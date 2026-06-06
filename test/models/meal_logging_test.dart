import 'package:flutter_test/flutter_test.dart';
import 'package:nutrilens/models/daily_summary.dart';
import 'package:nutrilens/models/meal.dart';
import 'package:nutrilens/models/meal_source.dart';
import 'package:nutrilens/models/nutrition_entry.dart';
import 'package:nutrilens/services/date_key.dart';
import 'package:nutrilens/services/in_memory_user_repository.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
  });

  // ── 6.1  NutritionEntry ─────────────────────────────────────────────────

  group('NutritionEntry', () {
    test('operator + sums fields correctly', () {
      const a = NutritionEntry(
        caloriesKcal: 200,
        proteinG: 20,
        carbsG: 25,
        fatsG: 5,
      );
      const b = NutritionEntry(
        caloriesKcal: 100,
        proteinG: 10,
        carbsG: 15,
        fatsG: 3,
      );
      expect(a + b, const NutritionEntry(
        caloriesKcal: 300,
        proteinG: 30,
        carbsG: 40,
        fatsG: 8,
      ));
    });

    test('round-trip serialization preserves all fields', () {
      const entry = NutritionEntry(
        caloriesKcal: 500,
        proteinG: 40,
        carbsG: 60,
        fatsG: 15,
      );
      final restored = NutritionEntry.fromMap(entry.toMap());
      expect(restored, entry);
    });

    test('fromMap defaults missing fields to 0', () {
      final entry = NutritionEntry.fromMap({});
      expect(entry.caloriesKcal, 0);
      expect(entry.proteinG, 0);
      expect(entry.carbsG, 0);
      expect(entry.fatsG, 0);
    });

    test('fromMap(null) returns zero entry', () {
      final entry = NutritionEntry.fromMap(null);
      expect(entry, const NutritionEntry());
    });
  });

  // ── 6.2  Meal ─────────────────────────────────────────────────────────────

  group('Meal', () {
    final loggedAt = DateTime.utc(2026, 6, 6, 12, 30);

    test('round-trip serialization preserves all fields', () {
      final meal = Meal(
        mealId: 'meal_001',
        name: 'Chicken and Rice',
        nutrition: const NutritionEntry(
          caloriesKcal: 600,
          proteinG: 50,
          carbsG: 70,
          fatsG: 10,
        ),
        source: MealSource.manual,
        loggedAt: loggedAt,
        photoStoragePath: 'photos/meal_001.jpg',
        notes: 'Post-workout meal',
      );

      final restored = Meal.fromMap(meal.toMap(), mealId: 'meal_001');

      expect(restored.mealId, meal.mealId);
      expect(restored.name, meal.name);
      expect(restored.nutrition, meal.nutrition);
      expect(restored.source, meal.source);
      expect(restored.loggedAt, meal.loggedAt);
      expect(restored.photoStoragePath, meal.photoStoragePath);
      expect(restored.notes, meal.notes);
    });

    test('unknown MealSource string defaults to manual', () {
      final meal = Meal.fromMap({
        'name': 'Unknown',
        'nutrition': <String, dynamic>{},
        'source': 'alien_scan',
        'loggedAt': loggedAt.toIso8601String(),
      });
      expect(meal.source, MealSource.manual);
    });

    test('MealSource.fromFirestore handles null as manual', () {
      expect(MealSource.fromFirestore(null), MealSource.manual);
    });
  });

  // ── 6.3  dateKeyFor / DailySummary ────────────────────────────────────────

  group('dateKeyFor', () {
    test('summer DST: 2026-06-06T23:30:00Z in America/Los_Angeles → 2026-06-06',
        () {
      // PDT = UTC-7 → 23:30 UTC = 16:30 local → same date
      final instant = DateTime.utc(2026, 6, 6, 23, 30);
      expect(dateKeyFor(instant, 'America/Los_Angeles'), '2026-06-06');
    });

    test('winter no-DST: 2026-01-01T05:30:00Z in America/Los_Angeles → 2025-12-31',
        () {
      // PST = UTC-8 → 05:30 UTC = 21:30 local on Dec 31
      final instant = DateTime.utc(2026, 1, 1, 5, 30);
      expect(dateKeyFor(instant, 'America/Los_Angeles'), '2025-12-31');
    });

    test('unknown timezone falls back to UTC', () {
      final instant = DateTime.utc(2026, 6, 6, 23, 30);
      // Falls back to UTC → same as UTC date
      expect(dateKeyFor(instant, 'Unknown/Zone'), '2026-06-06');
    });
  });

  group('DailySummary', () {
    test('round-trip serialization preserves all fields', () {
      final summary = DailySummary(
        uid: 'user_abc',
        dateKey: '2026-06-06',
        totals: const NutritionEntry(
          caloriesKcal: 2000,
          proteinG: 150,
          carbsG: 250,
          fatsG: 70,
        ),
        mealCount: 3,
        hydrationLiters: 2.5,
        sleepHours: 8.0,
        updatedAt: DateTime.utc(2026, 6, 6, 20),
      );

      final restored = DailySummary.fromMap(summary.toMap());
      expect(restored.uid, summary.uid);
      expect(restored.dateKey, summary.dateKey);
      expect(restored.totals, summary.totals);
      expect(restored.mealCount, summary.mealCount);
      expect(restored.hydrationLiters, summary.hydrationLiters);
      expect(restored.sleepHours, summary.sleepHours);
      expect(restored.updatedAt, summary.updatedAt);
    });

    test('fromMap defaults totals and mealCount when absent', () {
      final summary = DailySummary.fromMap({
        'uid': 'user_abc',
        'dateKey': '2026-06-06',
        'hydrationLiters': 1.5,
        'sleepHours': 7.0,
        'updatedAt': DateTime.utc(2026, 6, 6).toIso8601String(),
      });
      expect(summary.totals, const NutritionEntry());
      expect(summary.mealCount, 0);
      expect(summary.hydrationLiters, 1.5);
    });
  });

  // ── 6.4  InMemoryUserRepository.logMeal ──────────────────────────────────

  group('InMemoryUserRepository.logMeal', () {
    late InMemoryUserRepository repo;
    const uid = 'user_test';
    const timezone = 'America/Los_Angeles';
    final loggedAt = DateTime.utc(2026, 6, 6, 18); // 11:00 PDT

    setUp(() {
      repo = InMemoryUserRepository();
    });

    test('first meal creates summary with correct totals and mealCount 1',
        () async {
      final meal = Meal(
        name: 'Breakfast',
        nutrition: const NutritionEntry(
          caloriesKcal: 400,
          proteinG: 30,
          carbsG: 50,
          fatsG: 10,
        ),
        source: MealSource.manual,
        loggedAt: loggedAt,
      );

      final saved = await repo.logMeal(uid, meal, timezone);
      expect(saved.mealId, isNotNull);
      expect(saved.name, 'Breakfast');

      final summary = await repo.getDailySummary(uid, '2026-06-06');
      expect(summary, isNotNull);
      expect(summary!.mealCount, 1);
      expect(summary.totals.caloriesKcal, 400);
      expect(summary.totals.proteinG, 30);
    });

    test('second meal increments totals and mealCount', () async {
      final meal1 = Meal(
        name: 'Breakfast',
        nutrition: const NutritionEntry(
          caloriesKcal: 400,
          proteinG: 30,
          carbsG: 50,
          fatsG: 10,
        ),
        source: MealSource.manual,
        loggedAt: loggedAt,
      );
      final meal2 = Meal(
        name: 'Lunch',
        nutrition: const NutritionEntry(
          caloriesKcal: 600,
          proteinG: 50,
          carbsG: 70,
          fatsG: 15,
        ),
        source: MealSource.manual,
        loggedAt: loggedAt.add(const Duration(hours: 4)),
      );

      await repo.logMeal(uid, meal1, timezone);
      await repo.logMeal(uid, meal2, timezone);

      final summary = await repo.getDailySummary(uid, '2026-06-06');
      expect(summary!.mealCount, 2);
      expect(summary.totals.caloriesKcal, 1000);
      expect(summary.totals.proteinG, 80);
      expect(summary.totals.carbsG, 120);
      expect(summary.totals.fatsG, 25);
    });
  });

  // ── 6.5  InMemoryUserRepository.updateDailySummary ───────────────────────

  group('InMemoryUserRepository.updateDailySummary', () {
    late InMemoryUserRepository repo;
    const uid = 'user_test';
    const dateKey = '2026-06-06';

    setUp(() {
      repo = InMemoryUserRepository();
    });

    test(
        'hydration-only write with no prior summary creates valid summary '
        'with zero totals and mealCount 0', () async {
      await repo.updateDailySummary(uid, dateKey, hydrationLiters: 2.5);

      final summary = await repo.getDailySummary(uid, dateKey);
      expect(summary, isNotNull);
      expect(summary!.uid, uid);
      expect(summary.dateKey, dateKey);
      expect(summary.hydrationLiters, 2.5);
      expect(summary.sleepHours, 0);
      expect(summary.totals, const NutritionEntry());
      expect(summary.mealCount, 0);
    });

    test('sleep-only write creates valid summary', () async {
      await repo.updateDailySummary(uid, dateKey, sleepHours: 7.5);

      final summary = await repo.getDailySummary(uid, dateKey);
      expect(summary!.sleepHours, 7.5);
      expect(summary.hydrationLiters, 0);
      expect(summary.totals, const NutritionEntry());
    });

    test('update on existing summary only changes provided fields', () async {
      // First create a summary via logMeal.
      final meal = Meal(
        name: 'Dinner',
        nutrition: const NutritionEntry(caloriesKcal: 800, proteinG: 60, carbsG: 90, fatsG: 20),
        source: MealSource.manual,
        loggedAt: DateTime.utc(2026, 6, 6, 18),
      );
      await repo.logMeal(uid, meal, 'America/Los_Angeles');

      // Now update only hydration.
      await repo.updateDailySummary(uid, dateKey, hydrationLiters: 3.0);

      final summary = await repo.getDailySummary(uid, dateKey);
      expect(summary!.hydrationLiters, 3.0);
      // Meal count and totals should be unchanged.
      expect(summary.mealCount, 1);
      expect(summary.totals.caloriesKcal, 800);
    });
  });
}
