import 'package:nutrilens/models/reminder_kind.dart';

class InAppNotification {
  const InAppNotification({
    required this.kind,
    required this.title,
    required this.body,
    required this.actionLabel,
    this.sourceKey,
    this.storedId,
  });

  final ReminderKind kind;
  final String title;
  final String body;
  final String actionLabel;
  final String? sourceKey;
  final String? storedId;

  InAppNotification copyWith({
    String? sourceKey,
    String? storedId,
  }) {
    return InAppNotification(
      kind: kind,
      title: title,
      body: body,
      actionLabel: actionLabel,
      sourceKey: sourceKey ?? this.sourceKey,
      storedId: storedId ?? this.storedId,
    );
  }
}
