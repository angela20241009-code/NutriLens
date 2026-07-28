import 'package:flutter_test/flutter_test.dart';
import 'package:nutrilens/models/meal_plan.dart';
import 'package:nutrilens/models/nutrition_entry.dart';
import 'package:nutrilens/models/tasty_recipe.dart';
import 'package:nutrilens/models/user_profile.dart';
import 'package:nutrilens/services/in_memory_user_repository.dart';
import 'package:nutrilens/services/meal_plan_client.dart';
import 'package:nutrilens/services/meal_plan_serializer.dart';
import 'package:nutrilens/services/persisted_meal_plan_client.dart';
import 'package:nutrilens/services/tasty_image_meal_plan_client.dart';
import 'package:nutrilens/services/tasty_recipe_client.dart';

void main() {
  group('TastyImageMealPlanClient', () {
    test('enrichWeeklyPlan matches every meal to Tasty and stores metadata', () async {
      final client = TastyImageMealPlanClient(
        delegate: _StubMealPlanClient(),
        tastyClient: _FakeTastyClient(),
      );

      final week = _sampleWeek(DateTime(2026, 7, 27));
      final result = await client.enrichWeeklyPlan(week);

      expect(result.changed, isTrue);
      expect(result.week.days, hasLength(7));
      for (final day in result.week.days) {
        for (final meal in day.meals) {
          expect(meal.recipe.sourceName, 'Tasty');
          expect(meal.recipe.imageUrl, isNotEmpty);
          expect(meal.recipe.recipeId, '42');
          expect(meal.recipe.sourceUrl, contains('tasty.co'));
        }
      }
    });
  });

  group('PersistedMealPlanClient with Tasty enrichment', () {
    test('re-enriches cached plan and saves Tasty matches to storage', () async {
      final repository = InMemoryUserRepository();
      final tastyClient = TastyImageMealPlanClient(
        delegate: _StubMealPlanClient(),
        tastyClient: _FakeTastyClient(),
      );
      final client = PersistedMealPlanClient(
        delegate: tastyClient,
        repository: repository,
      );

      const uid = 'uid_test';
      final today = DateTime(2026, 7, 27);
      final profile = UserProfile.demoAngela(userId: uid, now: today);
      await repository.saveMealPlanWeek(uid, _sampleWeek(today));

      final plan = await client.fetchWeeklyPlan(
        uid: uid,
        profile: profile,
        startDate: today,
      );

      expect(plan.mealsFor(today), isNotEmpty);
      expect(plan.mealsFor(today).first.recipe.sourceName, 'Tasty');

      final stored = await repository.getMealPlanWeek(uid);
      expect(stored?.mealsFor(today).first.recipe.imageUrl, isNotEmpty);
    });

    test('mealsFor returns only the requested day', () {
      final week = _sampleWeek(DateTime(2026, 7, 27));

      expect(week.mealsFor(DateTime(2026, 7, 27)), hasLength(1));
      expect(week.mealsFor(DateTime(2026, 7, 28)), hasLength(1));
      expect(week.mealsFor(DateTime(2026, 8, 3)), isEmpty);
    });
  });
}

class _StubMealPlanClient implements MealPlanClient {
  @override
  Future<MealPlanWeek> fetchWeeklyPlan({
    required String uid,
    required UserProfile profile,
    required DateTime startDate,
    bool forceRefresh = false,
  }) async {
    return _sampleWeek(startDate);
  }

  @override
  Future<MealPlanMeal> regenerateMeal({
    required String uid,
    required UserProfile profile,
    required DateTime date,
    required MealSlot slot,
  }) async {
    throw UnimplementedError();
  }
}

class _FakeTastyClient implements TastyRecipeClient {
  @override
  Future<TastyRecipeDetail> fetchRecipeDetail(int recipeId) async {
    throw UnimplementedError();
  }

  @override
  Future<TastyRecipeSearchResult> searchRecipes({
    String query = '',
    int from = 0,
    int size = 20,
  }) async {
    return TastyRecipeSearchResult(
      recipes: [
        TastyRecipe(
          id: 42,
          name: query,
          thumbnailUrl: 'https://example.com/$query.jpg',
          slug: 'test-recipe',
        ),
      ],
      totalCount: 1,
    );
  }
}

MealPlanWeek _sampleWeek(DateTime startDate) {
  final start = DateTime(startDate.year, startDate.month, startDate.day);
  return MealPlanWeek(
    generatedAt: DateTime.utc(start.year, start.month, start.day),
    days: List.generate(
      7,
      (index) => MealPlanDay(
        date: start.add(Duration(days: index)),
        meals: [
          MealPlanMeal(
            slot: MealSlot.breakfast,
            timeLabel: '8:00 AM',
            badgeLabel: 'BREAKFAST',
            recipe: MealPlanRecipe(
              recipeId: 'planned',
              title: 'Day ${index + 1} Breakfast',
              imageUrl: null,
              sourceName: 'NutriLens',
              sourceUrl: '',
              calories: 400,
              nutrition: const NutritionEntry(
                caloriesKcal: 400,
                proteinG: 20,
                carbsG: 40,
                fatsG: 10,
              ),
            ),
          ),
        ],
      ),
      growable: false,
    ),
  );
}
