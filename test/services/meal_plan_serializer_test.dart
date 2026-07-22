import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrilens/models/meal_plan.dart';
import 'package:nutrilens/models/nutrition_entry.dart';
import 'package:nutrilens/services/meal_plan_serializer.dart';

void main() {
  group('MealPlanSerializer', () {
    test('round-trips a weekly plan', () {
      final start = DateTime(2026, 7, 22);
      final week = MealPlanWeek(
        generatedAt: DateTime.utc(2026, 7, 22, 12),
        days: List.generate(7, (index) {
          final date = DateUtils.dateOnly(start).add(Duration(days: index));
          return MealPlanDay(
            date: date,
            meals: [
              MealPlanMeal(
                slot: MealSlot.breakfast,
                timeLabel: '8:00 AM',
                badgeLabel: 'BREAKFAST',
                recipe: MealPlanRecipe(
                  recipeId: 'r-$index',
                  title: 'Meal $index',
                  imageUrl: null,
                  sourceName: 'NutriLens',
                  sourceUrl: '',
                  calories: (400 + index).toDouble(),
                  nutrition: NutritionEntry(
                    caloriesKcal: 400 + index,
                    proteinG: 20,
                    carbsG: 40,
                    fatsG: 10,
                  ),
                ),
              ),
            ],
          );
        }, growable: false),
      );

      final restored = MealPlanSerializer.weekFromMap(
        MealPlanSerializer.weekToMap(week),
      );

      expect(restored.days, hasLength(7));
      expect(restored.days.first.date, DateUtils.dateOnly(start));
      expect(restored.days.last.meals.first.recipe.title, 'Meal 6');
    });
  });

  group('MealPlanWeekDates', () {
    test('isActiveOn covers the seven-day window', () {
      final start = DateTime(2026, 7, 22);
      final week = MealPlanWeek(
        generatedAt: DateTime.utc(2026, 7, 22),
        days: List.generate(
          7,
          (index) => MealPlanDay(
            date: DateUtils.dateOnly(start).add(Duration(days: index)),
            meals: const [],
          ),
          growable: false,
        ),
      );

      expect(week.isActiveOn(start), isTrue);
      expect(week.isActiveOn(start.add(const Duration(days: 6))), isTrue);
      expect(week.isActiveOn(start.add(const Duration(days: 7))), isFalse);
      expect(week.isExpiredOn(start.add(const Duration(days: 7))), isTrue);
    });
  });
}
