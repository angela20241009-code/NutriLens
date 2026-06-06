## ADDED Requirements

### Requirement: Log a meal entry
The system SHALL allow a logged-in user to persist a meal entry containing a name, nutrition values, source type, optional photo storage path, optional notes, and a timestamp. The entry SHALL be stored at `meals/{uid}/entries/{mealId}` in Firestore. The `mealId` SHALL be a Firestore auto-generated document ID. The signature SHALL be `logMeal(uid, meal, timezone)`; the `timezone` (IANA name) is used to derive the `dateKey` for the day's `DailySummary`.

#### Scenario: Log a manual meal
- **WHEN** `logMeal(uid, meal, timezone)` is called with a valid `Meal` object whose source is `MealSource.manual`
- **THEN** a document is written to `meals/{uid}/entries/{mealId}` with all fields serialized
- **THEN** the method returns the saved `Meal` with the assigned `mealId`

#### Scenario: Log a meal with a photo
- **WHEN** `logMeal(uid, meal, timezone)` is called with a non-null `photoStoragePath`
- **THEN** the document is written with `photoStoragePath` set to the provided value
- **THEN** no upload is performed by `logMeal` — the caller is responsible for uploading the photo to Storage before calling `logMeal`

#### Scenario: Log fails due to network error
- **WHEN** `logMeal(uid, meal, timezone)` is called and the Firestore transaction throws
- **THEN** the exception propagates to the caller unchanged
- **THEN** neither the meal entry nor the summary update is committed (no partial document remains)

### Requirement: Retrieve meals for a day
The system SHALL allow retrieval of all meal entries for a given user on a given calendar day, ordered by timestamp ascending. The day boundary SHALL be computed using the user's timezone.

#### Scenario: Meals exist for the requested day
- **WHEN** `getMealsForDay(uid, date, timezone)` is called for a day that has logged meals
- **THEN** all meals whose timestamp falls within that calendar day (in the given timezone) are returned in ascending timestamp order

#### Scenario: No meals logged for the requested day
- **WHEN** `getMealsForDay(uid, date, timezone)` is called for a day with no entries
- **THEN** an empty list is returned

### Requirement: Meal model fields
The `Meal` model SHALL contain:
- `mealId`: nullable String (null before persisted)
- `name`: String (non-empty)
- `nutrition`: `NutritionEntry` (calories, protein, carbs, fats — all non-negative)
- `source`: `MealSource` enum (`manual`, `scan`, `mealPlan`)
- `loggedAt`: DateTime (UTC)
- `photoStoragePath`: nullable String
- `notes`: nullable String

#### Scenario: Meal serializes and deserializes round-trip
- **WHEN** a `Meal` is converted to a map via `toMap()` and back via `Meal.fromMap()`
- **THEN** all fields are equal to the original values

#### Scenario: Unknown MealSource defaults to manual
- **WHEN** `Meal.fromMap()` encounters an unrecognized `source` string
- **THEN** `source` is set to `MealSource.manual`

### Requirement: NutritionEntry value object
The `NutritionEntry` model SHALL contain:
- `caloriesKcal`: int (non-negative)
- `proteinG`: int (non-negative)
- `carbsG`: int (non-negative)
- `fatsG`: int (non-negative)

It SHALL expose an `operator +` that sums two `NutritionEntry` instances field-by-field.

#### Scenario: Adding two NutritionEntry instances
- **WHEN** `NutritionEntry(200, 20, 25, 5) + NutritionEntry(100, 10, 15, 3)` is computed
- **THEN** the result is `NutritionEntry(300, 30, 40, 8)`
