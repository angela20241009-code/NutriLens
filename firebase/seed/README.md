# Firestore catalog seed data

Import these documents into project `nutrilens-817c0` (or your Firebase project) before onboarding demos.

## Documents

| Path | Source file |
|------|-------------|
| `sportProfiles/tennis` | [`sportProfiles_tennis.json`](sportProfiles_tennis.json) |
| `teamPrograms/lincoln_high_tennis` | [`teamPrograms_lincoln_high_tennis.json`](teamPrograms_lincoln_high_tennis.json) |

## Firebase Console

1. Open Firestore → **Start collection** (or add to existing).
2. Collection ID: `sportProfiles`, Document ID: `tennis`, paste JSON fields from `sportProfiles_tennis.json`.
3. Collection ID: `teamPrograms`, Document ID: `lincoln_high_tennis`, paste from `teamPrograms_lincoln_high_tennis.json`.

## Firebase CLI

```bash
firebase deploy --only firestore:rules
```

To import seed docs (requires [Firestore import](https://firebase.google.com/docs/firestore/manage-data/export-import) or a one-off script). For quick local dev, use the matching Dart constants in [`lib/data/catalog_seed_data.dart`](../../lib/data/catalog_seed_data.dart) with `InMemoryUserRepository.seedCatalog()`.

## Security rules

Catalog collections are **read-only** for authenticated clients. See [`firestore.rules`](../../firestore.rules).
