import 'package:nutrilens/models/firestore_map.dart';
import 'package:nutrilens/models/meal_source.dart';
import 'package:nutrilens/models/nutrition_entry.dart';

/// A single logged meal entry.
///
/// [mealId] is null before the entry is persisted (auto-assigned by Firestore).
/// [loggedAt] is always stored/returned as UTC.
class Meal {
  const Meal({
    this.mealId,
    required this.name,
    required this.nutrition,
    required this.source,
    required this.loggedAt,
    this.photoStoragePath,
    this.notes,
  });

  final String? mealId;
  final String name;
  final NutritionEntry nutrition;
  final MealSource source;
  final DateTime loggedAt;
  final String? photoStoragePath;
  final String? notes;

  factory Meal.fromMap(Map<String, dynamic> map, {String? mealId}) {
    final nutritionRaw = map['nutrition'];
    return Meal(
      mealId: mealId ?? map['mealId'] as String?,
      name: map['name'] as String? ?? '',
      nutrition: NutritionEntry.fromMap(
        nutritionRaw != null
            ? Map<String, dynamic>.from(nutritionRaw as Map)
            : null,
      ),
      source: MealSource.fromFirestore(map['source'] as String?),
      loggedAt: parseRequiredDateTime(map['loggedAt']),
      photoStoragePath: map['photoStoragePath'] as String?,
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'mealId': mealId,
    'name': name,
    'nutrition': nutrition.toMap(),
    'source': source.firestoreValue,
    'loggedAt': loggedAt.toUtc().toIso8601String(),
    'photoStoragePath': photoStoragePath,
    'notes': notes,
  };

  Meal copyWith({
    String? mealId,
    String? name,
    NutritionEntry? nutrition,
    MealSource? source,
    DateTime? loggedAt,
    String? photoStoragePath,
    String? notes,
  }) {
    return Meal(
      mealId: mealId ?? this.mealId,
      name: name ?? this.name,
      nutrition: nutrition ?? this.nutrition,
      source: source ?? this.source,
      loggedAt: loggedAt ?? this.loggedAt,
      photoStoragePath: photoStoragePath ?? this.photoStoragePath,
      notes: notes ?? this.notes,
    );
  }
}
