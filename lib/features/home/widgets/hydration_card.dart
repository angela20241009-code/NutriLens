import 'package:flutter/material.dart';
import 'package:nutrilens/theme/app_colors.dart';

class HydrationCard extends StatefulWidget {
  const HydrationCard({
    super.key,
    required this.currentLiters,
    required this.targetLiters,
    this.onLitersCommitted,
  });

  final double currentLiters;
  final double targetLiters;
  final ValueChanged<double>? onLitersCommitted;

  @override
  State<HydrationCard> createState() => _HydrationCardState();
}

class _HydrationCardState extends State<HydrationCard> {
  late double _sliderValue;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _sliderValue = _clampValue(widget.currentLiters);
  }

  @override
  void didUpdateWidget(covariant HydrationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isDragging) {
      return;
    }
    if (oldWidget.currentLiters != widget.currentLiters ||
        oldWidget.targetLiters != widget.targetLiters) {
      _sliderValue = _clampValue(widget.currentLiters);
    }
  }

  double _clampValue(double value) {
    final max = widget.targetLiters <= 0 ? 1.0 : widget.targetLiters;
    return value.clamp(0.0, max);
  }

  int _sliderDivisions(double maxLiters) {
    final divisions = (maxLiters * 10).round();
    return divisions < 1 ? 1 : divisions;
  }

  @override
  Widget build(BuildContext context) {
    final targetLiters = widget.targetLiters <= 0 ? 1.0 : widget.targetLiters;
    final displayLiters = _sliderValue;
    final remaining = (targetLiters - displayLiters).clamp(
      0.0,
      targetLiters,
    );
    final goalMet = remaining <= 0.05;
    final progress = targetLiters <= 0
        ? 0.0
        : (displayLiters / targetLiters).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.hydrationBlue,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.water_drop_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hydration reminder',
                      style: TextStyle(fontSize: 13, color: Colors.white70),
                    ),
                    Text(
                      goalMet
                          ? 'Great job — goal reached!'
                          : 'Drink ${_formatLiters(remaining)}L more today',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_formatLiters(displayLiters)}L of ${_formatLiters(targetLiters)}L logged',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 44,
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 4,
                      backgroundColor: Colors.white.withValues(alpha: 0.25),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                    Text(
                      '${(progress * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.25),
              thumbColor: Colors.white,
              overlayColor: Colors.white.withValues(alpha: 0.12),
              trackHeight: 4,
            ),
            child: Slider(
              min: 0,
              max: targetLiters,
              divisions: _sliderDivisions(targetLiters),
              value: _sliderValue,
              onChanged: widget.onLitersCommitted == null
                  ? null
                  : (value) {
                      setState(() {
                        _isDragging = true;
                        _sliderValue = value;
                      });
                    },
              onChangeEnd: widget.onLitersCommitted == null
                  ? null
                  : (value) {
                      setState(() => _isDragging = false);
                      widget.onLitersCommitted!(value);
                    },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0L',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              Text(
                '${_formatLiters(targetLiters)}L',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatLiters(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }
}
