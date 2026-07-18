import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nutrilens/models/meal_analysis_result.dart';
import 'package:nutrilens/services/meal_analysis_client.dart';
import 'package:nutrilens/services/openai_meal_analysis_client.dart';

void main() {
  group('MealAnalysisResult', () {
    test('fromJson maps OpenAI nutrition fields', () {
      final result = MealAnalysisResult.fromJson({
        'mealName': 'Grilled chicken bowl',
        'caloriesKcal': 540,
        'proteinG': 42,
        'carbsG': 38,
        'fatsG': 18,
      });

      expect(result.name, 'Grilled chicken bowl');
      expect(result.nutrition.caloriesKcal, 540);
      expect(result.nutrition.proteinG, 42);
      expect(result.nutrition.carbsG, 38);
      expect(result.nutrition.fatsG, 18);
    });
  });

  group('OpenAiMealAnalysisClient', () {
    test('throws when API key is missing', () async {
      final client = OpenAiMealAnalysisClient(apiKey: '');

      expect(
        () => client.analyzeMealPhoto(
          imageBytes: const [1, 2, 3],
          mimeType: 'image/jpeg',
        ),
        throwsA(
          isA<MealAnalysisException>().having(
            (error) => error.message,
            'message',
            contains('OPENAI_API_KEY'),
          ),
        ),
      );
    });

    test('parses a successful OpenAI vision response', () async {
      Map<String, dynamic>? requestBody;

      final client = OpenAiMealAnalysisClient(
        apiKey: 'test_key',
        httpClient: MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.toString(), 'https://api.openai.com/v1/chat/completions');
          expect(request.headers['Authorization'], 'Bearer test_key');

          requestBody = jsonDecode(request.body) as Map<String, dynamic>;
          expect(requestBody!['model'], 'gpt-4o-mini');
          expect(requestBody!['response_format'], {'type': 'json_object'});

          return http.Response(
            jsonEncode({
              'choices': [
                {
                  'message': {
                    'content': jsonEncode({
                      'mealName': 'Avocado toast',
                      'caloriesKcal': 320,
                      'proteinG': 12,
                      'carbsG': 28,
                      'fatsG': 18,
                    }),
                  },
                },
              ],
            }),
            200,
          );
        }),
      );

      final result = await client.analyzeMealPhoto(
        imageBytes: const [9, 8, 7],
        mimeType: 'image/jpeg',
      );

      expect(result.name, 'Avocado toast');
      expect(result.nutrition.caloriesKcal, 320);
      expect(result.nutrition.proteinG, 12);
      expect(result.nutrition.carbsG, 28);
      expect(result.nutrition.fatsG, 18);

      final messages = requestBody!['messages'] as List;
      final userContent = (messages.last as Map)['content'] as List;
      expect(userContent.first['type'], 'text');
      expect(userContent.last['type'], 'image_url');
      expect(
        userContent.last['image_url']['url'],
        startsWith('data:image/jpeg;base64,'),
      );
    });
  });
}
