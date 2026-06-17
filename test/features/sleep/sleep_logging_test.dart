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
