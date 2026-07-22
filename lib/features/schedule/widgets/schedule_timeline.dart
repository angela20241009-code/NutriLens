import 'package:flutter/material.dart';
import 'package:nutrilens/features/schedule/schedule_view_filter.dart';
import 'package:nutrilens/features/schedule/widgets/timeline_event_tile.dart';
import 'package:nutrilens/features/schedule/widgets/timeline_meal_tile.dart';
import 'package:nutrilens/features/schedule/widgets/timeline_sleep_tile.dart';
import 'package:nutrilens/models/meal.dart';
import 'package:nutrilens/models/schedule_event.dart';
import 'package:nutrilens/theme/app_colors.dart';

enum _TimelineItemKind { event, meal, sleep }

class _TimelineItem {
  const _TimelineItem.event(this.event)
    : meal = null,
      sleepHours = null,
      kind = _TimelineItemKind.event;

  const _TimelineItem.meal(this.meal)
    : event = null,
      sleepHours = null,
      kind = _TimelineItemKind.meal;

  const _TimelineItem.sleep(this.sleepHours)
    : event = null,
      meal = null,
      kind = _TimelineItemKind.sleep;

  final _TimelineItemKind kind;
  final UserScheduleEvent? event;
  final Meal? meal;
  final double? sleepHours;

  DateTime get startAt {
    switch (kind) {
      case _TimelineItemKind.event:
        return event!.startAt;
      case _TimelineItemKind.meal:
        return meal!.loggedAt;
      case _TimelineItemKind.sleep:
        return DateTime(1970, 1, 1);
    }
  }
}

class ScheduleTimeline extends StatelessWidget {
  const ScheduleTimeline({
    super.key,
    required this.events,
    required this.loggedMeals,
    required this.filter,
    this.sleepHours = 0,
    this.onEventTap,
    this.onSleepTap,
  });

  final List<UserScheduleEvent> events;
  final List<Meal> loggedMeals;
  final ScheduleViewFilter filter;
  final double sleepHours;
  final ValueChanged<UserScheduleEvent>? onEventTap;
  final VoidCallback? onSleepTap;

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
              _TimelineItemKind.sleep => TimelineSleepTile(
                sleepHours: items[i].sleepHours!,
                isLast: i == items.length - 1,
                onTap: onSleepTap,
              ),
            },
      ],
    );
  }

  String get _emptyMessage {
    switch (filter) {
      case ScheduleViewFilter.all:
        return 'No events, meals, or sleep logged for this day.';
      case ScheduleViewFilter.events:
        return 'No events scheduled for this day.';
      case ScheduleViewFilter.loggedMeals:
        return 'No logged meals for this day.';
      case ScheduleViewFilter.sleep:
        return 'No sleep logged for this day.';
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
      if ((filter == ScheduleViewFilter.all ||
              filter == ScheduleViewFilter.sleep) &&
          sleepHours > 0)
        _TimelineItem.sleep(sleepHours),
    ]..sort((a, b) {
      if (a.kind == _TimelineItemKind.sleep &&
          b.kind != _TimelineItemKind.sleep) {
        return -1;
      }
      if (b.kind == _TimelineItemKind.sleep &&
          a.kind != _TimelineItemKind.sleep) {
        return 1;
      }
      return a.startAt.compareTo(b.startAt);
    });

    return items;
  }
}
