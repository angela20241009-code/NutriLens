import 'package:nutrilens/models/models.dart';

abstract class MealPlanClient {
  Future<MealPlanWeek> fetchWeeklyPlan({
    required String uid,
    required UserProfile profile,
    required DateTime startDate,
    bool forceRefresh = false,
  });

  Future<MealPlanMeal> regenerateMeal({
    required String uid,
    required UserProfile profile,
    required DateTime date,
    required MealSlot slot,
  });
}
