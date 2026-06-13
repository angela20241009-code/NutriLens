import 'package:flutter/material.dart';
import 'package:nutrilens/theme/app_colors.dart';

class MacroProgress {
  const MacroProgress({
    required this.label,
    required this.current,
    required this.target,
    required this.unit,
  });

  final String label;
  final int current;
  final int target;
  final String unit;

  double get progress => target == 0 ? 0 : current / target;
}

class MacroProgressRow extends StatelessWidget {
  const MacroProgressRow({super.key, required this.macro});

  final MacroProgress macro;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            macro.label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.limeDark,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.onLime,
              ),
              children: [
                TextSpan(text: '${macro.current}${macro.unit}'),
                TextSpan(
                  text: ' /${macro.target}',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: AppColors.onLime.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: macro.progress.clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: AppColors.limeDark.withValues(alpha: 0.4),
              valueColor: const AlwaysStoppedAnimation(AppColors.onLime),
            ),
          ),
        ],
      ),
    );
  }
}
