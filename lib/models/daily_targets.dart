import 'package:nutrilens/models/firestore_map.dart';

enum DailyTargetsSource {
  onboarding('onboarding'),
  sportDefaults('sport_defaults'),
  coachOverride('coach_override'),
  manual('manual');

  const DailyTargetsSource(this.firestoreValue);
  final String firestoreValue;

  static DailyTargetsSource fromFirestore(String? value) {
    return DailyTargetsSource.values.firstWhere(
      (e) => e.firestoreValue == value,
      orElse: () => DailyTargetsSource.sportDefaults,
    );
  }
}

class DailyTargets {
  const DailyTargets({
    required this.caloriesKcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatsG,
    required this.hydrationLiters,
    required this.sleepHours,
    required this.source,
    required this.effectiveFrom,
  });

  final int caloriesKcal;
  final int proteinG;
  final int carbsG;
  final int fatsG;
  final double hydrationLiters;
  final double sleepHours;
  final DailyTargetsSource source;
  final DateTime effectiveFrom;

  factory DailyTargets.fromMap(Map<String, dynamic> map) {
    return DailyTargets(
      caloriesKcal: parseInt(map['caloriesKcal']) ?? 0,
      proteinG: parseInt(map['proteinG']) ?? 0,
      carbsG: parseInt(map['carbsG']) ?? 0,
      fatsG: parseInt(map['fatsG']) ?? 0,
      hydrationLiters: parseDouble(map['hydrationLiters']) ?? 0,
      sleepHours: parseDouble(map['sleepHours']) ?? 8,
      source: DailyTargetsSource.fromFirestore(map['source'] as String?),
      effectiveFrom: parseRequiredDateTime(map['effectiveFrom']),
    );
  }

  Map<String, dynamic> toMap() => {
    'caloriesKcal': caloriesKcal,
    'proteinG': proteinG,
    'carbsG': carbsG,
    'fatsG': fatsG,
    'hydrationLiters': hydrationLiters,
    'sleepHours': sleepHours,
    'source': source.firestoreValue,
    'effectiveFrom': effectiveFrom.toUtc().toIso8601String(),
  };

  DailyTargets copyWith({
    int? caloriesKcal,
    int? proteinG,
    int? carbsG,
    int? fatsG,
    double? hydrationLiters,
    double? sleepHours,
    DailyTargetsSource? source,
    DateTime? effectiveFrom,
  }) {
    return DailyTargets(
      caloriesKcal: caloriesKcal ?? this.caloriesKcal,
      proteinG: proteinG ?? this.proteinG,
      carbsG: carbsG ?? this.carbsG,
      fatsG: fatsG ?? this.fatsG,
      hydrationLiters: hydrationLiters ?? this.hydrationLiters,
      sleepHours: sleepHours ?? this.sleepHours,
      source: source ?? this.source,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
    );
  }
}
