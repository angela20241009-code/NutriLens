import 'package:nutrilens/models/reminder_kind.dart';

class StoredNotification {
  const StoredNotification({
    required this.id,
    required this.uid,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.sourceKey,
    this.kind,
    this.read = false,
  });

  final String id;
  final String uid;
  final String title;
  final String body;
  final DateTime createdAt;
  final String sourceKey;
  final ReminderKind? kind;
  final bool read;

  StoredNotification copyWith({
    bool? read,
  }) {
    return StoredNotification(
      id: id,
      uid: uid,
      title: title,
      body: body,
      createdAt: createdAt,
      sourceKey: sourceKey,
      kind: kind,
      read: read ?? this.read,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'title': title,
      'body': body,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'sourceKey': sourceKey,
      'kind': kind?.payload,
      'read': read,
    };
  }

  factory StoredNotification.fromMap(Map<String, dynamic> map) {
    return StoredNotification(
      id: map['id'] as String? ?? map['sourceKey'] as String? ?? '',
      uid: map['uid'] as String? ?? '',
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      createdAt: _parseDate(map['createdAt']),
      sourceKey: map['sourceKey'] as String? ?? map['id'] as String? ?? '',
      kind: ReminderKind.fromPayload(map['kind'] as String?),
      read: map['read'] as bool? ?? false,
    );
  }

  static DateTime _parseDate(Object? value) {
    if (value is DateTime) {
      return value.toUtc();
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.parse(value).toUtc();
    }
    return DateTime.now().toUtc();
  }
}
