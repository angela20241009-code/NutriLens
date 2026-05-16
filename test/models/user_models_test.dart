import 'package:flutter_test/flutter_test.dart';
import 'package:nutrilens/data/catalog_seed_data.dart';
import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/services/in_memory_user_repository.dart';

void main() {
  final now = DateTime.utc(2026, 5, 16, 12);

  test('UserAccount round-trips through map', () {
    final account = UserAccount.anonymousShell(uid: 'abc123', now: now);
    final restored = UserAccount.fromMap(account.toMap(), uid: 'abc123');
    expect(restored.uid, 'abc123');
    expect(restored.authProviders, ['anonymous']);
    expect(restored.onboardingCompleted, false);
  });

  test('UserProfile.demoAngela matches mock home targets', () {
    final profile = UserProfile.demoAngela(userId: 'abc123', now: now);
    expect(profile.displayName, 'Angela');
    expect(profile.primarySportId, 'tennis');
    expect(profile.teamProgramName, 'Lincoln High Tennis Program');
    expect(profile.dailyTargets.caloriesKcal, 3200);
    expect(profile.dailyTargets.hydrationLiters, 3.5);
  });

  test('catalog seed sport and team program parse', () {
    final sport = CatalogSeedData.tennisSport(effectiveFrom: now);
    final team = CatalogSeedData.lincolnHighTennis();
    expect(SportProfile.fromMap(sport.toMap(), sportId: sport.sportId).displayName,
        'Tennis');
    expect(
      TeamProgram.fromMap(team.toMap(), programId: team.programId).tier,
      'FREE',
    );
  });

  test('InMemoryUserRepository anonymous sign-in and onboarding', () async {
    final repo = InMemoryUserRepository();
    repo.seedCatalog(
      sportProfile: CatalogSeedData.tennisSport(effectiveFrom: now),
      teamProgram: CatalogSeedData.lincolnHighTennis(),
    );

    final account = await repo.signInAnonymously(timezone: 'America/Los_Angeles');
    expect(account.onboardingCompleted, false);

    final profile = UserProfile.demoAngela(
      userId: account.uid,
      now: now,
    );
    final completed = await repo.completeOnboarding(
      uid: account.uid,
      profile: profile,
    );
    expect(completed.onboardingStep, 'completed');

    final savedAccount = await repo.getAccount(account.uid);
    expect(savedAccount?.onboardingCompleted, true);

    final sport = await repo.getSportProfile(CatalogSeedData.tennisSportId);
    expect(sport?.defaultDailyTargets.caloriesKcal, 3200);
  });
}
