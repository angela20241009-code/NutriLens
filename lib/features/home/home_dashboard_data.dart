import 'package:nutrilens/models/models.dart';

class HomeDashboardData {
  const HomeDashboardData({
    required this.profile,
    required this.summary,
    required this.loggedMeals,
    required this.plannedMeals,
    this.mealPlanError,
  });

  final UserProfile profile;
  final DailySummary summary;
  final List<Meal> loggedMeals;
  final List<HomeMealPlanItem> plannedMeals;
  final String? mealPlanError;
}

class HomeMealPlanItem {
  const HomeMealPlanItem({
    required this.mealType,
    required this.name,
    required this.calories,
    required this.protein,
    required this.imageUrl,
    required this.logged,
  });

  final String mealType;
  final String name;
  final int calories;
  final int protein;
  final String? imageUrl;
  final bool logged;

  factory HomeMealPlanItem.fromMealPlanMeal({
    required MealPlanMeal meal,
    required List<Meal> loggedMeals,
  }) {
    final recipe = meal.recipe;
    return HomeMealPlanItem(
      mealType: meal.slot.label.toUpperCase(),
      name: recipe.title,
      calories: recipe.nutrition.caloriesKcal,
      protein: recipe.nutrition.proteinG,
      imageUrl: recipe.imageUrl,
      logged: loggedMeals.any(
        (loggedMeal) => _normalize(loggedMeal.name) == _normalize(recipe.title),
      ),
    );
  }

  static String _normalize(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }
}
