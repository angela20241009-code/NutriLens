import 'package:nutrilens/models/models.dart';

abstract class MealPlanClient {
  Future<MealPlanWeek> fetchWeeklyPlan({
    required UserProfile profile,
    required DateTime startDate,
  });
}
