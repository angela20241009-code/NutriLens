import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/models/meal_plan.dart';
import 'package:nutrilens/services/openai_meal_plan_client.dart';

void main() {
  group('OpenAiMealPlanClient', () {
    test('fetchWeeklyPlan maps OpenAI JSON into seven days', () async {
      final client = OpenAiMealPlanClient(
        apiKey: 'test-key',
        httpClient: MockClient((request) async {
          expect(
            request.url.toString(),
            'https://api.openai.com/v1/chat/completions',
          );

          return http.Response(
            '''
{
  "choices": [
    {
      "message": {
        "content": "{\\"days\\":[{\\"meals\\":[{\\"slot\\":\\"breakfast\\",\\"title\\":\\"Oats Bowl\\",\\"timeLabel\\":\\"8:00 AM\\",\\"calories\\":400,\\"proteinG\\":20,\\"carbsG\\":50,\\"fatsG\\":10},{\\"slot\\":\\"lunch\\",\\"title\\":\\"Chicken Bowl\\",\\"timeLabel\\":\\"12:30 PM\\",\\"calories\\":650,\\"proteinG\\":45,\\"carbsG\\":60,\\"fatsG\\":18},{\\"slot\\":\\"dinner\\",\\"title\\":\\"Salmon Plate\\",\\"timeLabel\\":\\"7:00 PM\\",\\"calories\\":700,\\"proteinG\\":42,\\"carbsG\\":55,\\"fatsG\\":24}]},{\\"meals\\":[{\\"slot\\":\\"breakfast\\",\\"title\\":\\"Day 2 Breakfast\\",\\"timeLabel\\":\\"8:00 AM\\",\\"calories\\":420,\\"proteinG\\":22,\\"carbsG\\":48,\\"fatsG\\":12},{\\"slot\\":\\"lunch\\",\\"title\\":\\"Day 2 Lunch\\",\\"timeLabel\\":\\"12:30 PM\\",\\"calories\\":640,\\"proteinG\\":40,\\"carbsG\\":58,\\"fatsG\\":20},{\\"slot\\":\\"dinner\\",\\"title\\":\\"Day 2 Dinner\\",\\"timeLabel\\":\\"7:00 PM\\",\\"calories\\":690,\\"proteinG\\":38,\\"carbsG\\":52,\\"fatsG\\":22}]},{\\"meals\\":[{\\"slot\\":\\"breakfast\\",\\"title\\":\\"Day 3 Breakfast\\",\\"timeLabel\\":\\"8:00 AM\\",\\"calories\\":420,\\"proteinG\\":22,\\"carbsG\\":48,\\"fatsG\\":12},{\\"slot\\":\\"lunch\\",\\"title\\":\\"Day 3 Lunch\\",\\"timeLabel\\":\\"12:30 PM\\",\\"calories\\":640,\\"proteinG\\":40,\\"carbsG\\":58,\\"fatsG\\":20},{\\"slot\\":\\"dinner\\",\\"title\\":\\"Day 3 Dinner\\",\\"timeLabel\\":\\"7:00 PM\\",\\"calories\\":690,\\"proteinG\\":38,\\"carbsG\\":52,\\"fatsG\\":22}]},{\\"meals\\":[{\\"slot\\":\\"breakfast\\",\\"title\\":\\"Day 4 Breakfast\\",\\"timeLabel\\":\\"8:00 AM\\",\\"calories\\":420,\\"proteinG\\":22,\\"carbsG\\":48,\\"fatsG\\":12},{\\"slot\\":\\"lunch\\",\\"title\\":\\"Day 4 Lunch\\",\\"timeLabel\\":\\"12:30 PM\\",\\"calories\\":640,\\"proteinG\\":40,\\"carbsG\\":58,\\"fatsG\\":20},{\\"slot\\":\\"dinner\\",\\"title\\":\\"Day 4 Dinner\\",\\"timeLabel\\":\\"7:00 PM\\",\\"calories\\":690,\\"proteinG\\":38,\\"carbsG\\":52,\\"fatsG\\":22}]},{\\"meals\\":[{\\"slot\\":\\"breakfast\\",\\"title\\":\\"Day 5 Breakfast\\",\\"timeLabel\\":\\"8:00 AM\\",\\"calories\\":420,\\"proteinG\\":22,\\"carbsG\\":48,\\"fatsG\\":12},{\\"slot\\":\\"lunch\\",\\"title\\":\\"Day 5 Lunch\\",\\"timeLabel\\":\\"12:30 PM\\",\\"calories\\":640,\\"proteinG\\":40,\\"carbsG\\":58,\\"fatsG\\":20},{\\"slot\\":\\"dinner\\",\\"title\\":\\"Day 5 Dinner\\",\\"timeLabel\\":\\"7:00 PM\\",\\"calories\\":690,\\"proteinG\\":38,\\"carbsG\\":52,\\"fatsG\\":22}]},{\\"meals\\":[{\\"slot\\":\\"breakfast\\",\\"title\\":\\"Day 6 Breakfast\\",\\"timeLabel\\":\\"8:00 AM\\",\\"calories\\":420,\\"proteinG\\":22,\\"carbsG\\":48,\\"fatsG\\":12},{\\"slot\\":\\"lunch\\",\\"title\\":\\"Day 6 Lunch\\",\\"timeLabel\\":\\"12:30 PM\\",\\"calories\\":640,\\"proteinG\\":40,\\"carbsG\\":58,\\"fatsG\\":20},{\\"slot\\":\\"dinner\\",\\"title\\":\\"Day 6 Dinner\\",\\"timeLabel\\":\\"7:00 PM\\",\\"calories\\":690,\\"proteinG\\":38,\\"carbsG\\":52,\\"fatsG\\":22}]},{\\"meals\\":[{\\"slot\\":\\"breakfast\\",\\"title\\":\\"Day 7 Breakfast\\",\\"timeLabel\\":\\"8:00 AM\\",\\"calories\\":420,\\"proteinG\\":22,\\"carbsG\\":48,\\"fatsG\\":12},{\\"slot\\":\\"lunch\\",\\"title\\":\\"Day 7 Lunch\\",\\"timeLabel\\":\\"12:30 PM\\",\\"calories\\":640,\\"proteinG\\":40,\\"carbsG\\":58,\\"fatsG\\":20},{\\"slot\\":\\"dinner\\",\\"title\\":\\"Day 7 Dinner\\",\\"timeLabel\\":\\"7:00 PM\\",\\"calories\\":690,\\"proteinG\\":38,\\"carbsG\\":52,\\"fatsG\\":22}]}]}"
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

      final plan = await client.fetchWeeklyPlan(
        profile: profile,
        startDate: DateTime(2026, 7, 22),
      );

      expect(plan.days, hasLength(7));
      expect(plan.days.first.date, DateTime(2026, 7, 22));
      expect(plan.days.first.meals.first.recipe.title, 'Oats Bowl');
      expect(plan.days.first.meals.first.slot, MealSlot.breakfast);
    });

    test('fetchWeeklyPlan throws when API key is missing', () async {
      final client = OpenAiMealPlanClient(apiKey: '');

      await expectLater(
        () => client.fetchWeeklyPlan(
          profile: UserProfile.demoAngela(
            userId: 'uid_123',
            now: DateTime(2026, 7, 22),
          ),
          startDate: DateTime(2026, 7, 22),
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}
