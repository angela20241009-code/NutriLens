import 'package:flutter_test/flutter_test.dart';
import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/models/reminder_kind.dart';
import 'package:nutrilens/services/in_app_reminder_checker.dart';

void main() {
  final now = DateTime.utc(2026, 8, 1, 12);

  test('InAppReminderChecker returns meal reminder at scheduled minute', () {
    final profile = UserProfile.demoAngela(userId: 'abc123', now: now).copyWith(
      usualWakeTimeMinutes: 7 * 60,
      usualBedtimeMinutes: 22 * 60,
      nutritionSettings: const NutritionSettings(mealsPerDay: 3),
      notificationSettings: const NotificationSettings(
        mealRemindersEnabled: true,
      ),
    );

    final allMealMinutes = <int>{};
    for (var minute = 0; minute < 24 * 60; minute++) {
      final due = InAppReminderChecker.dueReminders(
        profile: profile,
        currentMinutesOfDay: minute,
      );
      for (final reminder in due) {
        if (reminder.kind == ReminderKind.meal) {
          allMealMinutes.add(minute);
        }
      }
    }

    expect(allMealMinutes, hasLength(3));

    for (final minute in allMealMinutes) {
      final due = InAppReminderChecker.dueReminders(
        profile: profile,
        currentMinutesOfDay: minute,
      );
      expect(due.any((reminder) => reminder.kind == ReminderKind.meal), isTrue);
    }
  });

  test('InAppReminderChecker returns bedtime and wake reminders when enabled', () {
    final profile = UserProfile.demoAngela(userId: 'abc123', now: now).copyWith(
      usualWakeTimeMinutes: 7 * 60,
      usualBedtimeMinutes: 22 * 60,
      notificationSettings: const NotificationSettings(
        sleepRemindersEnabled: true,
        bedtimeReminderLeadMinutes: 30,
      ),
    );

    final wake = InAppReminderChecker.dueReminders(
      profile: profile,
      currentMinutesOfDay: 7 * 60,
    );
    expect(wake.single.kind, ReminderKind.wake);

    final bedtime = InAppReminderChecker.dueReminders(
      profile: profile,
      currentMinutesOfDay: 21 * 60 + 30,
    );
    expect(bedtime.single.kind, ReminderKind.bedtime);
  });

  test('InAppReminderChecker returns hydration reminders when enabled', () {
    final profile = UserProfile.demoAngela(userId: 'abc123', now: now).copyWith(
      usualWakeTimeMinutes: 8 * 60,
      usualBedtimeMinutes: 22 * 60,
      notificationSettings: const NotificationSettings(
        hydrationRemindersEnabled: true,
        mealRemindersEnabled: false,
        sleepRemindersEnabled: false,
      ),
    );

    final hydrationMinutes = <int>{};
    for (var minute = 0; minute < 24 * 60; minute++) {
      final due = InAppReminderChecker.dueReminders(
        profile: profile,
        currentMinutesOfDay: minute,
      );
      for (final reminder in due) {
        if (reminder.kind == ReminderKind.hydration) {
          hydrationMinutes.add(minute);
        }
      }
    }

    expect(hydrationMinutes, hasLength(3));
  });
}
