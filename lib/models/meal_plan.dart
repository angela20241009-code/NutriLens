import 'package:nutrilens/models/nutrition_entry.dart';

enum MealSlot {
  breakfast('Breakfast'),
  lunch('Lunch'),
  dinner('Dinner');

  const MealSlot(this.label);

  final String label;

  static MealSlot fromSection(String section) {
    return MealSlot.values.firstWhere(
      (slot) => slot.label.toLowerCase() == section.toLowerCase(),
      orElse: () => MealSlot.breakfast,
    );
  }
}

class MealPlanRecipe {
  const MealPlanRecipe({
    required this.recipeId,
    required this.title,
    required this.imageUrl,
    required this.sourceName,
    required this.sourceUrl,
    required this.calories,
    required this.nutrition,
  });

  final String recipeId;
  final String title;
  final String? imageUrl;
  final String sourceName;
  final String sourceUrl;
  final double calories;
  final NutritionEntry nutrition;
}

class MealPlanMeal {
  const MealPlanMeal({
    required this.slot,
    required this.timeLabel,
    required this.badgeLabel,
    required this.recipe,
  });

  final MealSlot slot;
  final String timeLabel;
  final String badgeLabel;
  final MealPlanRecipe recipe;
}

class MealPlanDay {
  const MealPlanDay({
    required this.date,
    required this.meals,
  });

  final DateTime date;
  final List<MealPlanMeal> meals;

  NutritionEntry get totals {
    return meals.fold(
      const NutritionEntry(),
      (sum, meal) => sum + meal.recipe.nutrition,
    );
  }
}

class MealPlanWeek {
  const MealPlanWeek({
    required this.generatedAt,
    required this.days,
  });

  final DateTime generatedAt;
  final List<MealPlanDay> days;
}
