## Why

The app has no way to log meals — the core nutrition-tracking loop is broken. Without a `Meal` model, Firestore collection, and daily summary aggregation, the home dashboard and insights screens have no real data to display.

## What Changes

- Add `Meal` model with full macro breakdown, photo reference, source (manual / scan), and timestamp
- Add `DailySummary` model for pre-aggregated daily totals (calories, protein, carbs, fats, hydration, sleep)
- Add Firestore paths: `meals/{uid}/entries/{mealId}` and `dailySummaries/{uid}/days/{dateKey}`
- Extend `UserRepository` interface with `logMeal`, `getMealsForDay`, `getDailySummary`, `updateDailySummary` (`logMeal` and `getMealsForDay` take an explicit `timezone` arg)
- Add `timezone` package + `dateKeyFor` helper for IANA-correct `dateKey` derivation
- Implement the above in `FirestoreUserRepository` and `InMemoryUserRepository`
- Add `MealSource` enum: `manual`, `scan`, `mealPlan`
- Add `NutritionEntry` value object (calories, protein, carbs, fats) reused across Meal and DailySummary

## Capabilities

### New Capabilities

- `meal-logging`: Log a meal entry with macros, optional photo, source type, and timestamp. Entries stored under `meals/{uid}/entries/{mealId}`. Supports create and list-by-day queries.
- `daily-summary`: Read and write a pre-aggregated daily nutrition summary keyed by `yyyy-MM-dd`. Updated atomically on each meal log. Powers home dashboard macro progress bars and insights trend data.

### Modified Capabilities

<!-- none -->

## Impact

- `lib/models/` — new files: `meal.dart`, `daily_summary.dart`, `nutrition_entry.dart`, `meal_source.dart`
- `lib/models/models.dart` — add new model exports
- `lib/services/user_repository.dart` — new method signatures
- `lib/services/firestore_user_repository.dart` — Firestore read/write implementations
- `lib/services/in_memory_user_repository.dart` — in-memory implementations for demo/test
- `lib/services/firestore_paths.dart` — new path helpers
- `lib/services/date_key.dart` — new `dateKeyFor(instant, timezone)` helper
- `pubspec.yaml` — add `timezone` package (IANA tz conversion for `dateKey` derivation)
- App startup — call `tz.initializeTimeZones()` before first repository use
- No UI changes in this change — data layer only
