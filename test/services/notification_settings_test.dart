import 'package:flutter_test/flutter_test.dart';
import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/services/notification_scheduler.dart';
import 'package:nutrilens/services/openai_sleep_target_client.dart';

void main() {
  final now = DateTime.utc(2026, 8, 1, 12);

  test('NotificationSettings round-trips through map', () {
    const settings = NotificationSettings(
      mealRemindersEnabled: true,
      bedtimeReminderEnabled: true,
      wakeReminderEnabled: false,
      bedtimeReminderLeadMinutes: 45,
    );

    final restored = NotificationSettings.fromMap(settings.toMap());

    expect(restored.mealRemindersEnabled, true);
    expect(restored.bedtimeReminderEnabled, true);
    expect(restored.wakeReminderEnabled, false);
    expect(restored.bedtimeReminderLeadMinutes, 45);
  });

  test('UserProfile round-trips notification settings', () {
    final profile = UserProfile.demoAngela(userId: 'abc123', now: now).copyWith(
      notificationSettings: const NotificationSettings(
        mealRemindersEnabled: false,
        bedtimeReminderEnabled: true,
        wakeReminderEnabled: true,
      ),
    );

    final restored = UserProfile.fromMap(profile.toMap(), userId: 'abc123');

    expect(restored.notificationSettings.mealRemindersEnabled, false);
    expect(restored.notificationSettings.bedtimeReminderEnabled, true);
    expect(restored.notificationSettings.wakeReminderEnabled, true);
  });

  test('NotificationScheduler distributes meal reminders across the day', () {
    final profile = UserProfile.demoAngela(userId: 'abc123', now: now).copyWith(
      usualWakeTimeMinutes: 7 * 60,
      usualBedtimeMinutes: 22 * 60,
      nutritionSettings: const NutritionSettings(mealsPerDay: 3),
    );

    final minutes = NotificationScheduler.mealReminderMinutes(profile);

    expect(minutes, hasLength(3));
    expect(minutes.first, greaterThan(7 * 60));
    expect(minutes.last, lessThan(22 * 60));
  });

  test('OpenAiSleepTargetClient falls back without API key', () async {
    final profile = UserProfile.demoAngela(userId: 'abc123', now: now);
    final client = OpenAiSleepTargetClient(apiKey: '');

    final target = await client.fetchDailyTargetHours(
      profile,
      recentSleep: const [],
    );

    expect(target, profile.dailyTargets.sleepHours);
  });

  test('OpenAiSleepTargetClient uses recent sleep average in fallback', () async {
    final base = UserProfile.demoAngela(userId: 'abc123', now: now);
    final profile = base.copyWith(
      dailyTargets: base.dailyTargets.copyWith(sleepHours: 8),
    );
    final client = OpenAiSleepTargetClient(apiKey: '');

    final target = await client.fetchDailyTargetHours(
      profile,
      recentSleep: [
        DailySummary(
          uid: 'abc123',
          dateKey: '2026-07-30',
          sleepHours: 6.5,
          updatedAt: now,
        ),
        DailySummary(
          uid: 'abc123',
          dateKey: '2026-07-31',
          sleepHours: 7,
          updatedAt: now,
        ),
      ],
    );

    expect(target, greaterThanOrEqualTo(6.5));
    expect(target, lessThanOrEqualTo(10));
  });
}
