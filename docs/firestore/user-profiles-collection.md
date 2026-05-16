# Firestore: `userProfiles/{uid}`

Primary athlete profile store for Profile, Home, and Onboarding. Document ID **must equal** `request.auth.uid`.

## Identity and presentation

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `userId` | string | yes | Same as document ID |
| `displayName` | string | yes | Greeting / profile name |
| `firstName` | string \| null | no | |
| `lastName` | string \| null | no | |
| `avatarStoragePath` | string \| null | no | Firebase Storage path |
| `avatarUrl` | string \| null | no | Cached download URL |

## Student-athlete context

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `schoolName` | string \| null | no | |
| `graduationYear` | number \| null | no | Prefer year over full DOB |
| `timezone` | string | yes | IANA, e.g. `America/Los_Angeles` |
| `locale` | string | no | Default `en-US` |

## Sport and program

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `primarySportId` | string | yes | Catalog key, e.g. `tennis` |
| `primarySportName` | string | yes | Denormalized display label |
| `secondarySportIds` | array&lt;string&gt; | no | |
| `teamProgramId` | string \| null | no | → `teamPrograms/{id}` |
| `teamProgramName` | string \| null | no | Denormalized |
| `programTier` | string \| null | no | `FREE`, `PRO`, etc. |
| `role` | string | yes | Default `athlete` |

## Body and activity (onboarding)

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `sex` | string \| null | no | Optional metabolic input |
| `birthYear` | number \| null | no | |
| `heightCm` | number \| null | no | |
| `weightKg` | number \| null | no | |
| `activityLevel` | string \| null | no | `moderate`, `high`, … |
| `trainingDaysPerWeek` | number \| null | no | |

## Active nutrition targets

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `dailyTargets` | map | yes | Current targets (see below) |
| `activeGoalId` | string \| null | no | Future → `nutritionGoals/{id}` |

### `dailyTargets` map

```json
{
  "caloriesKcal": 3200,
  "proteinG": 180,
  "carbsG": 440,
  "fatsG": 90,
  "hydrationLiters": 3.5,
  "sleepHours": 8,
  "source": "sport_defaults",
  "effectiveFrom": "<timestamp>"
}
```

`source`: `onboarding` \| `sport_defaults` \| `coach_override` \| `manual`

**Onboarding write path:** read `sportProfiles/{sportId}` → copy/adjust `defaultDailyTargets` → write `userProfiles/{uid}.dailyTargets`.

## Dietary profile

```json
{
  "allergens": ["peanut", "dairy"],
  "restrictions": ["vegetarian"],
  "preferences": ["high_protein"],
  "notes": ""
}
```

Use canonical snake_case keys in storage; map to display labels in the app.

## Nutrition settings

```json
{
  "unitSystem": "metric",
  "mealRemindersEnabled": true,
  "preWorkoutReminderEnabled": true,
  "matchDayModeEnabled": true
}
```

## Health sync

```json
{
  "appleHealthEnabled": false,
  "googleFitEnabled": false,
  "lastSyncAt": null,
  "scopesGranted": []
}
```

No raw health payloads in Firestore for MVP.

## Optional stats cache

| Field | Type | Notes |
|-------|------|-------|
| `statsCache` | map \| null | `{ currentStreak, mealsLoggedTotal, fuelScore }` |
| `statsCacheUpdatedAt` | timestamp \| null | |

Prefer computing from `meals` / `insights` later; cache only if needed for demo latency.

## Onboarding audit

| Field | Type | Notes |
|-------|------|-------|
| `onboardingStep` | string \| null | `sport_selected`, `targets_reviewed`, `completed` |
| `onboardingCompletedAt` | timestamp \| null | |
| `createdAt` | timestamp | |
| `updatedAt` | timestamp | |

## Example document (demo persona)

See seed in [`firebase/seed/README.md`](../../firebase/seed/README.md) and `UserProfile.demoAngela` in Dart.

## Out of scope (stored elsewhere)

| Data | Collection |
|------|------------|
| Daily calorie progress | Derived from `meals` |
| Meal plan items | `meals` |
| Schedule / next session | `scheduleEvents` |
| Weekly fuel trends | `insights` |
| Goal version history | `nutritionGoals` |

## Dart model

[`lib/models/user_profile.dart`](../../lib/models/user_profile.dart)

## Repository

[`lib/services/user_repository.dart`](../../lib/services/user_repository.dart) — `completeOnboarding`, `saveProfile`, `getProfile`
