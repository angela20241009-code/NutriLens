import 'package:flutter/material.dart';
import 'package:nutrilens/models/schedule_event.dart';

class MockScheduleData {
  static final DateTime anchorDate = DateTime(2026, 4, 15);

  static List<DateTime> get weekDates =>
      List.generate(6, (i) => DateTime(2026, 4, 14 + i));

  static DateTime get defaultSelectedDate => anchorDate;

  static const sessionTitle = 'Serve & Rally Drills';
  static const sessionSubtitle = 'Today · 4:30 PM · Eat carbs in 2h';

  static final MatchDayInfo matchDay = MatchDayInfo(
    date: anchorDate,
    badge: 'CONFERENCE FINALS',
    matchup: 'Home athlete vs Rivera',
    location: 'Lincoln Courts',
    time: const TimeOfDay(hour: 16, minute: 0),
    fuelingHints: const [
      FuelingHint(timing: '3H BEFORE', label: 'Big Carbs'),
      FuelingHint(timing: '1H BEFORE', label: 'Light Snack'),
      FuelingHint(timing: 'POST', label: 'Protein+'),
    ],
  );

  static final Map<DateTime, List<ScheduleEvent>> _eventsByDay = {
    _dayKey(anchorDate): [
      ScheduleEvent(
        start: DateTime(2026, 4, 15, 7),
        title: 'Breakfast • Power Oats',
        subtitle: '620 kcal · Carb loading',
        type: ScheduleEventType.meal,
        icon: Icons.ramen_dining_rounded,
      ),
      ScheduleEvent(
        start: DateTime(2026, 4, 15, 10),
        title: 'Light Stretch Session',
        subtitle: '30 min · Mobility',
        type: ScheduleEventType.training,
        icon: Icons.fitness_center_rounded,
      ),
      ScheduleEvent(
        start: DateTime(2026, 4, 15, 15),
        title: 'Pre-Match Meal',
        subtitle: '780 kcal · Optimal 3h window',
        type: ScheduleEventType.meal,
        icon: Icons.restaurant_rounded,
      ),
      ScheduleEvent(
        start: DateTime(2026, 4, 15, 16),
        title: 'Conference Finals',
        subtitle: '~2h · Lincoln Courts',
        type: ScheduleEventType.match,
        icon: Icons.sports_tennis_rounded,
      ),
    ],
    _dayKey(DateTime(2026, 4, 14)): [
      ScheduleEvent(
        start: DateTime(2026, 4, 14, 8),
        title: 'Breakfast • Power Oats',
        subtitle: '620 kcal · Logged',
        type: ScheduleEventType.meal,
        icon: Icons.ramen_dining_rounded,
      ),
      ScheduleEvent(
        start: DateTime(2026, 4, 14, 16, 30),
        title: sessionTitle,
        subtitle: '4:30 PM · Eat carbs in 2h',
        type: ScheduleEventType.training,
        icon: Icons.sports_tennis_rounded,
      ),
    ],
    _dayKey(DateTime(2026, 4, 17)): [
      ScheduleEvent(
        start: DateTime(2026, 4, 17, 12),
        title: 'Lunch • Chicken Power Bowl',
        subtitle: '780 kcal · High protein',
        type: ScheduleEventType.meal,
        icon: Icons.restaurant_rounded,
      ),
      ScheduleEvent(
        start: DateTime(2026, 4, 17, 17),
        title: 'Match Practice',
        subtitle: '90 min · Rally drills',
        type: ScheduleEventType.training,
        icon: Icons.sports_tennis_rounded,
      ),
    ],
    _dayKey(DateTime(2026, 4, 19)): [
      ScheduleEvent(
        start: DateTime(2026, 4, 19, 9),
        title: 'Recovery Stretch',
        subtitle: '20 min · Post-match',
        type: ScheduleEventType.training,
        icon: Icons.self_improvement_rounded,
      ),
    ],
  };

  static DateTime _dayKey(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static List<ScheduleEvent> eventsFor(DateTime date) {
    return _eventsByDay[_dayKey(date)] ?? [];
  }

  static bool hasEventsOn(DateTime date) => eventsFor(date).isNotEmpty;

  static MatchDayInfo? matchFor(DateTime date) {
    if (_dayKey(date) == _dayKey(matchDay.date)) {
      return matchDay;
    }
    return null;
  }

  static String formatShortDate(DateTime date) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  static String formatDayLabel(DateTime date) {
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return days[date.weekday - 1];
  }

  static String formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    if (minute == 0) {
      return '$displayHour:00 $period';
    }
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  static String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    if (minute == 0) {
      return '$displayHour:00 $period';
    }
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }
}
