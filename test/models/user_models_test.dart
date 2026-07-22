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

  test('UserProfile.demoAngela includes default nutrition targets', () {
    final profile = UserProfile.demoAngela(userId: 'abc123', now: now);
    expect(profile.displayName, 'Angela');
    expect(profile.primarySportId, 'tennis');
    expect(profile.teamProgramName, 'Lincoln High Tennis Program');
    expect(profile.dailyTargets.caloriesKcal, 3200);
    expect(profile.dailyTargets.hydrationLiters, 3.5);
  });

  test('UserProfile round-trips segment control style', () {
    final profile = UserProfile.demoAngela(
      userId: 'abc123',
      now: now,
    ).copyWith(segmentControlStyle: SegmentControlStyle.classicPill);

    final restored = UserProfile.fromMap(profile.toMap(), userId: 'abc123');

    expect(profile.toMap()['segmentControlStyle'], 'classic_pill');
    expect(restored.segmentControlStyle, SegmentControlStyle.classicPill);
  });

  test('UserProfile defaults segment control style to minimal tabs', () {
    final map = UserProfile.demoAngela(userId: 'abc123', now: now).toMap()
      ..remove('segmentControlStyle');

    final restored = UserProfile.fromMap(map, userId: 'abc123');

    expect(restored.segmentControlStyle, SegmentControlStyle.minimalTabs);
  });

  test('UserProfile round-trips sleep mode onboarding preference', () {
    final profile = UserProfile.demoAngela(userId: 'abc123', now: now).copyWith(
      sleepModeEnabled: true,
      sleepModeRecommended: true,
      sleepModeRecommendationReasons: [
        'You often wake up tired.',
        'Sleep reminders could support recovery.',
      ],
    );

    final restored = UserProfile.fromMap(profile.toMap(), userId: 'abc123');

    expect(restored.sleepModeEnabled, true);
    expect(restored.sleepModeRecommended, true);
    expect(
      restored.sleepModeRecommendationReasons,
      contains('You often wake up tired.'),
    );
  });

  test('UserProfile defaults missing sleep mode fields to disabled', () {
    final map = UserProfile.demoAngela(userId: 'abc123', now: now).toMap()
      ..remove('sleepModeEnabled')
      ..remove('sleepModeRecommended')
      ..remove('sleepModeRecommendationReasons');

    final restored = UserProfile.fromMap(map, userId: 'abc123');

    expect(restored.sleepModeEnabled, false);
    expect(restored.sleepModeRecommended, false);
    expect(restored.sleepModeRecommendationReasons, isEmpty);
  });

  test('UserProfile round-trips display preferences', () {
    final profile = UserProfile.demoAngela(userId: 'abc123', now: now).copyWith(
      accessibilityModeEnabled: true,
      textScale: AppTextScale.large,
      themePalette: AppThemePalette.ocean,
    );

    final restored = UserProfile.fromMap(profile.toMap(), userId: 'abc123');

    expect(restored.accessibilityModeEnabled, true);
    expect(restored.textScale, AppTextScale.large);
    expect(restored.themePalette, AppThemePalette.ocean);
  });

  test('UserProfile defaults display preferences', () {
    final map = UserProfile.demoAngela(userId: 'abc123', now: now).toMap()
      ..remove('accessibilityModeEnabled')
      ..remove('textScale')
      ..remove('themePalette');

    final restored = UserProfile.fromMap(map, userId: 'abc123');

    expect(restored.accessibilityModeEnabled, false);
    expect(restored.textScale, AppTextScale.medium);
    expect(restored.themePalette, AppThemePalette.classic);
  });

  test('UserProfile round-trips usual sleep schedule times', () {
    final profile = UserProfile.demoAngela(
      userId: 'abc123',
      now: now,
    ).copyWith(usualBedtimeMinutes: 22 * 60 + 30, usualWakeTimeMinutes: 390);

    final restored = UserProfile.fromMap(profile.toMap(), userId: 'abc123');

    expect(restored.usualBedtimeMinutes, 1350);
    expect(restored.usualWakeTimeMinutes, 390);
  });

  test('UserProfile defaults missing usual sleep schedule times to null', () {
    final map = UserProfile.demoAngela(userId: 'abc123', now: now).toMap()
      ..remove('usualBedtimeMinutes')
      ..remove('usualWakeTimeMinutes');

    final restored = UserProfile.fromMap(map, userId: 'abc123');

    expect(restored.usualBedtimeMinutes, isNull);
    expect(restored.usualWakeTimeMinutes, isNull);
  });

  test('UserProfile round-trips custom bedtime preset items', () {
    final profile = UserProfile.demoAngela(
      userId: 'abc123',
      now: now,
    ).copyWith(customBedtimePresetMinutes: [1260, 1325, 1380]);

    final restored = UserProfile.fromMap(profile.toMap(), userId: 'abc123');

    expect(restored.customBedtimePresetMinutes, [1260, 1325, 1380]);
  });

  test('UserProfile defaults missing custom bedtime items to empty', () {
    final map = UserProfile.demoAngela(userId: 'abc123', now: now).toMap()
      ..remove('customBedtimePresetMinutes');

    final restored = UserProfile.fromMap(map, userId: 'abc123');

    expect(restored.customBedtimePresetMinutes, isEmpty);
  });

  test('UserProfile defaults missing schedule events to empty', () {
    final map = UserProfile.demoAngela(userId: 'abc123', now: now).toMap()
      ..remove('scheduleEvents');

    final restored = UserProfile.fromMap(map, userId: 'abc123');

    expect(restored.scheduleEvents, isEmpty);
  });

  test('UserProfile round-trips schedule events', () {
    final event = UserScheduleEvent(
      eventId: 'event_001',
      type: ScheduleEventType.match,
      startAt: DateTime.utc(2026, 6, 20, 23),
      title: 'Home athlete vs Rivera',
      subtitle: '~2h',
      location: 'Lincoln Courts',
      badge: 'CONFERENCE FINALS',
      fuelingHints: const [
        FuelingHint(timing: '3H BEFORE', label: 'Big Carbs'),
        FuelingHint(timing: '1H BEFORE', label: 'Light Snack'),
      ],
    );
    final profile = UserProfile.demoAngela(
      userId: 'abc123',
      now: now,
    ).copyWith(scheduleEvents: [event]);

    final map = profile.toMap();
    final restored = UserProfile.fromMap(map, userId: 'abc123');

    expect(map['scheduleEvents'], isA<List<dynamic>>());
    expect(restored.scheduleEvents, hasLength(1));
    expect(restored.scheduleEvents.single.eventId, 'event_001');
    expect(restored.scheduleEvents.single.type, ScheduleEventType.match);
    expect(restored.scheduleEvents.single.title, 'Home athlete vs Rivera');
    expect(restored.scheduleEvents.single.location, 'Lincoln Courts');
    expect(restored.scheduleEvents.single.fuelingHints, hasLength(2));
  });

  test('catalog seed sport and team program parse', () {
    final sport = CatalogSeedData.tennisSport(effectiveFrom: now);
    final team = CatalogSeedData.lincolnHighTennis();
    expect(
      SportProfile.fromMap(sport.toMap(), sportId: sport.sportId).displayName,
      'Tennis',
    );
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

    final account = await repo.signInAnonymously(
      timezone: 'America/Los_Angeles',
    );
    expect(account.onboardingCompleted, false);

    final profile = UserProfile.demoAngela(userId: account.uid, now: now);
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

  test('InMemoryUserRepository creates and signs in email accounts', () async {
    final repo = InMemoryUserRepository();

    final created = await repo.createAccountWithEmail(
      email: 'athlete@example.com',
      password: 'secret123',
      timezone: 'America/Los_Angeles',
    );

    expect(created.email, 'athlete@example.com');
    expect(created.authProviders, ['password']);
    expect(created.isAnonymous, false);

    await repo.signOut();
    final signedIn = await repo.signInWithEmail(
      email: 'athlete@example.com',
      password: 'secret123',
      timezone: 'America/Los_Angeles',
    );

    expect(signedIn.uid, created.uid);
    expect(repo.currentUid, created.uid);
  });

  test(
    'InMemoryUserRepository upgrades anonymous account with email',
    () async {
      final repo = InMemoryUserRepository();
      final guest = await repo.signInAnonymously(
        timezone: 'America/Los_Angeles',
      );

      final upgraded = await repo.linkEmail(
        uid: guest.uid,
        email: 'guest@example.com',
        password: 'secret123',
      );

      expect(upgraded.uid, guest.uid);
      expect(upgraded.email, 'guest@example.com');
      expect(upgraded.authProviders, ['password']);
      expect(upgraded.isAnonymous, false);
    },
  );

  test('InMemoryUserRepository deleteAccount removes user data', () async {
    final repo = InMemoryUserRepository();
    final account = await repo.createAccountWithEmail(
      email: 'delete@example.com',
      password: 'secret123',
      timezone: 'America/Los_Angeles',
    );
    await repo.completeOnboarding(
      uid: account.uid,
      profile: UserProfile.demoAngela(userId: account.uid, now: now),
    );
    await repo.logMeal(
      account.uid,
      Meal(
        name: 'Breakfast',
        nutrition: const NutritionEntry(
          caloriesKcal: 400,
          proteinG: 30,
          carbsG: 50,
          fatsG: 10,
        ),
        source: MealSource.manual,
        loggedAt: now,
      ),
      'America/Los_Angeles',
    );

    await repo.deleteAccount(account.uid);

    expect(repo.currentUid, isNull);
    expect(await repo.getAccount(account.uid), isNull);
    expect(await repo.getProfile(account.uid), isNull);
    expect(
      await repo.getRecentMeals(
        account.uid,
        limit: 10,
        timezone: 'America/Los_Angeles',
      ),
      isEmpty,
    );

    await expectLater(
      () => repo.signInWithEmail(
        email: 'delete@example.com',
        password: 'secret123',
        timezone: 'America/Los_Angeles',
      ),
      throwsA(isA<StateError>()),
    );
  });
}
