import 'package:nutrilens/models/models.dart';

abstract class MealPlanClient {
  Future<MealPlanWeek> fetchWeeklyPlan({
    required UserProfile profile,
    required DateTime startDate,
  });

  Future<MealPlanMeal> regenerateMeal({
    required UserProfile profile,
    required DateTime date,
    required MealSlot slot,
  });
}
