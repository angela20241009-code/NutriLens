import 'package:flutter/material.dart';
import 'package:nutrilens/features/home/home_dashboard_data.dart';
import 'package:nutrilens/features/sleep/sleep_logging.dart';
import 'package:nutrilens/theme/app_colors.dart';

class WeeklySleepSummaryCard extends StatelessWidget {
  const WeeklySleepSummaryCard({
    super.key,
    required this.days,
    required this.targetHours,
    required this.onLogSleepTap,
  });

  final List<WeeklySleepDay> days;
  final double targetHours;
  final VoidCallback onLogSleepTap;

  static const _weekdayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final loggedDays = days.where((day) => day.sleepHours > 0).length;
    final averageHours = loggedDays == 0
        ? 0.0
        : days
                  .where((day) => day.sleepHours > 0)
                  .fold<double>(0, (sum, day) => sum + day.sleepHours) /
              loggedDays;
    final maxBarHours = [
      targetHours,
      ...days.map((day) => day.sleepHours),
    ].reduce((a, b) => a > b ? a : b).clamp(1.0, 16.0);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.sleepAccent.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.nightlight_round,
                color: AppColors.sleepAccent.withValues(alpha: 0.95),
                size: 26,
              ),
              const SizedBox(width: 10),
              Text(
                'This week\'s sleep',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              TextButton(
                onPressed: onLogSleepTap,
                child: const Text(
                  'Log sleep',
                  style: TextStyle(
                    color: AppColors.sleepAccent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            loggedDays == 0
                ? 'No sleep logged yet this week.'
                : '${formatSleepHours(averageHours)} avg • ${loggedDays} of 7 days logged',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 132,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < days.length; i++)
                  Expanded(
                    child: _SleepBar(
                      label: _weekdayLabels[i],
                      sleepHours: days[i].sleepHours,
                      maxHours: maxBarHours,
                      targetHours: targetHours,
                      isToday: days[i].isToday,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _LegendSwatch(color: AppColors.sleepAccent, label: 'Logged'),
              const SizedBox(width: 16),
              _LegendSwatch(
                color: AppColors.sleepAccent.withValues(alpha: 0.25),
                label: 'Target ${targetHours.toStringAsFixed(1)}h',
                dashed: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SleepBar extends StatelessWidget {
  const _SleepBar({
    required this.label,
    required this.sleepHours,
    required this.maxHours,
    required this.targetHours,
    required this.isToday,
  });

  final String label;
  final double sleepHours;
  final double maxHours;
  final double targetHours;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final barHeight = sleepHours <= 0 ? 6.0 : (sleepHours / maxHours) * 92;
    final targetTop = (1 - (targetHours / maxHours).clamp(0.0, 1.0)) * 92;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: 92,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Positioned(
                  top: targetTop,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 1,
                    color: AppColors.sleepAccent.withValues(alpha: 0.35),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: double.infinity,
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: sleepHours > 0
                        ? AppColors.sleepAccent.withValues(
                            alpha: isToday ? 1 : 0.72,
                          )
                        : Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: isToday
                        ? Border.all(color: AppColors.sleepAccent, width: 1.5)
                        : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isToday
                  ? AppColors.sleepAccent
                  : AppColors.textMuted.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendSwatch extends StatelessWidget {
  const _LegendSwatch({
    required this.color,
    required this.label,
    this.dashed = false,
  });

  final Color color;
  final String label;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: dashed ? 2 : 10,
          decoration: BoxDecoration(
            color: dashed ? null : color,
            borderRadius: dashed ? null : BorderRadius.circular(3),
            border: dashed
                ? Border(
                    top: BorderSide(color: color, width: 2),
                  )
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textMuted.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }
}
