import 'package:flutter/material.dart';
import 'package:nutrilens/features/schedule/widgets/timeline_event_tile.dart';
import 'package:nutrilens/models/schedule_event.dart';
import 'package:nutrilens/theme/app_colors.dart';

class ScheduleTimeline extends StatelessWidget {
  const ScheduleTimeline({
    super.key,
    required this.events,
  });

  final List<ScheduleEvent> events;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Timeline',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        if (events.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              'No events scheduled for this day.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          )
        else
          for (var i = 0; i < events.length; i++)
            TimelineEventTile(
              event: events[i],
              isLast: i == events.length - 1,
            ),
      ],
    );
  }
}
