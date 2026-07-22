import 'package:flutter_test/flutter_test.dart';
import 'package:nutrilens/features/sleep/sleep_logging.dart';
import 'package:nutrilens/models/models.dart';

void main() {
  test('sleepDurationMinutes handles overnight sleep correctly', () {
    final minutes = sleepDurationMinutes(
      bedtimeMinutes: 22 * 60 + 30,
      wakeTimeMinutes: 6 * 60 + 45,
    );

    expect(minutes, 495);
    expect(formatSleepHours(minutes / 60), '8h 15m');
  });

  test('shouldPromptSleepCheckIn is false when sleep mode is disabled', () {
    final profile = UserProfile.demoAngela(
      userId: 'abc',
      now: DateTime.utc(2026, 6, 16, 12),
    );

    expect(
      shouldPromptSleepCheckIn(profile: profile, todaySummary: null),
      isFalse,
    );
  });

  test('shouldPromptSleepCheckIn is false after sleep is logged today', () {
    final profile = UserProfile.demoAngela(
      userId: 'abc',
      now: DateTime.utc(2026, 6, 16, 12),
    ).copyWith(sleepModeEnabled: true);
    final summary = DailySummary(
      uid: 'abc',
      dateKey: '2026-06-16',
      sleepHours: 7.5,
      updatedAt: DateTime.utc(2026, 6, 16, 12),
    );

    expect(
      shouldPromptSleepCheckIn(profile: profile, todaySummary: summary),
      isFalse,
    );
  });

  test('shouldPromptSleepCheckIn is true when sleep mode is on and not logged', () {
    final profile = UserProfile.demoAngela(
      userId: 'abc',
      now: DateTime.utc(2026, 6, 16, 12),
    ).copyWith(sleepModeEnabled: true);

    expect(
      shouldPromptSleepCheckIn(profile: profile, todaySummary: null),
      isTrue,
    );
  });

  test('buildSleepAdvice reports deficit when below target', () {
    final now = DateTime.utc(2026, 6, 16, 12);
    final profile = UserProfile.demoAngela(
      userId: 'abc',
      now: now,
    ).copyWith(usualWakeTimeMinutes: 7 * 60);

    final advice = buildSleepAdvice(
      profile: profile,
      sleepHours: 6,
      wakeTimeMinutes: 7 * 60,
      referenceUtc: now,
    );

    expect(advice.title, 'Sleep needs a boost');
    expect(advice.shortLine, contains('under your 8.0h target'));
  });

  test('buildSleepAdvice reports on target near sleep goal', () {
    final now = DateTime.utc(2026, 6, 16, 12);
    final profile = UserProfile.demoAngela(
      userId: 'abc',
      now: now,
    ).copyWith(usualWakeTimeMinutes: 7 * 60);

    final advice = buildSleepAdvice(
      profile: profile,
      sleepHours: 8,
      wakeTimeMinutes: 7 * 60,
      referenceUtc: now,
    );

    expect(advice.title, 'On target');
    expect(advice.shortLine, contains('matching your 8.0h goal'));
  });
}
