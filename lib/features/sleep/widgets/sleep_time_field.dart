import 'package:flutter/material.dart';
import 'package:nutrilens/features/sleep/sleep_logging.dart';
import 'package:nutrilens/theme/app_colors.dart';

class SleepTimeField extends StatelessWidget {
  const SleepTimeField({
    super.key,
    required this.label,
    required this.minutes,
    required this.placeholder,
    required this.onTap,
  });

  final String label;
  final int? minutes;
  final String placeholder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: BorderSide(color: AppColors.sleepAccent.withValues(alpha: 0.6)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            minutes == null ? placeholder : formatMinutesAsClock(minutes!),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
