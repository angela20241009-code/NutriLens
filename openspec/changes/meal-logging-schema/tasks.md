## 0. Dependencies

- [x] 0.1 Add `timezone: ^0.9.4` to `pubspec.yaml` dependencies (IANA tz conversion — Dart stdlib `DateTime` cannot convert UTC to an arbitrary IANA zone)
- [x] 0.2 Initialize the tz database once at app startup (`tz.initializeTimeZones()`) before any repository call that derives `dateKey`
- [x] 0.3 Add `lib/services/date_key.dart` — `String dateKeyFor(DateTime instant, String timezone)` using `tz.TZDateTime.from(instant, tz.getLocation(timezone))` and `yyyy-MM-dd` formatting (manual `padLeft`, no `intl` needed); falls back to UTC if the timezone name is unknown

## 1. Models

- [x] 1.1 Create `lib/models/nutrition_entry.dart` — `NutritionEntry` with `caloriesKcal`, `proteinG`, `carbsG`, `fatsG` (all `int`, non-negative), `fromMap`, `toMap`, `operator +`, `copyWith`. `fromMap` defaults each field to `0` when absent
- [x] 1.2 Create `lib/models/meal_source.dart` — `MealSource` enum with `manual`, `scan`, `mealPlan` and `fromFirestore` (defaults to `manual`)
- [x] 1.3 Create `lib/models/meal.dart` — `Meal` model with all fields, `fromMap`, `toMap`, `copyWith`
- [x] 1.4 Create `lib/models/daily_summary.dart` — `DailySummary` model with all fields, `fromMap`, `toMap`, `copyWith`. `fromMap` defaults `totals` to a zero `NutritionEntry` and `mealCount` to `0` so a summary created by a hydration/sleep-only write parses cleanly
- [x] 1.5 Export all new models from `lib/models/models.dart`

## 2. Firestore Paths

- [x] 2.1 Add `meals(String uid)` → `'meals/$uid/entries'` to `FirestorePaths`
- [x] 2.2 Add `mealDoc(String uid, String mealId)` → `'meals/$uid/entries/$mealId'` to `FirestorePaths`
- [x] 2.3 Add `dailySummaries(String uid)` → `'dailySummaries/$uid/days'` to `FirestorePaths`
- [x] 2.4 Add `dailySummaryDoc(String uid, String dateKey)` → `'dailySummaries/$uid/days/$dateKey'` to `FirestorePaths`

## 3. Repository Interface

- [x] 3.1 Add `logMeal(String uid, Meal meal, String timezone) → Future<Meal>` to `UserRepository` (timezone passed explicitly — symmetric with `getMealsForDay`, no profile read inside the transaction)
- [x] 3.2 Add `getMealsForDay(String uid, DateTime date, String timezone) → Future<List<Meal>>` to `UserRepository`
- [x] 3.3 Add `getDailySummary(String uid, String dateKey) → Future<DailySummary?>` to `UserRepository`
- [x] 3.4 Add `updateDailySummary(String uid, String dateKey, {double? hydrationLiters, double? sleepHours}) → Future<void>` to `UserRepository`

## 4. Firestore Implementation

- [x] 4.1 Implement `logMeal` in `FirestoreUserRepository` — derive `dateKey` from `meal.loggedAt` + `timezone` via `dateKeyFor`. Create the auto-ID meal `doc()` ref before `runTransaction`. Inside the transaction: read the summary doc first (all reads before writes), then write the meal entry and the updated/created summary. Both writes commit atomically or not at all
- [x] 4.2 Implement `getMealsForDay` in `FirestoreUserRepository` — compute the local-day start/end in `timezone`, convert both bounds back to UTC instants, query `meals/{uid}/entries` with `loggedAt` range on those instants, order by `loggedAt` ascending
- [x] 4.3 Implement `getDailySummary` in `FirestoreUserRepository` — read `dailySummaries/{uid}/days/{dateKey}`, return null if missing
- [x] 4.4 Implement `updateDailySummary` in `FirestoreUserRepository` — if the summary doc is missing, create it with `uid`, `dateKey`, zero `totals`, `mealCount` 0, the provided field(s), and `updatedAt`; if it exists, partial-update only the provided field(s) plus `updatedAt` via `SetOptions(merge: true)`

## 5. In-Memory Implementation

- [x] 5.1 Implement `logMeal` in `InMemoryUserRepository` — derive `dateKey` via `dateKeyFor`, append to in-memory list, update or create `DailySummary` map entry
- [x] 5.2 Implement `getMealsForDay` in `InMemoryUserRepository` — filter in-memory list by local day using `timezone`
- [x] 5.3 Implement `getDailySummary` in `InMemoryUserRepository` — look up from in-memory map, return null if missing
- [x] 5.4 Implement `updateDailySummary` in `InMemoryUserRepository` — update hydration/sleep on existing summary, or create a new summary (zero `totals`, `mealCount` 0) when none exists — matching the Firestore impl

## 6. Tests

- [x] 6.1 Unit test `NutritionEntry` — `operator +`, round-trip serialization, missing-field defaults to 0
- [x] 6.2 Unit test `Meal` — round-trip serialization, unknown `MealSource` defaults to `manual`
- [x] 6.3 Unit test `dateKeyFor` / `DailySummary` — `2026-06-06T23:30:00Z` in `America/Los_Angeles` → `2026-06-06`; a winter instant near midnight resolves with the correct (non-DST) offset; round-trip serialization
- [x] 6.4 Unit test `InMemoryUserRepository.logMeal` — first meal creates summary, second meal increments totals and `mealCount`
- [x] 6.5 Unit test `InMemoryUserRepository.updateDailySummary` — hydration-only write with no prior summary creates a valid summary with zero `totals` and `mealCount` 0
