import 'package:nutrilens/models/firestore_map.dart';

class StatsCache {
  const StatsCache({
    required this.currentStreak,
    required this.mealsLoggedTotal,
    required this.fuelScore,
  });

  final int currentStreak;
  final int mealsLoggedTotal;
  final int fuelScore;

  factory StatsCache.fromMap(Map<String, dynamic> map) {
    return StatsCache(
      currentStreak: parseInt(map['currentStreak']) ?? 0,
      mealsLoggedTotal: parseInt(map['mealsLoggedTotal']) ?? 0,
      fuelScore: parseInt(map['fuelScore']) ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'currentStreak': currentStreak,
    'mealsLoggedTotal': mealsLoggedTotal,
    'fuelScore': fuelScore,
  };
}
