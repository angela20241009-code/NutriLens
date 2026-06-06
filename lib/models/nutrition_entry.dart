import 'package:nutrilens/models/firestore_map.dart';

/// Immutable value object holding per-meal or daily nutrition totals.
///
/// All fields are non-negative integers (rounding is acceptable for MVP).
class NutritionEntry {
  const NutritionEntry({
    this.caloriesKcal = 0,
    this.proteinG = 0,
    this.carbsG = 0,
    this.fatsG = 0,
  });

  final int caloriesKcal;
  final int proteinG;
  final int carbsG;
  final int fatsG;

  factory NutritionEntry.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const NutritionEntry();
    return NutritionEntry(
      caloriesKcal: parseInt(map['caloriesKcal']) ?? 0,
      proteinG: parseInt(map['proteinG']) ?? 0,
      carbsG: parseInt(map['carbsG']) ?? 0,
      fatsG: parseInt(map['fatsG']) ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'caloriesKcal': caloriesKcal,
    'proteinG': proteinG,
    'carbsG': carbsG,
    'fatsG': fatsG,
  };

  NutritionEntry operator +(NutritionEntry other) => NutritionEntry(
    caloriesKcal: caloriesKcal + other.caloriesKcal,
    proteinG: proteinG + other.proteinG,
    carbsG: carbsG + other.carbsG,
    fatsG: fatsG + other.fatsG,
  );

  NutritionEntry copyWith({
    int? caloriesKcal,
    int? proteinG,
    int? carbsG,
    int? fatsG,
  }) {
    return NutritionEntry(
      caloriesKcal: caloriesKcal ?? this.caloriesKcal,
      proteinG: proteinG ?? this.proteinG,
      carbsG: carbsG ?? this.carbsG,
      fatsG: fatsG ?? this.fatsG,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NutritionEntry &&
          caloriesKcal == other.caloriesKcal &&
          proteinG == other.proteinG &&
          carbsG == other.carbsG &&
          fatsG == other.fatsG;

  @override
  int get hashCode =>
      Object.hash(caloriesKcal, proteinG, carbsG, fatsG);

  @override
  String toString() =>
      'NutritionEntry(calories=$caloriesKcal, protein=$proteinG, carbs=$carbsG, fats=$fatsG)';
}
