import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrilens/models/meal_plan.dart';
import 'package:nutrilens/models/nutrition_entry.dart';
import 'package:nutrilens/models/user_profile.dart';
import 'package:nutrilens/services/in_memory_user_repository.dart';
import 'package:nutrilens/services/meal_plan_client.dart';
import 'package:nutrilens/services/persisted_meal_plan_client.dart';

void main() {
  group('PersistedMealPlanClient', () {
    test('returns cached plan without calling delegate when still active', () async {
      final repository = InMemoryUserRepository();
      final delegate = _RecordingMealPlanClient();
      final client = PersistedMealPlanClient(
        delegate: delegate,
        repository: repository,
      );

      const uid = 'uid_test';
      final profile = UserProfile.demoAngela(
        userId: uid,
        now: DateTime(2026, 7, 22),
      );
      final today = DateUtils.dateOnly(DateTime(2026, 7, 22));
      final cachedWeek = _sampleWeek(today);

      await repository.saveMealPlanWeek(uid, cachedWeek);

      final plan = await client.fetchWeeklyPlan(
        uid: uid,
        profile: profile,
        startDate: today,
      );

      expect(plan.days.first.meals.first.recipe.title, 'Cached Breakfast');
      expect(delegate.fetchCount, 0);
    });

    test('regenerates and saves when cached plan is expired', () async {
      final repository = InMemoryUserRepository();
      final delegate = _RecordingMealPlanClient();
      final client = PersistedMealPlanClient(
        delegate: delegate,
        repository: repository,
      );

      const uid = 'uid_test';
      final profile = UserProfile.demoAngela(
        userId: uid,
        now: DateTime(2026, 7, 22),
      );
      final expiredStart = DateTime(2026, 7, 10);
      await repository.saveMealPlanWeek(uid, _sampleWeek(expiredStart));

      final today = DateUtils.dateOnly(DateTime(2026, 7, 22));
      final plan = await client.fetchWeeklyPlan(
        uid: uid,
        profile: profile,
        startDate: today,
      );

      expect(delegate.fetchCount, 1);
      expect(delegate.lastStartDate, today);
      expect(plan.days.first.date, today);
      expect(plan.days.first.meals.first.recipe.title, 'Fresh Breakfast');

      final stored = await repository.getMealPlanWeek(uid);
      expect(stored?.days.first.date, today);
    });

    test('forceRefresh bypasses cache', () async {
      final repository = InMemoryUserRepository();
      final delegate = _RecordingMealPlanClient();
      final client = PersistedMealPlanClient(
        delegate: delegate,
        repository: repository,
      );

      const uid = 'uid_test';
      final profile = UserProfile.demoAngela(
        userId: uid,
        now: DateTime(2026, 7, 22),
      );
      final today = DateUtils.dateOnly(DateTime(2026, 7, 22));
      await repository.saveMealPlanWeek(uid, _sampleWeek(today));

      await client.fetchWeeklyPlan(
        uid: uid,
        profile: profile,
        startDate: today,
        forceRefresh: true,
      );

      expect(delegate.fetchCount, 1);
    });
  });
}

MealPlanWeek _sampleWeek(DateTime startDate) {
  final start = DateUtils.dateOnly(startDate);
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
              recipeId: 'cached',
              title: 'Cached Breakfast',
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

class _RecordingMealPlanClient implements MealPlanClient {
  int fetchCount = 0;
  DateTime? lastStartDate;

  @override
  Future<MealPlanWeek> fetchWeeklyPlan({
    required String uid,
    required UserProfile profile,
    required DateTime startDate,
    bool forceRefresh = false,
  }) async {
    fetchCount += 1;
    lastStartDate = DateUtils.dateOnly(startDate);
    return _sampleWeek(startDate).copyWithFreshBreakfast();
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

extension on MealPlanWeek {
  MealPlanWeek copyWithFreshBreakfast() {
    final days = this.days.map((day) {
      final meals = day.meals.map((meal) {
        if (meal.slot != MealSlot.breakfast) {
          return meal;
        }
        return MealPlanMeal(
          slot: meal.slot,
          timeLabel: meal.timeLabel,
          badgeLabel: meal.badgeLabel,
          recipe: meal.recipe.copyWith(title: 'Fresh Breakfast'),
        );
      }).toList(growable: false);
      return MealPlanDay(date: day.date, meals: meals);
    }).toList(growable: false);
    return MealPlanWeek(generatedAt: generatedAt, days: days);
  }
}

extension on MealPlanRecipe {
  MealPlanRecipe copyWith({String? title}) {
    return MealPlanRecipe(
      recipeId: recipeId,
      title: title ?? this.title,
      imageUrl: imageUrl,
      sourceName: sourceName,
      sourceUrl: sourceUrl,
      calories: calories,
      nutrition: nutrition,
    );
  }
}
