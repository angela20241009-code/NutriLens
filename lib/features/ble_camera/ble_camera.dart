/// Client for the XIAO ESP32-S3 Sense BLE camera (BLE_Camera_OLED_Angela.ino).
///
/// Wire protocol, all little-endian, on the IMG notify characteristic:
///   header : "IMGH" + uint32 total_len + uint16 num_chunks + uint16 payload_size
///   chunk  : uint16 index + `payload_size` bytes of JPEG
///   footer : "IMGE" + uint32 total_len
///
/// We write back to the CMD characteristic:
///   0x01 + uint16 next_index  ACK  - "I have everything below next_index"
///   0x02                      SHOOT - the only thing that makes the board capture
///   0x03                      READY - subscribed; the board now accepts SHOOT
///   0x04                      DESC_BEGIN - start a description
///   0x05 + UTF-8 bytes        DESC_CHUNK - part of the description
///   0x06                      DESC_END - board shows the description on its OLED
///   0x07 + UTF-8 bytes        ERROR - board shows a short error message
///
/// One capture is one cycle: SHOOT -> photo arrives -> ChatGPT describes it ->
/// the description (or an error) goes back to the board. [capturePhase] tracks
/// where the cycle is, and a new SHOOT is refused until it finishes.
///
/// The board sends a window of chunks, waits for an ACK, and rewinds to
/// whatever index we ask for, so a dropped notification costs a retransmit
/// instead of the whole image.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'description_format.dart';
import 'vision.dart';

final Guid kServiceUuid = Guid('b1a70001-5f3a-4d2b-9c1e-8a7f6d3e2c10');
final Guid kImgCharUuid = Guid('b1a70002-5f3a-4d2b-9c1e-8a7f6d3e2c10');
final Guid kCmdCharUuid = Guid('b1a70003-5f3a-4d2b-9c1e-8a7f6d3e2c10');
final Guid kStatCharUuid = Guid('b1a70004-5f3a-4d2b-9c1e-8a7f6d3e2c10');

const String kDeviceName = 'XIAO-S3-Angela';

/// Must match ACK_WINDOW in the firmware.
const int kAckWindow = 4;

/// How long to wait for the photo header after SHOOT before giving up.
const Duration kShootTimeout = Duration(seconds: 15);

enum CamState { idle, scanning, connecting, connected, receiving }

/// Where the current capture cycle has got to.
enum CapturePhase { idle, requested, receiving, describing }

/// Where a photo's OpenAI description has got to.
enum DescState { none, pending, done, failed }

/// One received image, with the stats worth showing in the UI.
class CapturedPhoto {
  CapturedPhoto({
    required this.bytes,
    required this.receivedAt,
    required this.elapsed,
    required this.recoveredDrops,
  });

  final Uint8List bytes;
  final DateTime receivedAt;
  final Duration elapsed;
  final int recoveredDrops;

  /// Filled in asynchronously by [BleCamera] once the image is complete.
  DescState descState = DescState.none;
  String? description;
  String? descError;

  /// Result of echoing [description] back to the board. Null until attempted.
  String? sendError;
  bool sentToBoard = false;

  double get kbPerSecond {
    final s = elapsed.inMicroseconds / 1e6;
    return s > 0 ? bytes.length / s / 1024 : 0;
  }
}

/// Scans, connects, and reassembles the chunked image stream.
///
/// A [ChangeNotifier] so the UI can just watch it; every field below is
/// read-only from the outside.
class BleCamera extends ChangeNotifier {
  CamState state = CamState.idle;
  String status = 'Idle';
  BluetoothDevice? device;
  int mtu = 0;

  /// Newest first.
  final List<CapturedPhoto> photos = [];

  /// 0..1 while an image is arriving, otherwise 0.
  double progress = 0;
  int bytesReceived = 0;
  int bytesExpected = 0;

  CapturePhase capturePhase = CapturePhase.idle;
  bool get isCapturing => capturePhase != CapturePhase.idle;

  /// The photo whose description finishes the current cycle. A retry on an
  /// older photo must not end a cycle that is still running.
  CapturedPhoto? _cyclePhoto;
  Timer? _shootTimeout;

  BluetoothCharacteristic? _cmdChar;
  StreamSubscription<List<int>>? _imgSub;
  StreamSubscription<List<int>>? _statSub;
  StreamSubscription<BluetoothConnectionState>? _connSub;
  StreamSubscription<List<ScanResult>>? _scanSub;

  // Reassembly state.
  final BytesBuilder _buf = BytesBuilder(copy: true);
  int _expected = 0;
  int _nchunks = 0;
  int _nextIndex = 0;
  int _recovered = 0;
  DateTime? _t0;

  bool get isConnected => device != null && device!.isConnected;

  void _set(CamState s, String msg) {
    state = s;
    status = msg;
    _log('${s.name}: $msg');
    notifyListeners();
  }

  /// Connection/transfer log, visible in the `flutter run` terminal.
  static void _log(String msg) => debugPrint('[BLE] $msg');

  // ---------------- connection ----------------

  /// Scan for the board's service UUID, connect, subscribe, and say READY.
  Future<void> start() async {
    // We think we're connected but the link is gone (e.g. the board reset and
    // the disconnect was missed). Clean up and connect again rather than
    // leaving the Connect button stuck.
    if ((state == CamState.connected || state == CamState.receiving) &&
        !isConnected) {
      _log('Stale connection (state=${state.name}, device gone) - resetting');
      await _teardown('Reconnecting');
    }
    if (state != CamState.idle) {
      _log('start() ignored: state is ${state.name}, not idle');
      return;
    }
    _set(CamState.scanning, 'Scanning for $kDeviceName ...');

    try {
      if (!await FlutterBluePlus.isSupported) {
        _set(CamState.idle, 'Bluetooth is not supported on this device');
        return;
      }
      _log('Bluetooth adapter: ${FlutterBluePlus.adapterStateNow.name}');

      // iOS reports "unknown" for a moment after launch and rejects a scan
      // started then. Wait for "on" instead of failing the first tap.
      if (FlutterBluePlus.adapterStateNow != BluetoothAdapterState.on) {
        final s = await FlutterBluePlus.adapterState
            .firstWhere(
              (s) =>
                  s == BluetoothAdapterState.on ||
                  s == BluetoothAdapterState.off ||
                  s == BluetoothAdapterState.unauthorized,
            )
            .timeout(
              const Duration(seconds: 5),
              onTimeout: () => FlutterBluePlus.adapterStateNow,
            );
        _log('Bluetooth adapter now: ${s.name}');
        if (s != BluetoothAdapterState.on) {
          _set(
            CamState.idle,
            s == BluetoothAdapterState.unauthorized
                ? 'Bluetooth permission denied - allow it in Settings'
                : 'Turn Bluetooth on and try again',
          );
          return;
        }
      }

      final found = Completer<BluetoothDevice>();
      _scanSub = FlutterBluePlus.scanResults.listen((results) {
        for (final r in results) {
          // Match the service UUID, but fall back to the name in case the
          // advertisement drops it.
          final byUuid = r.advertisementData.serviceUuids.contains(
            kServiceUuid,
          );
          final byName =
              r.advertisementData.advName == kDeviceName ||
              r.device.platformName == kDeviceName;
          if ((byUuid || byName) && !found.isCompleted) {
            _log(
              'Found ${r.device.platformName} (${r.device.remoteId}), '
              'RSSI ${r.rssi}, byUuid=$byUuid byName=$byName',
            );
            found.complete(r.device);
          }
        }
      });

      // No `withServices` filter: some ESP32 builds advertise the UUID only in
      // the scan response, which Android's hardware filter can miss.
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 20));

      final dev = await found.future.timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw TimeoutException('no device found'),
      );
      await FlutterBluePlus.stopScan();
      await _scanSub?.cancel();
      _scanSub = null;

      device = dev;
      _set(CamState.connecting, 'Connecting to ${dev.platformName} ...');

      // mtu:null so we can request it explicitly after connecting; iOS ignores
      // the request and negotiates ~185 on its own, which the firmware handles.
      await dev.connect(license: License.nonprofit, mtu: null);
      _log('connect() returned');

      // Listen only AFTER connecting: the stream replays the current state on
      // subscribe, and before connect() that is "disconnected", which used to
      // tear the connection down while it was still being made.
      _connSub = dev.connectionState.listen((s) {
        _log('Connection state: ${s.name}');
        if (s == BluetoothConnectionState.disconnected &&
            state != CamState.idle) {
          _teardown('Disconnected');
        }
      });
      try {
        mtu = await dev.requestMtu(517);
      } catch (e) {
        _log('requestMtu failed ($e), using mtuNow');
        mtu = dev.mtuNow;
      }

      final services = await dev.discoverServices();
      _log('Discovered ${services.length} services');
      // iOS negotiates the MTU on its own, often after connect() returns, so
      // mtuNow can still read 23 above. Pick up the real value now.
      if (dev.mtuNow > mtu) mtu = dev.mtuNow;
      final svc = services.firstWhere(
        (s) => s.serviceUuid == kServiceUuid,
        orElse: () => throw StateError('camera service not found'),
      );

      final imgChar = svc.characteristics.firstWhere(
        (c) => c.characteristicUuid == kImgCharUuid,
      );
      _cmdChar = svc.characteristics.firstWhere(
        (c) => c.characteristicUuid == kCmdCharUuid,
      );
      final statMatches = svc.characteristics.where(
        (c) => c.characteristicUuid == kStatCharUuid,
      );
      final statChar = statMatches.isEmpty ? null : statMatches.first;

      _imgSub = imgChar.onValueReceived.listen(_onImgData);
      await imgChar.setNotifyValue(true);

      if (statChar != null) {
        _statSub = statChar.onValueReceived.listen((d) {
          final msg = String.fromCharCodes(d);
          // The board already shows its own error on the OLED; just free the
          // Capture button.
          if (msg.startsWith('ERR')) {
            _resetImage();
            _endCapture();
            _set(CamState.connected, '[board] $msg');
            return;
          }
          _set(state, '[board] $msg');
        });
        await statChar.setNotifyValue(true); // status channel is optional
      }

      _set(
        CamState.connected,
        'Connected (MTU $mtu). Tap Capture to take a photo.',
      );
      await _cmd([
        0x03,
      ]); // READY - the board waits for SHOOT, it never captures on its own
    } catch (e) {
      await _teardown('Connection failed: $e');
    }
  }

  /// Start a capture cycle. Ignored while one is already running.
  Future<void> shoot() async {
    if (!isConnected || isCapturing) return;
    capturePhase = CapturePhase.requested;
    _log('SHOOT (0x02) sent');
    _shootTimeout?.cancel();
    _shootTimeout = Timer(kShootTimeout, () {
      if (capturePhase != CapturePhase.requested) return;
      _endCapture();
      _set(state, "Camera didn't respond. Try again.");
    });
    _set(state, 'Requested a capture ...');
    await _cmd([0x02]);
  }

  /// Finish the current cycle so the Capture button comes back.
  void _endCapture() {
    _shootTimeout?.cancel();
    _shootTimeout = null;
    _cyclePhoto = null;
    if (capturePhase == CapturePhase.idle) return;
    capturePhase = CapturePhase.idle;
    notifyListeners();
  }

  Future<void> disconnect() async {
    try {
      await device?.disconnect();
    } catch (_) {}
    await _teardown('Idle');
  }

  Future<void> _teardown(String msg) async {
    await _imgSub?.cancel();
    await _statSub?.cancel();
    await _connSub?.cancel();
    await _scanSub?.cancel();
    _imgSub = _statSub = null;
    _connSub = null;
    _scanSub = null;
    _cmdChar = null;
    device = null;
    mtu = 0;
    _resetImage();
    _endCapture();
    _set(CamState.idle, msg);
  }

  Future<void> _cmd(List<int> bytes) async {
    final c = _cmdChar;
    if (c == null) return;
    try {
      await c.write(bytes, withoutResponse: true);
    } catch (e) {
      // A failed ACK just means the board times out and resends the window.
      debugPrint('command write failed: $e');
    }
  }

  // ---------------- reassembly ----------------

  void _resetImage() {
    _buf.clear();
    _expected = 0;
    _nchunks = 0;
    _nextIndex = 0;
    _recovered = 0;
    _t0 = null;
    progress = 0;
    bytesReceived = 0;
    bytesExpected = 0;
  }

  /// Mutates state synchronously and fires ACKs without awaiting, so
  /// notifications are never processed out of order.
  void _onImgData(List<int> data) {
    final b = Uint8List.fromList(data);
    final bd = ByteData.sublistView(b);

    // Header: "IMGH" + uint32 total + uint16 nchunks + uint16 payload
    if (b.length == 12 && _tagIs(b, 'IMGH')) {
      _resetImage();
      _expected = bd.getUint32(4, Endian.little);
      _nchunks = bd.getUint16(8, Endian.little);
      _t0 = DateTime.now();
      bytesExpected = _expected;
      _shootTimeout?.cancel();
      capturePhase = CapturePhase.receiving;
      _set(
        CamState.receiving,
        'Incoming: $_expected bytes in $_nchunks chunks',
      );
      return;
    }

    // Footer: "IMGE" + uint32 total
    if (b.length == 8 && _tagIs(b, 'IMGE')) {
      _finish(bd.getUint32(4, Endian.little));
      return;
    }

    // Chunk: uint16 index + payload
    if (b.length < 2 || _expected == 0) return;
    final index = bd.getUint16(0, Endian.little);

    if (index != _nextIndex) {
      // Either a dropped notification or a retransmit of something we already
      // have. Take in-order data only and ask the board to resume from here.
      if (index > _nextIndex) _recovered++;
      unawaited(_ack());
      return;
    }

    _buf.add(b.sublist(2));
    _nextIndex++;
    bytesReceived = _buf.length;
    progress = _expected > 0 ? bytesReceived / _expected : 0;
    notifyListeners();

    if (_nextIndex % kAckWindow == 0 || _nextIndex == _nchunks) {
      unawaited(_ack());
    }
  }

  Future<void> _ack() =>
      _cmd([0x01, _nextIndex & 0xFF, (_nextIndex >> 8) & 0xFF]);

  void _finish(int total) {
    final bytes = _buf.toBytes();
    final elapsed = DateTime.now().difference(_t0 ?? DateTime.now());

    if (bytes.length != total) {
      _resetImage();
      _failCapture('Photo got corrupted. Try again.');
      _set(
        CamState.connected,
        'Size mismatch: got ${bytes.length}, expected $total - discarded',
      );
      return;
    }
    // JPEG sanity check: SOI at the start, EOI at the end.
    final soiOk = bytes.length > 4 && bytes[0] == 0xFF && bytes[1] == 0xD8;
    final eoiOk =
        bytes.length > 4 &&
        bytes[bytes.length - 2] == 0xFF &&
        bytes[bytes.length - 1] == 0xD9;
    if (!soiOk || !eoiOk) {
      _resetImage();
      _failCapture('Photo got corrupted. Try again.');
      _set(CamState.connected, 'Malformed JPEG (bad SOI/EOI) - discarded');
      return;
    }

    final photo = CapturedPhoto(
      bytes: bytes,
      receivedAt: DateTime.now(),
      elapsed: elapsed,
      recoveredDrops: _recovered,
    );
    photos.insert(0, photo);
    if (photos.length > 30) photos.removeLast(); // keep memory bounded
    capturePhase = CapturePhase.describing;
    _cyclePhoto = photo;
    unawaited(describe(photo));

    final drops = _recovered;
    _resetImage();
    _set(
      CamState.connected,
      '${(bytes.length / 1024).toStringAsFixed(1)} KB in '
      '${elapsed.inMilliseconds} ms '
      '(${photo.kbPerSecond.toStringAsFixed(1)} KB/s, $drops recovered drops)',
    );
  }

  // ---------------- image description ----------------

  /// Ask OpenAI to describe [photo]. Runs off the BLE path entirely, so a slow
  /// or failing API call never stalls the next capture. Safe to call again to
  /// retry a failure.
  ///
  /// Whatever happens, the board gets either the description or a short error,
  /// so its OLED never stays stuck on "Analyzing...".
  Future<void> describe(CapturedPhoto photo) async {
    if (photo.descState == DescState.pending) return;
    if (!Vision.isConfigured) {
      await _sendBoardError('No OpenAI key in the app');
      _endCycleFor(photo);
      return;
    }

    photo.descState = DescState.pending;
    photo.descError = null;
    notifyListeners();

    try {
      final text = await Vision.describe(photo.bytes);
      final formatted = formatAiDescription(text);
      photo.description = formatted;
      photo.descState = DescState.done;
      notifyListeners();
      await _sendDescriptionFor(photo, formatted); // shown on the board's OLED
    } catch (e) {
      photo.descError = e.toString();
      photo.descState = DescState.failed;
      notifyListeners();
      await _sendBoardError('ChatGPT failed. Try again.');
    } finally {
      _endCycleFor(photo);
    }
  }

  void _endCycleFor(CapturedPhoto photo) {
    if (identical(photo, _cyclePhoto)) _endCapture();
  }

  /// Tell the board the cycle failed and free the Capture button.
  void _failCapture(String msg) {
    unawaited(_sendBoardError(msg));
    _endCapture();
  }

  /// Show a short error on the board's OLED. One write, so [msg] must fit in
  /// the MTU; anything longer is cut off.
  Future<void> _sendBoardError(String msg) async {
    final c = _cmdChar;
    if (c == null || !isConnected) return;

    final limit = ((mtu > 23 ? mtu : 23) - 3 - 1).clamp(16, 512);
    var bytes = utf8.encode(msg);
    if (bytes.length > limit) bytes = bytes.sublist(0, limit);
    try {
      await c.write([0x07, ...bytes]);
    } catch (e) {
      debugPrint('sending error to board failed: $e');
    }
  }

  /// Write a description back to the board, which shows it on the OLED.
  ///
  /// Sent as DESC_BEGIN / DESC_CHUNK* / DESC_END on the CMD characteristic.
  /// These use acknowledged writes, unlike the image ACKs, so the fragments
  /// can't arrive out of order or go missing.
  /// Records the outcome on [photo] so a failure is visible in the UI rather
  /// than disappearing into the debug console.
  Future<void> _sendDescriptionFor(CapturedPhoto photo, String text) async {
    try {
      await sendDescription(text);
      photo.sentToBoard = true;
      photo.sendError = null;
    } catch (e) {
      photo.sentToBoard = false;
      photo.sendError = '$e';
      debugPrint('sending description failed: $e');
    }
    notifyListeners();
  }

  Future<void> sendDescription(String text) async {
    final c = _cmdChar;
    if (c == null || !isConnected) {
      throw StateError('not connected');
    }

    // One write is capped by the negotiated MTU: 3 bytes ATT overhead plus our
    // 1-byte opcode. iOS lands near 185, so expect ~180-byte fragments there.
    final limit = ((mtu > 23 ? mtu : 23) - 3 - 1).clamp(16, 512);
    final bytes = utf8.encode(text);

    await c.write([0x04]); // DESC_BEGIN
    for (var i = 0; i < bytes.length; i += limit) {
      final end = (i + limit < bytes.length) ? i + limit : bytes.length;
      // Splitting mid-character is fine: the board appends raw bytes.
      await c.write([0x05, ...bytes.sublist(i, end)]);
    }
    await c.write([0x06]); // DESC_END
  }

  static bool _tagIs(Uint8List b, String tag) {
    for (var i = 0; i < 4; i++) {
      if (b[i] != tag.codeUnitAt(i)) return false;
    }
    return true;
  }

  @override
  void dispose() {
    unawaited(_teardown('Idle'));
    super.dispose();
  }
}
