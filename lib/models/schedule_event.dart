import 'package:flutter/material.dart';
import 'package:nutrilens/models/firestore_map.dart';

enum ScheduleEventType { meal, training, match }

extension ScheduleEventTypeFirestore on ScheduleEventType {
  String get firestoreValue {
    switch (this) {
      case ScheduleEventType.meal:
        return 'meal';
      case ScheduleEventType.training:
        return 'training';
      case ScheduleEventType.match:
        return 'match';
    }
  }

  static ScheduleEventType fromFirestore(String? value) {
    return ScheduleEventType.values.firstWhere(
      (type) => type.firestoreValue == value,
      orElse: () => ScheduleEventType.training,
    );
  }
}

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
  const FuelingHint({required this.timing, required this.label});

  final String timing;
  final String label;

  factory FuelingHint.fromMap(Map<String, dynamic> map) {
    return FuelingHint(
      timing: map['timing'] as String? ?? '',
      label: map['label'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {'timing': timing, 'label': label};
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

class UserScheduleEvent {
  const UserScheduleEvent({
    required this.eventId,
    required this.type,
    required this.startAt,
    required this.title,
    this.subtitle,
    this.location,
    this.badge,
    this.fuelingHints = const [],
  });

  final String eventId;
  final ScheduleEventType type;
  final DateTime startAt;
  final String title;
  final String? subtitle;
  final String? location;
  final String? badge;
  final List<FuelingHint> fuelingHints;

  factory UserScheduleEvent.fromMap(Map<String, dynamic> map) {
    return UserScheduleEvent(
      eventId: map['eventId'] as String? ?? '',
      type: ScheduleEventTypeFirestore.fromFirestore(map['type'] as String?),
      startAt: parseRequiredDateTime(map['startAt']),
      title: map['title'] as String? ?? '',
      subtitle: map['subtitle'] as String?,
      location: map['location'] as String?,
      badge: map['badge'] as String?,
      fuelingHints: (map['fuelingHints'] as List? ?? const [])
          .whereType<Map>()
          .map((hint) => FuelingHint.fromMap(Map<String, dynamic>.from(hint)))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
    'eventId': eventId,
    'type': type.firestoreValue,
    'startAt': startAt.toUtc().toIso8601String(),
    'title': title,
    'subtitle': subtitle,
    'location': location,
    'badge': badge,
    'fuelingHints': fuelingHints.map((hint) => hint.toMap()).toList(),
  };
}
