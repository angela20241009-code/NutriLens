import 'package:flutter/material.dart';
import 'package:nutrilens/theme/app_colors.dart';
import 'package:nutrilens/theme/theme_palette_scope.dart';

import 'ble_camera.dart';
import 'description_format.dart';
import 'photo_view_page.dart';
import 'vision.dart';

enum _LayoutMode { camera, history }

void _log(String msg) => debugPrint('[UI] $msg');

class BleCameraTabPage extends StatefulWidget {
  const BleCameraTabPage({super.key});

  @override
  State<BleCameraTabPage> createState() => _BleCameraTabPageState();
}

class _BleCameraTabPageState extends State<BleCameraTabPage> {
  final BleCamera cam = BleCamera();
  _LayoutMode mode = _LayoutMode.camera;

  @override
  void initState() {
    super.initState();
    cam.addListener(_onChange);
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    cam.removeListener(_onChange);
    cam.dispose();
    super.dispose();
  }

  bool get _busy =>
      cam.state == CamState.scanning || cam.state == CamState.connecting;

  CapturedPhoto? get _latest => cam.photos.isEmpty ? null : cam.photos.first;

  Future<void> _captureOrConnect() async {
    _log(
      'Capture pressed (state=${cam.state.name}, '
      'connected=${cam.isConnected}, phase=${cam.capturePhase.name})',
    );
    if (_busy || cam.isCapturing) {
      return;
    }
    if (!cam.isConnected) {
      await cam.start();
    }
    if (cam.isConnected) {
      await cam.shoot();
    }
  }

  Future<void> _toggleConnection() async {
    if (_busy) {
      return;
    }
    if (cam.isConnected) {
      await cam.disconnect();
      return;
    }
    await cam.start();
  }

  void _retryDescription(CapturedPhoto photo) {
    cam.describe(photo);
  }

  void _openPhoto(CapturedPhoto photo, String heroTag) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PhotoViewPage(photo: photo, heroTag: heroTag, cam: cam),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = ThemePaletteScope.primary(context);
    final onPrimary = ThemePaletteScope.onPrimary(context);
    final strings = _LensStrings.of(context);
    cam.setLanguageCode(strings.languageCode);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    strings.lensCaptureTitle,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _ConnectionCard(
                cam: cam,
                busy: _busy,
                onConnectToggle: _toggleConnection,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ActionPillButton(
                      label: _captureLabel(cam, _busy, strings),
                      onPressed: _busy || cam.isCapturing
                          ? null
                          : _captureOrConnect,
                      filled: true,
                      primary: primary,
                      onPrimary: onPrimary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionPillButton(
                      label: mode == _LayoutMode.camera
                          ? strings.history
                          : strings.camera,
                      onPressed: () {
                        setState(() {
                          mode = mode == _LayoutMode.camera
                              ? _LayoutMode.history
                              : _LayoutMode.camera;
                        });
                      },
                      filled: false,
                      primary: primary,
                      onPrimary: onPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: mode == _LayoutMode.camera
                      ? _CameraPane(
                          key: const ValueKey('camera'),
                          latest: _latest,
                          cam: cam,
                          onRetry: _retryDescription,
                          onOpenPhoto: _openPhoto,
                        )
                      : _HistoryPane(
                          key: const ValueKey('history'),
                          cam: cam,
                          onRetry: _retryDescription,
                          onOpenPhoto: _openPhoto,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConnectionCard extends StatelessWidget {
  const _ConnectionCard({
    required this.cam,
    required this.busy,
    required this.onConnectToggle,
  });

  final BleCamera cam;
  final bool busy;
  final VoidCallback onConnectToggle;

  @override
  Widget build(BuildContext context) {
    final primary = ThemePaletteScope.primary(context);
    final strings = _LensStrings.of(context);
    final muted = ThemePaletteScope.navInactive(
      context,
    ).withValues(alpha: 0.75);

    final statusText = cam.isConnected
        ? strings.connectedMtu(cam.mtu)
        : busy
        ? strings.connectingToDevice(kDeviceName)
        : strings.notConnected;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              cam.isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
              size: 20,
              color: primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              statusText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, color: muted),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: busy ? null : onConnectToggle,
            child: Text(cam.isConnected ? strings.disconnect : strings.connect),
          ),
        ],
      ),
    );
  }
}

class _CameraPane extends StatelessWidget {
  const _CameraPane({
    super.key,
    required this.latest,
    required this.cam,
    required this.onRetry,
    required this.onOpenPhoto,
  });

  final CapturedPhoto? latest;
  final BleCamera cam;
  final void Function(CapturedPhoto photo) onRetry;
  final void Function(CapturedPhoto photo, String heroTag) onOpenPhoto;

  @override
  Widget build(BuildContext context) {
    final strings = _LensStrings.of(context);
    return Column(
      children: [
        Expanded(
          child: _PhotoCard(
            photo: latest,
            label: strings.lastPhoto,
            heroTag: 'latest-photo',
            onTap: latest == null
                ? null
                : () => onOpenPhoto(latest!, 'latest-photo'),
          ),
        ),
        const SizedBox(height: 12),
        _DescriptionCard(photo: latest, onRetry: onRetry),
      ],
    );
  }
}

class _HistoryPane extends StatelessWidget {
  const _HistoryPane({
    super.key,
    required this.cam,
    required this.onRetry,
    required this.onOpenPhoto,
  });

  final BleCamera cam;
  final void Function(CapturedPhoto photo) onRetry;
  final void Function(CapturedPhoto photo, String heroTag) onOpenPhoto;

  @override
  Widget build(BuildContext context) {
    final strings = _LensStrings.of(context);
    if (cam.photos.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Center(
          child: Text(strings.noPhotosYet, textAlign: TextAlign.center),
        ),
      );
    }

    return ListView.separated(
      itemCount: cam.photos.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final photo = cam.photos[index];
        final heroTag = 'history-$index';
        return _HistoryTile(
          photo: photo,
          heroTag: heroTag,
          onTap: () => onOpenPhoto(photo, heroTag),
          onRetry: () => onRetry(photo),
        );
      },
    );
  }
}

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({
    required this.photo,
    required this.label,
    required this.heroTag,
    required this.onTap,
  });

  final CapturedPhoto? photo;
  final String label;
  final String heroTag;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (photo != null)
              Hero(
                tag: heroTag,
                child: Image.memory(photo!.bytes, fit: BoxFit.cover),
              )
            else
              const Center(
                child: Icon(
                  Icons.photo_camera_back_outlined,
                  size: 54,
                  color: Colors.white38,
                ),
              ),
            Positioned(
              left: 12,
              top: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.52),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(label),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard({required this.photo, required this.onRetry});

  final CapturedPhoto? photo;
  final void Function(CapturedPhoto photo) onRetry;

  @override
  Widget build(BuildContext context) {
    final primary = ThemePaletteScope.primary(context);
    final strings = _LensStrings.of(context);
    final hasPhoto = photo != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            strings.aiNutritionNote,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 8),
          if (!Vision.isConfigured)
            Text(strings.openAiKeyMissing)
          else if (!hasPhoto)
            Text(
              strings.capturePrompt,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            )
          else
            _DescriptionBody(photo: photo!, onRetry: () => onRetry(photo!)),
          if (hasPhoto && Vision.isConfigured)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => onRetry(photo!),
                icon: Icon(Icons.refresh, color: primary, size: 18),
                label: Text(strings.retry, style: TextStyle(color: primary)),
              ),
            ),
        ],
      ),
    );
  }
}

class _DescriptionBody extends StatelessWidget {
  const _DescriptionBody({required this.photo, required this.onRetry});

  final CapturedPhoto photo;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final strings = _LensStrings.of(context);
    final formattedDescription = formatAiDescription(
      photo.description,
      languageCode: strings.languageCode,
    );
    final textStyle = TextStyle(
      color: Colors.white.withValues(alpha: 0.9),
      height: 1.35,
    );

    return switch (photo.descState) {
      DescState.pending => Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 10),
          Text(strings.describing),
        ],
      ),
      DescState.done => Text(
        formattedDescription.isEmpty
            ? strings.noDescriptionAvailable
            : formattedDescription,
        style: textStyle,
      ),
      DescState.failed => InkWell(
        onTap: onRetry,
        child: Text(
          '${photo.descError}\n${strings.tapRetryToTryAgain}',
          style: textStyle,
        ),
      ),
      DescState.none => Text(strings.tapRetryToDescribe, style: textStyle),
    };
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.photo,
    required this.heroTag,
    required this.onTap,
    required this.onRetry,
  });

  final CapturedPhoto photo;
  final String heroTag;
  final VoidCallback onTap;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final strings = _LensStrings.of(context);
    return Material(
      color: AppColors.cardDark,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Hero(
                  tag: heroTag,
                  child: Image.memory(
                    photo.bytes,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${photo.receivedAt.hour.toString().padLeft(2, '0')}:${photo.receivedAt.minute.toString().padLeft(2, '0')}:${photo.receivedAt.second.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(photo.bytes.length / 1024).toStringAsFixed(1)} KB · ${photo.elapsed.inMilliseconds} ms · ${photo.kbPerSecond.toStringAsFixed(1)} KB/s',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                tooltip: strings.retryDescription,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionPillButton extends StatelessWidget {
  const _ActionPillButton({
    required this.label,
    required this.onPressed,
    required this.filled,
    required this.primary,
    required this.onPrimary,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool filled;
  final Color primary;
  final Color onPrimary;

  @override
  Widget build(BuildContext context) {
    if (filled) {
      return FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(label),
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: Colors.white.withValues(alpha: 0.22)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(label),
    );
  }
}

String _captureLabel(BleCamera cam, bool busy, _LensStrings strings) {
  if (busy) {
    return strings.connecting;
  }
  if (cam.isCapturing) {
    return switch (cam.capturePhase) {
      CapturePhase.requested => strings.waitingForCamera,
      CapturePhase.receiving => strings.receiving(cam.progress),
      CapturePhase.describing => strings.describing,
      CapturePhase.idle => strings.capturePhoto,
    };
  }
  return cam.isConnected ? strings.capturePhoto : strings.connectAndCapture;
}

class _LensStrings {
  const _LensStrings._({required this.languageCode});

  final String languageCode;

  static _LensStrings of(BuildContext context) {
    return _LensStrings._(
      languageCode: Localizations.localeOf(context).languageCode,
    );
  }

  String get lensCaptureTitle => switch (languageCode) {
    'es' => 'Captura de lente',
    'zh' => '镜头拍摄',
    _ => 'Lens Capture',
  };

  String get history => switch (languageCode) {
    'es' => 'Historial',
    'zh' => '历史',
    _ => 'History',
  };

  String get camera => switch (languageCode) {
    'es' => 'Cámara',
    'zh' => '相机',
    _ => 'Camera',
  };

  String connectedMtu(int mtu) => switch (languageCode) {
    'es' => 'Conectado · MTU $mtu',
    'zh' => '已连接 · MTU $mtu',
    _ => 'Connected · MTU $mtu',
  };

  String connectingToDevice(String deviceName) => switch (languageCode) {
    'es' => 'Conectando a $deviceName...',
    'zh' => '正在连接到 $deviceName...',
    _ => 'Connecting to $deviceName...',
  };

  String get notConnected => switch (languageCode) {
    'es' => 'Sin conexión',
    'zh' => '未连接',
    _ => 'Not connected',
  };

  String get connect => switch (languageCode) {
    'es' => 'Conectar',
    'zh' => '连接',
    _ => 'Connect',
  };

  String get disconnect => switch (languageCode) {
    'es' => 'Desconectar',
    'zh' => '断开',
    _ => 'Disconnect',
  };

  String get lastPhoto => switch (languageCode) {
    'es' => 'Última foto',
    'zh' => '最新照片',
    _ => 'Last photo',
  };

  String get noPhotosYet => switch (languageCode) {
    'es' => 'Aún no hay fotos. Toma una desde el modo Cámara.',
    'zh' => '还没有照片。请在相机模式下拍摄一张。',
    _ => 'No photos yet. Capture one from Camera mode.',
  };

  String get aiNutritionNote => switch (languageCode) {
    'es' => 'Nota nutricional de IA',
    'zh' => 'AI 营养说明',
    _ => 'AI nutrition note',
  };

  String get openAiKeyMissing => switch (languageCode) {
    'es' => 'OPENAI_API_KEY no está configurada en assets/.env',
    'zh' => 'assets/.env 中未配置 OPENAI_API_KEY',
    _ => 'OPENAI_API_KEY not configured in assets/.env',
  };

  String get capturePrompt => switch (languageCode) {
    'es' => 'Toma una foto para generar detalles nutricionales.',
    'zh' => '拍摄一张照片以生成营养详情。',
    _ => 'Capture a photo to generate nutrition details.',
  };

  String get retry => switch (languageCode) {
    'es' => 'Reintentar',
    'zh' => '重试',
    _ => 'Retry',
  };

  String get describing => switch (languageCode) {
    'es' => 'Describiendo...',
    'zh' => '描述中...',
    _ => 'Describing...',
  };

  String get noDescriptionAvailable => switch (languageCode) {
    'es' => 'No hay descripción disponible.',
    'zh' => '暂无描述。',
    _ => 'No description available.',
  };

  String get tapRetryToTryAgain => switch (languageCode) {
    'es' => 'Toca Reintentar para intentarlo de nuevo.',
    'zh' => '点击重试以再次尝试。',
    _ => 'Tap retry to try again.',
  };

  String get tapRetryToDescribe => switch (languageCode) {
    'es' => 'Toca Reintentar para describir esta foto.',
    'zh' => '点击重试以描述这张照片。',
    _ => 'Tap Retry to describe this photo.',
  };

  String get retryDescription => switch (languageCode) {
    'es' => 'Reintentar descripción',
    'zh' => '重试描述',
    _ => 'Retry description',
  };

  String get connecting => switch (languageCode) {
    'es' => 'Conectando...',
    'zh' => '连接中...',
    _ => 'Connecting...',
  };

  String get waitingForCamera => switch (languageCode) {
    'es' => 'Esperando la cámara...',
    'zh' => '等待相机中...',
    _ => 'Waiting for camera...',
  };

  String receiving(double progress) => switch (languageCode) {
    'es' => 'Recibiendo ${(progress * 100).toStringAsFixed(0)}%',
    'zh' => '接收中 ${(progress * 100).toStringAsFixed(0)}%',
    _ => 'Receiving ${(progress * 100).toStringAsFixed(0)}%',
  };

  String get capturePhoto => switch (languageCode) {
    'es' => 'Capturar foto',
    'zh' => '拍摄照片',
    _ => 'Capture photo',
  };

  String get connectAndCapture => switch (languageCode) {
    'es' => 'Conectar y capturar',
    'zh' => '连接并拍摄',
    _ => 'Connect & capture',
  };
}
