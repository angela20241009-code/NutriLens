import 'package:nutrilens/models/models.dart';

class WeeklySleepDay {
  const WeeklySleepDay({
    required this.date,
    required this.dateKey,
    required this.sleepHours,
    required this.isToday,
  });

  final DateTime date;
  final String dateKey;
  final double sleepHours;
  final bool isToday;
}

class WeeklyFuelDay {
  const WeeklyFuelDay({
    required this.date,
    required this.dateKey,
    required this.totals,
    required this.isToday,
  });

  final DateTime date;
  final String dateKey;
  final NutritionEntry totals;
  final bool isToday;

  bool get hasLoggedMeals => totals.caloriesKcal > 0;
}

class HomeDashboardData {
  const HomeDashboardData({
    required this.profile,
    required this.summary,
    required this.loggedMeals,
    required this.plannedMeals,
    this.mealPlanError,
    this.weeklySleepDays = const [],
  });

  final UserProfile profile;
  final DailySummary summary;
  final List<Meal> loggedMeals;
  final List<HomeMealPlanItem> plannedMeals;
  final String? mealPlanError;
  final List<WeeklySleepDay> weeklySleepDays;
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
