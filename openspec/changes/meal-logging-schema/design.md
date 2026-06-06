## Context

The app has `UserProfile`, `SportProfile`, and `TeamProgram` persisted in Firestore but no meal or nutrition logging layer. The home dashboard and insights screens currently consume static mock data. The repository pattern (`UserRepository` abstract class + `FirestoreUserRepository` / `InMemoryUserRepository` implementations) is already established and must be extended.

Current Firestore collections: `users`, `userProfiles`, `sportProfiles`, `teamPrograms`.

No meal, daily summary, or scan collection exists yet.

## Goals / Non-Goals

**Goals:**
- Define `Meal`, `DailySummary`, `NutritionEntry` Dart models with full Firestore serialization
- Add Firestore paths for `meals/{uid}/entries/{mealId}` and `dailySummaries/{uid}/days/{dateKey}`
- Extend `UserRepository` interface and both implementations with log/read methods
- Keep daily summary in sync with meal entries (client-side update on log)
- Support in-memory implementation parity for demo/offline mode

**Non-Goals:**
- Camera scan UI or AI food recognition (Phase 4)
- Meal plan generation (Phase 5)
- Cloud Functions / server-side aggregation triggers
- Deletion or editing of logged meals (future)

## Decisions

### Subcollection over top-level collection for meals

`meals/{uid}/entries/{mealId}` rather than a flat `meals/{mealId}` top-level collection.

**Why**: Firestore security rules can restrict the entire subcollection to the owning user with a single path rule (`/meals/{uid}/entries/{mealId}`). Flat collection requires a field-level rule check on every document. Subcollection also makes `getDailySummary` range queries cheaper — only scans one user's data.

**Alternative considered**: Top-level `meals` collection with `userId` field. Rejected because it requires composite index + security rule complexity for no benefit at this scale.

### Pre-aggregated DailySummary written on every meal log

On `logMeal`, the client reads the current `DailySummary` for that day, adds the new meal's macros, and writes both the meal entry and the summary in a single Firestore transaction. The auto-ID meal `doc()` ref is created before the transaction; inside, the summary is read first (Firestore requires all reads before any write), then both docs are written. The transaction commits atomically — there is no state where only one of the two writes is persisted.

**Why**: Home dashboard needs instant macro progress bar updates without scanning all meal entries. A read-time aggregation over potentially hundreds of entries per day is slow and expensive.

**Alternative considered**: Compute totals client-side from the full meal list on every screen load. Rejected — O(n) reads on every home screen visit, gets expensive as meal history grows.

**Trade-off**: Two writes per meal log (entry + summary). Acceptable at this scale; can move to Cloud Functions transaction later if needed.

### dateKey format: `yyyy-MM-dd` in the user's local timezone

DailySummary documents are keyed by `yyyy-MM-dd` derived from the meal timestamp converted to the user's local timezone (`UserProfile.timezone`, an IANA name). Stored as a string field and document ID.

**Why**: Simple, human-readable, sortable lexicographically. Easy range queries for weekly insights (`>=` / `<=` on string keys in ISO format).

**Alternative considered**: Unix day number (milliseconds / 86400000). Rejected — less readable, harder to debug.

### IANA timezone conversion via the `timezone` package

`dateKey` derivation and `getMealsForDay` day-boundary math both require converting a UTC instant to a wall-clock date in an arbitrary IANA zone (e.g. `America/Los_Angeles`).

**Why**: Dart's stdlib `DateTime` only supports the device-local zone (`toLocal()`) or UTC — it cannot resolve an arbitrary IANA zone, and DST means a fixed offset is wrong (LA is UTC-7 in summer, UTC-8 in winter). The `timezone` package ships the IANA tz database; `tz.TZDateTime.from(instant, tz.getLocation(name))` gives the correct local wall-clock time. Centralized in `lib/services/date_key.dart` as `dateKeyFor(instant, timezone)`, falling back to UTC for unknown zone names. `tz.initializeTimeZones()` must run once at app startup.

**Trade-off**: Adds one dependency and a startup init call. No stdlib alternative produces correct results.

### logMeal takes an explicit timezone argument

`logMeal(uid, meal, timezone)` rather than reading `UserProfile` inside the transaction to find the zone.

**Why**: Symmetric with `getMealsForDay(uid, date, timezone)`, avoids an extra Firestore read coupled into the write transaction, and keeps the data layer free of a profile dependency. The caller (which already has the profile in context) passes the zone.

### NutritionEntry as embedded value object

Macros (calories, protein, carbs, fats) are grouped in a `NutritionEntry` embedded map rather than top-level fields on `Meal` and `DailySummary`.

**Why**: Avoids field-name collisions (`caloriesKcal` is clear in isolation but ambiguous at the top level of a summary doc). Allows adding new macro fields (fiber, sugar, sodium) without flattening the schema.

### MealSource enum

`manual` — user typed in macros directly
`scan` — came from camera scan flow (future)
`mealPlan` — pre-populated from generated meal plan (future)

Stored as string in Firestore. Defaults to `manual` for unknown values.

## Risks / Trade-offs

- **Concurrent writes to DailySummary** → Using Firestore transaction in `logMeal` prevents double-counting if two devices log simultaneously. InMemory implementation uses synchronous update (no race condition in single-threaded Dart).
- **Timezone edge case** → Meals logged near midnight may land on the wrong day if the timezone is not applied correctly, including DST transitions. Mitigation: derive `dateKey` via `dateKeyFor` (IANA tz database), never a fixed offset or raw UTC.
- **No offline queue** → If the Firestore transaction fails, neither write commits and the meal is not saved (the exception propagates to the caller). Acceptable for MVP; add a local write-ahead queue in a later phase.
- **Hydration/sleep before any meal** → `updateDailySummary` may be the first write for a day, before any `DailySummary` exists. Both implementations create the doc with zero `totals` and `mealCount` 0 so the summary stays well-formed; `DailySummary.fromMap` also defaults these fields defensively.
- **Aggregate drift** → `totals`/`mealCount` are write-only increments with no meal edit/delete or recompute path (Non-Goals). A future failed correction could desync the summary from entries; revisit with a reconcile job when edit/delete lands.
- **Integer macros** → `NutritionEntry` fields are `int`; per-meal rounding then summing can drift the daily total slightly. Acceptable for MVP; widening to `double` later is a schema migration.

## Migration Plan

Data-layer only change. No existing Firestore documents are modified. New collections are additive. No migration required.

Rollout: ship new models + repository methods. UI screens can start reading real data as soon as this lands. InMemory fallback continues to work for offline/demo mode.
