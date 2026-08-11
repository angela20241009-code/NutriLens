import 'package:nutrilens/models/reminder_kind.dart';
import 'package:nutrilens/models/stored_notification.dart';
import 'package:nutrilens/services/user_repository.dart';

abstract final class NotificationInboxService {
  static const retention = Duration(days: 7);

  static Future<StoredNotification?> record({
    required UserRepository repository,
    required String uid,
    required String title,
    required String body,
    required String sourceKey,
    ReminderKind? kind,
    DateTime? createdAt,
  }) async {
    await repository.pruneNotifications(uid, maxAge: retention);

    final notification = StoredNotification(
      id: _notificationIdFor(sourceKey),
      uid: uid,
      title: title,
      body: body,
      createdAt: createdAt ?? DateTime.now().toUtc(),
      sourceKey: sourceKey,
      kind: kind,
    );
    return repository.saveNotification(notification);
  }

  static Future<void> markRead({
    required UserRepository repository,
    required String uid,
    required String notificationId,
  }) {
    return repository.markNotificationRead(uid, notificationId);
  }

  static String sourceKeyForReminder({
    required ReminderKind kind,
    required String dateKey,
    int? mealIndex,
    int? notificationId,
  }) {
    if (notificationId != null) {
      return 'push_${notificationId}_$dateKey';
    }
    return '${kind.name}_${mealIndex ?? 'none'}_$dateKey';
  }

  static String _notificationIdFor(String sourceKey) {
    return sourceKey.replaceAll('/', '_');
  }
}
