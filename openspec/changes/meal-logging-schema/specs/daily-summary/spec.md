## ADDED Requirements

### Requirement: Read a daily summary
The system SHALL allow retrieval of a pre-aggregated `DailySummary` document for a given user and calendar day. The document is stored at `dailySummaries/{uid}/days/{dateKey}` where `dateKey` is `yyyy-MM-dd` in the user's local timezone.

#### Scenario: Summary exists for the day
- **WHEN** `getDailySummary(uid, dateKey)` is called and a document exists
- **THEN** a `DailySummary` is returned with all fields populated

#### Scenario: No summary for the day
- **WHEN** `getDailySummary(uid, dateKey)` is called and no document exists
- **THEN** `null` is returned

### Requirement: Update daily summary atomically on meal log
The system SHALL update the `DailySummary` for the meal's calendar day as part of the same `logMeal` operation. The update SHALL be performed in a Firestore transaction so that the meal entry and summary are consistent.

#### Scenario: First meal of the day
- **WHEN** `logMeal` is called and no `DailySummary` exists for that day
- **THEN** a new `DailySummary` document is created with the meal's nutrition values
- **THEN** `mealCount` is set to 1

#### Scenario: Subsequent meal of the day
- **WHEN** `logMeal` is called and a `DailySummary` already exists for that day
- **THEN** the existing summary's `totals` fields are incremented by the meal's nutrition values
- **THEN** `mealCount` is incremented by 1

#### Scenario: Transaction failure commits neither write
- **WHEN** the Firestore transaction for `logMeal` fails (the transaction buffers both writes and commits atomically)
- **THEN** neither the meal entry nor the summary update is persisted
- **THEN** the exception propagates to the caller

### Requirement: DailySummary model fields
The `DailySummary` model SHALL contain:
- `uid`: String
- `dateKey`: String (`yyyy-MM-dd` in user's local timezone)
- `totals`: `NutritionEntry` (sum of all logged meals for the day)
- `mealCount`: int (number of meals logged)
- `hydrationLiters`: double (tracked separately, not from meal entries)
- `sleepHours`: double (tracked separately, not from meal entries)
- `updatedAt`: DateTime (UTC, set on every write)

#### Scenario: DailySummary serializes and deserializes round-trip
- **WHEN** a `DailySummary` is converted to a map via `toMap()` and back via `DailySummary.fromMap()`
- **THEN** all fields are equal to the original values

#### Scenario: Missing aggregate fields default safely
- **WHEN** `DailySummary.fromMap()` parses a document with no `totals` or `mealCount` (e.g. one created by a hydration-only write)
- **THEN** `totals` defaults to a zero `NutritionEntry` and `mealCount` defaults to 0

#### Scenario: dateKey format (summer, DST in effect)
- **WHEN** `dateKey` is derived for a meal logged at `2026-06-06T23:30:00Z` in timezone `America/Los_Angeles` (PDT, UTC-7)
- **THEN** `dateKey` is `2026-06-06` (the local date in that timezone)

#### Scenario: dateKey format (winter, no DST)
- **WHEN** `dateKey` is derived for a meal logged at `2026-01-01T05:30:00Z` in timezone `America/Los_Angeles` (PST, UTC-8)
- **THEN** `dateKey` is `2025-12-31` (the local date — the fixed-offset approach would give the wrong day)

### Requirement: Update hydration and sleep on daily summary
The system SHALL expose `updateDailySummary(uid, dateKey, {hydrationLiters, sleepHours})` to allow the home dashboard and sleep screen to write hydration and sleep data independently of meal logging.

#### Scenario: Update hydration only
- **WHEN** `updateDailySummary(uid, dateKey, hydrationLiters: 2.5)` is called and a summary already exists
- **THEN** only `hydrationLiters` and `updatedAt` are updated in Firestore
- **THEN** `totals`, `mealCount`, and `sleepHours` are unchanged

#### Scenario: Update with no existing summary creates a well-formed document
- **WHEN** `updateDailySummary(uid, dateKey, hydrationLiters: 2.5)` is called and no `DailySummary` exists for that day
- **THEN** a new document is created with `uid`, `dateKey`, the provided `hydrationLiters`, and `updatedAt`
- **THEN** `totals` is a zero `NutritionEntry`, `mealCount` is 0, and `sleepHours` is 0
- **THEN** the Firestore and in-memory implementations behave identically
