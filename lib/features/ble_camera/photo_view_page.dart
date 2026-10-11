import 'package:flutter/material.dart';

import 'ble_camera.dart';
import 'description_format.dart';
import 'vision.dart';

/// Full-screen, pinch-zoomable view of one received photo.
class PhotoViewPage extends StatelessWidget {
  const PhotoViewPage({
    super.key,
    required this.photo,
    required this.heroTag,
    required this.cam,
  });

  final CapturedPhoto photo;
  final String heroTag;
  final BleCamera cam;

  @override
  Widget build(BuildContext context) {
    final t = photo.receivedAt;
    final stamp =
        '${t.year}-${pad(t.month)}-${pad(t.day)} '
        '${pad(t.hour)}:${pad(t.minute)}:${pad(t.second)}';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(stamp, style: const TextStyle(fontSize: 16)),
      ),
      // Rebuild when the description arrives.
      body: AnimatedBuilder(
        animation: cam,
        builder: (context, _) => _body(context),
      ),
    );
  }

  Widget _body(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: InteractiveViewer(
            minScale: 0.8,
            maxScale: 6,
            child: Center(
              child: Hero(
                tag: heroTag,
                child: Image.memory(photo.bytes, fit: BoxFit.contain),
              ),
            ),
          ),
        ),
        _Description(photo: photo, onRetry: () => cam.describe(photo)),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _Stat(
                label: 'Size',
                value: '${(photo.bytes.length / 1024).toStringAsFixed(1)} KB',
              ),
              _Stat(
                label: 'Transfer',
                value: '${photo.elapsed.inMilliseconds} ms',
              ),
              _Stat(
                label: 'Rate',
                value: '${photo.kbPerSecond.toStringAsFixed(1)} KB/s',
              ),
              _Stat(label: 'Recovered', value: '${photo.recoveredDrops}'),
            ],
          ),
        ),
      ],
    );
  }

  static String pad(int n) => n.toString().padLeft(2, '0');
}

/// The OpenAI description panel: spinner, text, or a tappable error.
class _Description extends StatelessWidget {
  const _Description({required this.photo, required this.onRetry});

  final CapturedPhoto photo;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final formattedDescription = formatAiDescription(
      photo.description,
      languageCode: languageCode,
    );
    // Hide the panel entirely when there's no key, rather than nagging.
    if (!Vision.isConfigured) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(10),
      ),
      child: switch (photo.descState) {
        DescState.pending => const Row(
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Describing…', style: TextStyle(color: Colors.white70)),
          ],
        ),
        DescState.done => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formattedDescription.isEmpty
                  ? 'No description available.'
                  : formattedDescription,
              style: const TextStyle(color: Colors.white, height: 1.4),
            ),
            const SizedBox(height: 8),
            // Whether the board actually received it, so a failed write
            // isn't invisible.
            if (photo.sendError != null)
              Text(
                'Board: ${photo.sendError}',
                style: const TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 11,
                ),
              )
            else if (photo.sentToBoard)
              const Text(
                'Sent to board ✓',
                style: TextStyle(color: Colors.tealAccent, fontSize: 11),
              )
            else
              const Text(
                'Sending to board…',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
          ],
        ),
        DescState.failed => InkWell(
          onTap: onRetry,
          child: Row(
            children: [
              const Icon(Icons.refresh, size: 16, color: Colors.orangeAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${photo.descError}\nTap to retry.',
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        DescState.none => InkWell(
          onTap: onRetry,
          child: const Text(
            'Tap to describe this photo',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
      ],
    );
  }
}
