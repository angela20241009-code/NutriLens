import 'package:flutter_test/flutter_test.dart';
import 'package:nutrilens/models/reminder_kind.dart';
import 'package:nutrilens/models/stored_notification.dart';
import 'package:nutrilens/services/in_memory_user_repository.dart';
import 'package:nutrilens/services/notification_inbox_service.dart';

void main() {
  test('NotificationInboxService saves unread notification once per sourceKey', () async {
    final repository = InMemoryUserRepository();
    const uid = 'user_1';

    final first = await NotificationInboxService.record(
      repository: repository,
      uid: uid,
      title: 'Time to fuel up',
      body: 'Log your meal',
      sourceKey: 'meal_0_2026-08-10',
      kind: ReminderKind.meal,
      createdAt: DateTime.utc(2026, 8, 10, 12),
    );
    final second = await NotificationInboxService.record(
      repository: repository,
      uid: uid,
      title: 'Time to fuel up',
      body: 'Log your meal',
      sourceKey: 'meal_0_2026-08-10',
      kind: ReminderKind.meal,
      createdAt: DateTime.utc(2026, 8, 10, 12),
    );

    expect(first, isNotNull);
    expect(second, equals(first));
    expect(first!.read, isFalse);

    final items = await repository.getNotifications(uid);
    expect(items, hasLength(1));
  });

  test('NotificationInboxService prunes notifications older than 7 days', () async {
    final repository = InMemoryUserRepository();
    const uid = 'user_1';

    await repository.saveNotification(
      StoredNotification(
        id: 'old',
        uid: uid,
        title: 'Old',
        body: 'Old body',
        createdAt: DateTime.utc(2026, 8, 1),
        sourceKey: 'old_key',
        kind: ReminderKind.wake,
      ),
    );
    await NotificationInboxService.record(
      repository: repository,
      uid: uid,
      title: 'New',
      body: 'New body',
      sourceKey: 'new_key',
      kind: ReminderKind.meal,
      createdAt: DateTime.utc(2026, 8, 10, 12),
    );

    final items = await repository.getNotifications(uid);
    expect(items, hasLength(1));
    expect(items.single.title, 'New');
  });

  test('markNotificationRead updates unread count', () async {
    final repository = InMemoryUserRepository();
    const uid = 'user_1';

    final saved = await NotificationInboxService.record(
      repository: repository,
      uid: uid,
      title: 'Wake up',
      body: 'Log sleep',
      sourceKey: 'wake_none_2026-08-10',
      kind: ReminderKind.wake,
    );

    expect(await repository.getUnreadNotificationCount(uid), 1);
    await NotificationInboxService.markRead(
      repository: repository,
      uid: uid,
      notificationId: saved!.id,
    );
    expect(await repository.getUnreadNotificationCount(uid), 0);

    final items = await repository.getNotifications(uid);
    expect(items.single.read, isTrue);
  });
}
