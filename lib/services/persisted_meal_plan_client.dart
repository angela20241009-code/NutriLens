import 'package:flutter/material.dart';
import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/services/meal_plan_client.dart';
import 'package:nutrilens/services/meal_plan_serializer.dart';
import 'package:nutrilens/services/tasty_image_meal_plan_client.dart';
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
        return _ensureStoredWithTastyMatches(uid: uid, week: cached);
      }
    }

    final fresh = await _delegate.fetchWeeklyPlan(
      uid: uid,
      profile: profile,
      startDate: today,
      forceRefresh: true,
    );
    return _ensureStoredWithTastyMatches(
      uid: uid,
      week: fresh,
      persistAlways: true,
    );
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

    final updatedWeek = MealPlanWeek(
      generatedAt: DateTime.now().toUtc(),
      days: updatedDays,
    );
    await _repository.saveMealPlanWeek(
      uid,
      (await _enrichWeek(updatedWeek)).week,
    );
    return regenerated;
  }

  Future<MealPlanWeek> _ensureStoredWithTastyMatches({
    required String uid,
    required MealPlanWeek week,
    bool persistAlways = false,
  }) async {
    final enriched = await _enrichWeek(week);
    if (persistAlways || enriched.changed) {
      await _repository.saveMealPlanWeek(uid, enriched.week);
    }
    return enriched.week;
  }

  Future<({MealPlanWeek week, bool changed})> _enrichWeek(MealPlanWeek week) async {
    final delegate = _delegate;
    if (delegate is TastyImageMealPlanClient) {
      return delegate.enrichWeeklyPlan(week);
    }
    return (week: week, changed: false);
  }
}
