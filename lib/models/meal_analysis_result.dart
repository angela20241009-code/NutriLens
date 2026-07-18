import 'package:nutrilens/models/nutrition_entry.dart';

/// Nutrition estimate returned from a meal photo analysis service.
class MealAnalysisResult {
  const MealAnalysisResult({
    required this.name,
    required this.nutrition,
  });

  final String name;
  final NutritionEntry nutrition;

  factory MealAnalysisResult.fromJson(Map<String, dynamic> json) {
    return MealAnalysisResult(
      name: (json['mealName'] as String? ?? '').trim(),
      nutrition: NutritionEntry(
        caloriesKcal: _parseInt(json['caloriesKcal']),
        proteinG: _parseInt(json['proteinG']),
        carbsG: _parseInt(json['carbsG']),
        fatsG: _parseInt(json['fatsG']),
      ),
    );
  }

  static int _parseInt(Object? value) {
    if (value is int) {
      return value < 0 ? 0 : value;
    }
    if (value is num) {
      return value.round().clamp(0, 99999);
    }
    if (value is String) {
      return int.tryParse(value)?.clamp(0, 99999) ?? 0;
    }
    return 0;
  }
}
