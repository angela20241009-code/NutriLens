import 'package:flutter/material.dart';
import 'package:nutrilens/features/schedule/schedule_view_filter.dart';
import 'package:nutrilens/features/schedule/widgets/timeline_event_tile.dart';
import 'package:nutrilens/features/schedule/widgets/timeline_meal_tile.dart';
import 'package:nutrilens/models/meal.dart';
import 'package:nutrilens/models/schedule_event.dart';
import 'package:nutrilens/theme/app_colors.dart';

enum _TimelineItemKind { event, meal }

class _TimelineItem {
  const _TimelineItem.event(this.event) : meal = null, kind = _TimelineItemKind.event;

  const _TimelineItem.meal(this.meal) : event = null, kind = _TimelineItemKind.meal;

  final _TimelineItemKind kind;
  final UserScheduleEvent? event;
  final Meal? meal;

  DateTime get startAt =>
      kind == _TimelineItemKind.event ? event!.startAt : meal!.loggedAt;
}

class ScheduleTimeline extends StatelessWidget {
  const ScheduleTimeline({
    super.key,
    required this.events,
    required this.loggedMeals,
    required this.filter,
    this.onEventTap,
  });

  final List<UserScheduleEvent> events;
  final List<Meal> loggedMeals;
  final ScheduleViewFilter filter;
  final ValueChanged<UserScheduleEvent>? onEventTap;

  @override
  Widget build(BuildContext context) {
    final items = _buildItems();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Timeline', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        if (items.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              _emptyMessage,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          )
        else
          for (var i = 0; i < items.length; i++)
            switch (items[i].kind) {
              _TimelineItemKind.event => TimelineEventTile(
                event: items[i].event!,
                isLast: i == items.length - 1,
                onDelete: onEventTap == null
                    ? null
                    : () => onEventTap!(items[i].event!),
              ),
              _TimelineItemKind.meal => TimelineMealTile(
                meal: items[i].meal!,
                isLast: i == items.length - 1,
              ),
            },
      ],
    );
  }

  String get _emptyMessage {
    switch (filter) {
      case ScheduleViewFilter.all:
        return 'No events or logged meals for this day.';
      case ScheduleViewFilter.events:
        return 'No events scheduled for this day.';
      case ScheduleViewFilter.loggedMeals:
        return 'No logged meals for this day.';
    }
  }

  List<_TimelineItem> _buildItems() {
    final items = <_TimelineItem>[
      if (filter == ScheduleViewFilter.all ||
          filter == ScheduleViewFilter.events)
        ...events.map(_TimelineItem.event),
      if (filter == ScheduleViewFilter.all ||
          filter == ScheduleViewFilter.loggedMeals)
        ...loggedMeals.map(_TimelineItem.meal),
    ]..sort((a, b) => a.startAt.compareTo(b.startAt));

    return items;
  }
}
