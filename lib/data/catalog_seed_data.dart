import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/services/firestore_serializer.dart';

/// Reference catalog documents for Firestore seeding and in-memory demos.
abstract final class CatalogSeedData {
  static const tennisSportId = 'tennis';
  static const lincolnHighTennisProgramId = 'lincoln_high_tennis';

  static SportProfile tennisSport({DateTime? effectiveFrom}) {
    final now = effectiveFrom ?? firestoreNow();
    return SportProfile(
      sportId: tennisSportId,
      displayName: 'Tennis',
      iconAsset: 'assets/images/sport_tennis.png',
      defaultDailyTargets: DailyTargets(
        caloriesKcal: 3200,
        proteinG: 180,
        carbsG: 440,
        fatsG: 90,
        hydrationLiters: 3.5,
        sleepHours: 8,
        source: DailyTargetsSource.sportDefaults,
        effectiveFrom: now,
      ),
      fuelingWindowTemplateIds: const [
        'pre_practice_carbs',
        'match_day_hydration',
        'post_match_protein',
      ],
      activityLevelHints: const ['moderate', 'high'],
    );
  }

  static TeamProgram lincolnHighTennis() {
    return const TeamProgram(
      programId: lincolnHighTennisProgramId,
      name: 'Lincoln High Tennis Program',
      schoolName: 'Lincoln High',
      tier: 'FREE',
      primarySportId: tennisSportId,
      memberCount: 24,
    );
  }

  static Map<String, Map<String, dynamic>> allFirestoreSeedDocs() {
    final now = firestoreNow();
    return {
      'sportProfiles/$tennisSportId': tennisSport(effectiveFrom: now).toMap(),
      'teamPrograms/$lincolnHighTennisProgramId': lincolnHighTennis().toMap(),
    };
  }
}
