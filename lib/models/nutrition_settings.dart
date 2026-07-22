import 'package:nutrilens/models/firestore_map.dart';

enum UnitSystem {
  metric('metric'),
  imperial('imperial');

  const UnitSystem(this.firestoreValue);
  final String firestoreValue;

  static UnitSystem fromFirestore(String? value) {
    return UnitSystem.values.firstWhere(
      (e) => e.firestoreValue == value,
      orElse: () => UnitSystem.metric,
    );
  }
}

class NutritionSettings {
  const NutritionSettings({
    this.unitSystem = UnitSystem.metric,
    this.mealsPerDay = 3,
    this.mealRemindersEnabled = true,
    this.preWorkoutReminderEnabled = true,
    this.matchDayModeEnabled = true,
  });

  final UnitSystem unitSystem;
  final int mealsPerDay;
  final bool mealRemindersEnabled;
  final bool preWorkoutReminderEnabled;
  final bool matchDayModeEnabled;

  factory NutritionSettings.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const NutritionSettings();
    return NutritionSettings(
      unitSystem: UnitSystem.fromFirestore(map['unitSystem'] as String?),
      mealsPerDay: parseInt(map['mealsPerDay']) ?? 3,
      mealRemindersEnabled: parseBool(map['mealRemindersEnabled'], defaultValue: true),
      preWorkoutReminderEnabled: parseBool(
        map['preWorkoutReminderEnabled'],
        defaultValue: true,
      ),
      matchDayModeEnabled: parseBool(map['matchDayModeEnabled'], defaultValue: true),
    );
  }

  Map<String, dynamic> toMap() => {
    'unitSystem': unitSystem.firestoreValue,
    'mealsPerDay': mealsPerDay,
    'mealRemindersEnabled': mealRemindersEnabled,
    'preWorkoutReminderEnabled': preWorkoutReminderEnabled,
    'matchDayModeEnabled': matchDayModeEnabled,
  };

  NutritionSettings copyWith({
    UnitSystem? unitSystem,
    int? mealsPerDay,
    bool? mealRemindersEnabled,
    bool? preWorkoutReminderEnabled,
    bool? matchDayModeEnabled,
  }) {
    return NutritionSettings(
      unitSystem: unitSystem ?? this.unitSystem,
      mealsPerDay: mealsPerDay ?? this.mealsPerDay,
      mealRemindersEnabled: mealRemindersEnabled ?? this.mealRemindersEnabled,
      preWorkoutReminderEnabled:
          preWorkoutReminderEnabled ?? this.preWorkoutReminderEnabled,
      matchDayModeEnabled: matchDayModeEnabled ?? this.matchDayModeEnabled,
    );
  }
}
