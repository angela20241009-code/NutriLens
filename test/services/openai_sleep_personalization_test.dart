import 'package:flutter_test/flutter_test.dart';
import 'package:nutrilens/models/sleep_personalization_result.dart';
import 'package:nutrilens/services/openai_sleep_target_client.dart';

void main() {
  test('OpenAiSleepTargetClient parses personalized sleep plan JSON', () {
    const fallback = SleepPersonalizationResult(
      sleepHours: 8,
      bedtimeMinutes: 1350,
      wakeTimeMinutes: 420,
      summary: 'Fallback summary',
    );

    final parsed = OpenAiSleepTargetClient.parsePersonalizationForTest(
      '{"sleepHours": 8.5, "bedtimeMinutes": 1365, "wakeTimeMinutes": 405, '
      '"summary": "Keep bedtime earlier on school nights."}',
      fallback: fallback,
    );

    expect(parsed.sleepHours, 8.5);
    expect(parsed.bedtimeMinutes, 1365);
    expect(parsed.wakeTimeMinutes, 405);
    expect(parsed.summary, 'Keep bedtime earlier on school nights.');
  });
}
