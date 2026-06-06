import 'package:nutrilens/models/firestore_map.dart';
import 'package:nutrilens/models/nutrition_entry.dart';

/// Pre-aggregated daily nutrition summary keyed by `yyyy-MM-dd` in the user's
/// local timezone.
///
/// [totals] defaults to a zero [NutritionEntry] and [mealCount] to `0`
/// so that a summary created by a hydration/sleep-only write parses cleanly.
class DailySummary {
  const DailySummary({
    required this.uid,
    required this.dateKey,
    this.totals = const NutritionEntry(),
    this.mealCount = 0,
    this.hydrationLiters = 0,
    this.sleepHours = 0,
    required this.updatedAt,
  });

  final String uid;

  /// `yyyy-MM-dd` in the user's local timezone.
  final String dateKey;

  /// Sum of all logged meals for the day.
  final NutritionEntry totals;

  /// Number of meals logged for the day.
  final int mealCount;

  /// Liters of water consumed (tracked independently of meals).
  final double hydrationLiters;

  /// Hours slept (tracked independently of meals).
  final double sleepHours;

  /// UTC timestamp of the last write to this document.
  final DateTime updatedAt;

  factory DailySummary.fromMap(Map<String, dynamic> map) {
    final totalsRaw = map['totals'];
    return DailySummary(
      uid: map['uid'] as String? ?? '',
      dateKey: map['dateKey'] as String? ?? '',
      totals: NutritionEntry.fromMap(
        totalsRaw != null
            ? Map<String, dynamic>.from(totalsRaw as Map)
            : null,
      ),
      mealCount: parseInt(map['mealCount']) ?? 0,
      hydrationLiters: parseDouble(map['hydrationLiters']) ?? 0,
      sleepHours: parseDouble(map['sleepHours']) ?? 0,
      updatedAt: parseRequiredDateTime(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'dateKey': dateKey,
    'totals': totals.toMap(),
    'mealCount': mealCount,
    'hydrationLiters': hydrationLiters,
    'sleepHours': sleepHours,
    'updatedAt': updatedAt.toUtc().toIso8601String(),
  };

  DailySummary copyWith({
    String? uid,
    String? dateKey,
    NutritionEntry? totals,
    int? mealCount,
    double? hydrationLiters,
    double? sleepHours,
    DateTime? updatedAt,
  }) {
    return DailySummary(
      uid: uid ?? this.uid,
      dateKey: dateKey ?? this.dateKey,
      totals: totals ?? this.totals,
      mealCount: mealCount ?? this.mealCount,
      hydrationLiters: hydrationLiters ?? this.hydrationLiters,
      sleepHours: sleepHours ?? this.sleepHours,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
