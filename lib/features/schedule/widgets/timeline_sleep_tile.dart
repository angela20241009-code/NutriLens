import 'package:flutter/material.dart';
import 'package:nutrilens/features/schedule/schedule_view_filter.dart';
import 'package:nutrilens/features/sleep/sleep_logging.dart';
import 'package:nutrilens/theme/app_colors.dart';

class TimelineSleepTile extends StatelessWidget {
  const TimelineSleepTile({
    super.key,
    required this.sleepHours,
    required this.isLast,
    this.onTap,
  });

  final double sleepHours;
  final bool isLast;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: scheduleSleepColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.background,
                    width: 2,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Material(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: scheduleSleepColor.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.nightlight_round,
                            color: scheduleSleepColor,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sleep logged',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatSleepHours(sleepHours),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        if (onTap != null)
                          Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: AppColors.textMuted.withValues(alpha: 0.7),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
