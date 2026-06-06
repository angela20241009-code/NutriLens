import 'package:flutter/material.dart';
import 'package:nutrilens/data/mock_schedule_data.dart';
import 'package:nutrilens/models/schedule_event.dart';
import 'package:nutrilens/theme/app_colors.dart';

class TimelineEventTile extends StatelessWidget {
  const TimelineEventTile({
    super.key,
    required this.event,
    required this.isLast,
  });

  final ScheduleEvent event;
  final bool isLast;

  Color get _accentColor {
    switch (event.type) {
      case ScheduleEventType.meal:
        return AppColors.orange;
      case ScheduleEventType.training:
      case ScheduleEventType.match:
        return AppColors.lime;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor;
    final iconTextColor =
        event.type == ScheduleEventType.meal ? Colors.white : AppColors.onLime;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 52,
            child: Padding(
              padding: const EdgeInsets.only(top: 18),
              child: Text(
                MockScheduleData.formatTime(event.start),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 20,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.cardDarker,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        event.icon,
                        color: iconTextColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            event.subtitle,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 12,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
