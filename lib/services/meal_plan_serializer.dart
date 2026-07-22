import 'package:flutter/material.dart';
import 'package:nutrilens/models/meal_plan.dart';
import 'package:nutrilens/models/nutrition_entry.dart';

abstract final class MealPlanSerializer {
  static Map<String, dynamic> weekToMap(MealPlanWeek week) {
    final startDate = week.startDate;
    return {
      'startDate': _dateKey(startDate),
      'generatedAt': week.generatedAt.toUtc().toIso8601String(),
      'days': week.days.map(dayToMap).toList(growable: false),
    };
  }

  static MealPlanWeek weekFromMap(Map<String, dynamic> map) {
    final daysRaw = map['days'];
    final days = daysRaw is List
        ? daysRaw
              .whereType<Map<String, dynamic>>()
              .map(dayFromMap)
              .toList(growable: false)
        : const <MealPlanDay>[];

    final generatedAtRaw = map['generatedAt'] as String?;
    final generatedAt = generatedAtRaw == null
        ? DateTime.now().toUtc()
        : DateTime.parse(generatedAtRaw).toUtc();

    return MealPlanWeek(generatedAt: generatedAt, days: days);
  }

  static Map<String, dynamic> dayToMap(MealPlanDay day) {
    return {
      'date': _dateKey(day.date),
      'meals': day.meals.map(mealToMap).toList(growable: false),
    };
  }

  static MealPlanDay dayFromMap(Map<String, dynamic> map) {
    return MealPlanDay(
      date: _parseDate(map['date'] as String?),
      meals: (map['meals'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(mealFromMap)
          .toList(growable: false),
    );
  }

  static Map<String, dynamic> mealToMap(MealPlanMeal meal) {
    return {
      'slot': meal.slot.name,
      'timeLabel': meal.timeLabel,
      'badgeLabel': meal.badgeLabel,
      'recipe': recipeToMap(meal.recipe),
    };
  }

  static MealPlanMeal mealFromMap(Map<String, dynamic> map) {
    final slotName = map['slot'] as String? ?? 'breakfast';
    final slot = MealSlot.values.firstWhere(
      (value) => value.name == slotName,
      orElse: () => MealSlot.breakfast,
    );

    return MealPlanMeal(
      slot: slot,
      timeLabel: map['timeLabel'] as String? ?? slot.label,
      badgeLabel: map['badgeLabel'] as String? ?? slot.label.toUpperCase(),
      recipe: recipeFromMap(
        Map<String, dynamic>.from(map['recipe'] as Map? ?? {}),
      ),
    );
  }

  static Map<String, dynamic> recipeToMap(MealPlanRecipe recipe) {
    return {
      'recipeId': recipe.recipeId,
      'title': recipe.title,
      'imageUrl': recipe.imageUrl,
      'sourceName': recipe.sourceName,
      'sourceUrl': recipe.sourceUrl,
      'calories': recipe.calories,
      'nutrition': recipe.nutrition.toMap(),
    };
  }

  static MealPlanRecipe recipeFromMap(Map<String, dynamic> map) {
    return MealPlanRecipe(
      recipeId: map['recipeId'] as String? ?? '',
      title: map['title'] as String? ?? 'Untitled meal',
      imageUrl: map['imageUrl'] as String?,
      sourceName: map['sourceName'] as String? ?? 'NutriLens',
      sourceUrl: map['sourceUrl'] as String? ?? '',
      calories: (map['calories'] as num?)?.toDouble() ?? 0,
      nutrition: NutritionEntry.fromMap(
        Map<String, dynamic>.from(map['nutrition'] as Map? ?? {}),
      ),
    );
  }

  static String _dateKey(DateTime date) {
    final normalized = DateUtils.dateOnly(date);
    return '${normalized.year.toString().padLeft(4, '0')}-'
        '${normalized.month.toString().padLeft(2, '0')}-'
        '${normalized.day.toString().padLeft(2, '0')}';
  }

  static DateTime _parseDate(String? value) {
    if (value == null || value.isEmpty) {
      return DateUtils.dateOnly(DateTime.now());
    }
    final parts = value.split('-');
    if (parts.length != 3) {
      return DateUtils.dateOnly(DateTime.now());
    }
    return DateUtils.dateOnly(
      DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      ),
    );
  }
}

extension MealPlanWeekDates on MealPlanWeek {
  DateTime get startDate {
    if (days.isEmpty) {
      return DateUtils.dateOnly(generatedAt.toLocal());
    }
    return DateUtils.dateOnly(days.first.date);
  }

  DateTime get endDate => startDate.add(const Duration(days: 6));

  bool isActiveOn(DateTime date) {
    if (days.isEmpty) {
      return false;
    }
    final target = DateUtils.dateOnly(date);
    return !target.isBefore(startDate) && !target.isAfter(endDate);
  }

  bool isExpiredOn(DateTime date) {
    if (days.isEmpty) {
      return true;
    }
    return DateUtils.dateOnly(date).isAfter(endDate);
  }
}
