import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/services/openai_hydration_target_client.dart';

void main() {
  group('OpenAiHydrationTargetClient', () {
    test('fetchDailyTargetLiters maps OpenAI JSON into liters', () async {
      final client = OpenAiHydrationTargetClient(
        apiKey: 'test-key',
        httpClient: MockClient((request) async {
          return http.Response(
            '''
{
  "choices": [
    {
      "message": {
        "content": "{\\"hydrationLiters\\":4.2}"
      }
    }
  ]
}
''',
            200,
          );
        }),
      );

      final profile = UserProfile.demoAngela(
        userId: 'uid_123',
        now: DateTime(2026, 7, 22),
      );

      final liters = await client.fetchDailyTargetLiters(profile);

      expect(liters, 4.2);
    });

    test('fetchDailyTargetLiters falls back when API key is missing', () async {
      final client = OpenAiHydrationTargetClient(apiKey: '');
      final profile = UserProfile.demoAngela(
        userId: 'uid_123',
        now: DateTime(2026, 7, 22),
      );

      final liters = await client.fetchDailyTargetLiters(profile);

      expect(liters, profile.dailyTargets.hydrationLiters);
    });

    test('fetchDailyTargetLiters falls back when OpenAI request fails', () async {
      final client = OpenAiHydrationTargetClient(
        apiKey: 'test-key',
        httpClient: MockClient((request) async {
          return http.Response('error', 500);
        }),
      );
      final profile = UserProfile.demoAngela(
        userId: 'uid_123',
        now: DateTime(2026, 7, 22),
      );

      final liters = await client.fetchDailyTargetLiters(profile);

      expect(liters, profile.dailyTargets.hydrationLiters);
    });
  });
}
