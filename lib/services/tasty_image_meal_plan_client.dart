import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/models/tasty_recipe.dart';
import 'package:nutrilens/services/meal_plan_client.dart';
import 'package:nutrilens/services/tasty_recipe_client.dart';

/// Adds Tasty recipe matches to generated meal plans.
class TastyImageMealPlanClient implements MealPlanClient {
  TastyImageMealPlanClient({
    required MealPlanClient delegate,
    required TastyRecipeClient tastyClient,
  }) : _delegate = delegate,
       _tastyClient = tastyClient;

  final MealPlanClient _delegate;
  final TastyRecipeClient _tastyClient;
  final Map<String, TastyRecipe?> _recipeCache = {};

  @override
  Future<MealPlanWeek> fetchWeeklyPlan({
    required String uid,
    required UserProfile profile,
    required DateTime startDate,
    bool forceRefresh = false,
  }) async {
    final plan = await _delegate.fetchWeeklyPlan(
      uid: uid,
      profile: profile,
      startDate: startDate,
      forceRefresh: forceRefresh,
    );
    final result = await enrichWeeklyPlan(plan);
    return result.week;
  }

  @override
  Future<MealPlanMeal> regenerateMeal({
    required String uid,
    required UserProfile profile,
    required DateTime date,
    required MealSlot slot,
  }) async {
    final meal = await _delegate.regenerateMeal(
      uid: uid,
      profile: profile,
      date: date,
      slot: slot,
    );
    return _enrichMeal(meal);
  }

  Future<({MealPlanWeek week, bool changed})> enrichWeeklyPlan(
    MealPlanWeek week,
  ) async {
    var changed = false;
    final days = await Future.wait(
      week.days.map((day) async {
        final meals = await Future.wait(
          day.meals.map((meal) async {
            final enriched = await _enrichMeal(meal);
            if (enriched != meal) {
              changed = true;
            }
            return enriched;
          }),
        );
        return MealPlanDay(date: day.date, meals: meals);
      }),
    );

    return (
      week: MealPlanWeek(generatedAt: week.generatedAt, days: days),
      changed: changed,
    );
  }

  Future<MealPlanMeal> _enrichMeal(MealPlanMeal meal) async {
    if (_recipeHasTastyMatch(meal.recipe)) {
      return meal;
    }

    final tastyRecipe = await _lookupRecipe(meal.recipe.title);
    if (tastyRecipe == null) {
      return meal;
    }

    return MealPlanMeal(
      slot: meal.slot,
      timeLabel: meal.timeLabel,
      badgeLabel: meal.badgeLabel,
      recipe: meal.recipe.copyWith(
        recipeId: '${tastyRecipe.id}',
        imageUrl: tastyRecipe.thumbnailUrl,
        sourceName: 'Tasty',
        sourceUrl: _tastyRecipeUrl(tastyRecipe),
      ),
    );
  }

  Future<TastyRecipe?> _lookupRecipe(String title) async {
    final key = title.trim().toLowerCase();
    if (key.isEmpty) {
      return null;
    }
    if (_recipeCache.containsKey(key)) {
      return _recipeCache[key];
    }

    try {
      final result = await _tastyClient.searchRecipes(query: title, size: 1);
      final recipe = result.recipes.isEmpty ? null : result.recipes.first;
      _recipeCache[key] = recipe;
      return recipe;
    } catch (_) {
      _recipeCache[key] = null;
      return null;
    }
  }

  static bool _recipeHasTastyMatch(MealPlanRecipe recipe) {
    return recipe.sourceName == 'Tasty' &&
        recipe.imageUrl != null &&
        recipe.imageUrl!.isNotEmpty;
  }

  static String _tastyRecipeUrl(TastyRecipe recipe) {
    final slug = recipe.slug?.trim();
    if (slug != null && slug.isNotEmpty) {
      return 'https://tasty.co/recipe/$slug';
    }
    return 'https://tasty.co/recipe/${recipe.id}';
  }
}

/// Looks up Tasty thumbnails for meals that do not already have them.
Future<({MealPlanWeek week, bool changed})> enrichMealPlanWeekWithTastyImages({
  required MealPlanWeek week,
  required TastyRecipeClient tastyClient,
}) {
  return TastyImageMealPlanClient(
    delegate: _EnrichmentOnlyMealPlanClient(),
    tastyClient: tastyClient,
  ).enrichWeeklyPlan(week);
}

class _EnrichmentOnlyMealPlanClient implements MealPlanClient {
  @override
  Future<MealPlanWeek> fetchWeeklyPlan({
    required String uid,
    required UserProfile profile,
    required DateTime startDate,
    bool forceRefresh = false,
  }) {
    throw UnsupportedError('Enrichment-only client cannot fetch meal plans.');
  }

  @override
  Future<MealPlanMeal> regenerateMeal({
    required String uid,
    required UserProfile profile,
    required DateTime date,
    required MealSlot slot,
  }) {
    throw UnsupportedError('Enrichment-only client cannot regenerate meals.');
  }
}
