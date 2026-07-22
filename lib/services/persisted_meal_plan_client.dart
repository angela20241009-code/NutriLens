import 'package:flutter/material.dart';
import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/services/meal_plan_client.dart';
import 'package:nutrilens/services/meal_plan_serializer.dart';
import 'package:nutrilens/services/user_repository.dart';

/// Loads meal plans from persistent storage and only calls the delegate
/// when the cached week is missing or expired.
class PersistedMealPlanClient implements MealPlanClient {
  PersistedMealPlanClient({
    required MealPlanClient delegate,
    required UserRepository repository,
  }) : _delegate = delegate,
       _repository = repository;

  final MealPlanClient _delegate;
  final UserRepository _repository;

  @override
  Future<MealPlanWeek> fetchWeeklyPlan({
    required String uid,
    required UserProfile profile,
    required DateTime startDate,
    bool forceRefresh = false,
  }) async {
    final today = DateUtils.dateOnly(DateTime.now());

    if (!forceRefresh) {
      final cached = await _repository.getMealPlanWeek(uid);
      if (cached != null && cached.isActiveOn(today)) {
        return cached;
      }
    }

    final fresh = await _delegate.fetchWeeklyPlan(
      uid: uid,
      profile: profile,
      startDate: today,
      forceRefresh: true,
    );
    await _repository.saveMealPlanWeek(uid, fresh);
    return fresh;
  }

  @override
  Future<MealPlanMeal> regenerateMeal({
    required String uid,
    required UserProfile profile,
    required DateTime date,
    required MealSlot slot,
  }) async {
    final regenerated = await _delegate.regenerateMeal(
      uid: uid,
      profile: profile,
      date: date,
      slot: slot,
    );

    final cached = await _repository.getMealPlanWeek(uid);
    if (cached == null) {
      return regenerated;
    }

    final targetDate = DateUtils.dateOnly(date);
    final updatedDays = cached.days.map((day) {
      if (!DateUtils.isSameDay(day.date, targetDate)) {
        return day;
      }

      final meals = day.meals
          .map((meal) => meal.slot == slot ? regenerated : meal)
          .toList(growable: false);
      return MealPlanDay(date: day.date, meals: meals);
    }).toList(growable: false);

    await _repository.saveMealPlanWeek(
      uid,
      MealPlanWeek(generatedAt: DateTime.now().toUtc(), days: updatedDays),
    );
    return regenerated;
  }
}
