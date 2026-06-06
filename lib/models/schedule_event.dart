import 'package:flutter/material.dart';

enum ScheduleEventType { meal, training, match }

class ScheduleEvent {
  const ScheduleEvent({
    required this.start,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.icon,
  });

  final DateTime start;
  final String title;
  final String subtitle;
  final ScheduleEventType type;
  final IconData icon;
}

class FuelingHint {
  const FuelingHint({
    required this.timing,
    required this.label,
  });

  final String timing;
  final String label;
}

class MatchDayInfo {
  const MatchDayInfo({
    required this.date,
    required this.badge,
    required this.matchup,
    required this.location,
    required this.time,
    required this.fuelingHints,
  });

  final DateTime date;
  final String badge;
  final String matchup;
  final String location;
  final TimeOfDay time;
  final List<FuelingHint> fuelingHints;
}
