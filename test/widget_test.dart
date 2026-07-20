import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrilens/app.dart';
import 'package:nutrilens/app/app_settings_scope.dart';
import 'package:nutrilens/app/meal_plan_scope.dart';
import 'package:nutrilens/app/session_scope.dart';
import 'package:nutrilens/app/user_scope.dart';
import 'package:nutrilens/data/catalog_seed_data.dart';
import 'package:nutrilens/features/auth/auth_screen.dart';
import 'package:nutrilens/features/meals/meals_screen.dart';
import 'package:nutrilens/features/onboarding/onboarding_flow.dart';
import 'package:nutrilens/features/profile/account_settings_screen.dart';
import 'package:nutrilens/features/profile/profile_screen.dart';
import 'package:nutrilens/features/scan/scan_previous_meals_sheet.dart';
import 'package:nutrilens/features/schedule/schedule_screen.dart';
import 'package:nutrilens/features/schedule/schedule_view_filter.dart';
import 'package:nutrilens/features/schedule/widgets/month_date_selector.dart';
import 'package:nutrilens/features/schedule/widgets/week_date_selector.dart';
import 'package:nutrilens/features/shell/app_shell.dart';
import 'package:nutrilens/features/sleep/sleep_dashboard_screen.dart';
import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/services/meal_plan_client.dart';
import 'package:nutrilens/services/in_memory_user_repository.dart';
import 'package:nutrilens/theme/app_theme.dart';

void main() {
  testWidgets('Auth screen shows email auth and guest options', (
    WidgetTester tester,
  ) async {
    var createCalled = false;
    var signInCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: AuthScreen(
          onCreateAccount: (_, _, __) async => createCalled = true,
          onSignIn: (_, _) async => signInCalled = true,
          onContinueAsGuest: (_) async {},
        ),
      ),
    );

    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Sign in'), findsWidgets);
    expect(find.text('Continue as guest'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'athlete@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'secret123',
    );
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pump();

    expect(createCalled, true);
    expect(signInCalled, false);
  });

  testWidgets('Onboarding recommends and saves Sleep Mode opt-in', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryUserRepository();
    final account = await repository.signInAnonymously(
      timezone: 'America/Los_Angeles',
    );

    await _pumpOnboarding(tester, repository, account.uid);

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Angela');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tennis'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await _completeOnboardingMealPrefsStep(tester);

    expect(find.text('Sleep recovery'), findsOneWidget);
    expect(find.text('Daily nutrition targets'), findsNothing);

    await tester.tap(find.text('Most days'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Often'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Yes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Sleep Mode recommended'));
    await tester.pumpAndSettle();
    expect(find.text('Sleep Mode recommended'), findsOneWidget);

    await tester.ensureVisible(find.text('Use Sleep Mode'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Use Sleep Mode'));
    await tester.pumpAndSettle();

    await _completeOnboardingBodyStep(tester);

    expect(find.text('Daily nutrition targets'), findsOneWidget);

    await tester.tap(find.text('Finish setup'));
    await tester.pumpAndSettle();

    final profile = await repository.getProfile(account.uid);
    expect(profile?.sleepModeEnabled, true);
    expect(profile?.sleepModeRecommended, true);
    expect(profile?.sleepModeRecommendationReasons, isNotEmpty);
    expect(profile?.heightCm, 175);
    expect(profile?.weightKg, 70);
  });

  testWidgets('Onboarding can skip Sleep Mode after low-need answers', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryUserRepository();
    final account = await repository.signInAnonymously(
      timezone: 'America/Los_Angeles',
    );

    await _pumpOnboarding(tester, repository, account.uid);

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Angela');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tennis'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await _completeOnboardingMealPrefsStep(tester);

    await tester.tap(find.text('Rarely').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rarely').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('No'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('No'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Sleep Mode is optional'));
    await tester.pumpAndSettle();
    expect(find.text('Sleep Mode is optional'), findsOneWidget);

    await tester.ensureVisible(find.text('Skip for now'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip for now'));
    await tester.pumpAndSettle();
    await _completeOnboardingBodyStep(tester);
    await tester.tap(find.text('Finish setup'));
    await tester.pumpAndSettle();

    final profile = await repository.getProfile(account.uid);
    expect(profile?.sleepModeEnabled, false);
    expect(profile?.sleepModeRecommended, false);
    expect(profile?.sleepModeRecommendationReasons, isEmpty);
    expect(profile?.heightCm, 175);
    expect(profile?.weightKg, 70);
  });

  testWidgets('App shell gates Sleep mode by profile preference', (
    WidgetTester tester,
  ) async {
    final disabledRepository = InMemoryUserRepository();
    final disabledAccount = await disabledRepository.signInAnonymously(
      timezone: 'America/Los_Angeles',
    );
    await disabledRepository.completeOnboarding(
      uid: disabledAccount.uid,
      profile: UserProfile.demoAngela(
        userId: disabledAccount.uid,
        now: DateTime.now().toUtc(),
      ),
    );

    await _pumpAppShell(tester, disabledRepository, disabledAccount.uid);
    expect(find.text('Meal Tracking'), findsNothing);
    expect(find.text('Sleep'), findsNothing);

    final enabledRepository = InMemoryUserRepository();
    final enabledAccount = await enabledRepository.signInAnonymously(
      timezone: 'America/Los_Angeles',
    );
    await enabledRepository.completeOnboarding(
      uid: enabledAccount.uid,
      profile: UserProfile.demoAngela(
        userId: enabledAccount.uid,
        now: DateTime.now().toUtc(),
      ).copyWith(sleepModeEnabled: true),
    );

    await _pumpAppShell(tester, enabledRepository, enabledAccount.uid);
    expect(find.text('Meal Tracking'), findsOneWidget);
    expect(find.text('Sleep'), findsOneWidget);
  });

  testWidgets('Settings shows Sleep Mode toggle off and enables it', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryUserRepository();
    final account = await repository.signInAnonymously(
      timezone: 'America/Los_Angeles',
    );
    await repository.completeOnboarding(
      uid: account.uid,
      profile: UserProfile.demoAngela(
        userId: account.uid,
        now: DateTime.now().toUtc(),
      ),
    );

    await _pumpAccountSettings(tester, repository, account.uid);

    expect(find.text('Sleep Mode'), findsOneWidget);
    expect(tester.widget<Switch>(find.byType(Switch)).value, false);
    expect(find.text('Mode switcher'), findsNothing);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Units'), findsOneWidget);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    final profile = await repository.getProfile(account.uid);
    expect(profile?.sleepModeEnabled, true);
    expect(tester.widget<Switch>(find.byType(Switch)).value, true);
    expect(find.text('Mode switcher'), findsOneWidget);
  });

  testWidgets('Settings shows Sleep Mode toggle on and disables it', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryUserRepository();
    final account = await repository.signInAnonymously(
      timezone: 'America/Los_Angeles',
    );
    await repository.completeOnboarding(
      uid: account.uid,
      profile: UserProfile.demoAngela(
        userId: account.uid,
        now: DateTime.now().toUtc(),
      ).copyWith(sleepModeEnabled: true),
    );

    await _pumpAccountSettings(tester, repository, account.uid);

    expect(find.text('Sleep Mode'), findsOneWidget);
    expect(tester.widget<Switch>(find.byType(Switch)).value, true);
    expect(find.text('Mode switcher'), findsOneWidget);
    expect(find.text('Minimal tabs'), findsOneWidget);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    final profile = await repository.getProfile(account.uid);
    expect(profile?.sleepModeEnabled, false);
    expect(tester.widget<Switch>(find.byType(Switch)).value, false);
    expect(find.text('Mode switcher'), findsNothing);
  });

  testWidgets(
    'Sleep dashboard asks for schedule when sleep times are missing',
    (WidgetTester tester) async {
      final repository = InMemoryUserRepository();
      final account = await repository.signInAnonymously(
        timezone: 'America/Los_Angeles',
      );
      await repository.completeOnboarding(
        uid: account.uid,
        profile: UserProfile.demoAngela(
          userId: account.uid,
          now: DateTime.now().toUtc(),
        ).copyWith(sleepModeEnabled: true),
      );

      await _pumpSleepDashboard(tester, repository, account.uid);

      expect(find.text('Set your sleep schedule'), findsOneWidget);
      expect(find.textContaining('track sleep statistics'), findsOneWidget);
      expect(find.text('BEDTIME'), findsOneWidget);
      expect(find.text('WAKE TIME'), findsOneWidget);
      expect(find.text('Save sleep schedule'), findsOneWidget);
    },
  );

  testWidgets('Sleep dashboard shows wake-time planning for saved schedule', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryUserRepository();
    final account = await repository.signInAnonymously(
      timezone: 'America/Los_Angeles',
    );
    await repository.completeOnboarding(
      uid: account.uid,
      profile:
          UserProfile.demoAngela(
            userId: account.uid,
            now: DateTime.now().toUtc(),
          ).copyWith(
            sleepModeEnabled: true,
            usualBedtimeMinutes: 22 * 60 + 30,
            usualWakeTimeMinutes: 6 * 60 + 30,
          ),
    );

    await _pumpSleepDashboard(tester, repository, account.uid);

    expect(find.text('Wake-time planning'), findsOneWidget);
    expect(find.text('Target sleep'), findsOneWidget);
    expect(find.text('8h'), findsOneWidget);
    expect(find.text('Tonight bedtime'), findsOneWidget);
    expect(find.text('10:30 PM'), findsWidgets);
    expect(find.text('Wake time'), findsWidgets);
    expect(find.text('6:30 AM'), findsWidgets);
  });

  testWidgets('Guest profile create account unlocks profile editing', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryUserRepository();
    final account = await repository.signInAnonymously(
      timezone: 'America/Los_Angeles',
    );

    await tester.pumpWidget(
      UserScope(
        repository: repository,
        uid: account.uid,
        child: MaterialApp(theme: AppTheme.dark, home: const ProfileScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Create an account'), findsOneWidget);

    await tester.tap(find.text('Create account'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'guest@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'secret123',
    );
    await tester.tap(find.text('Create'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Full name'), findsOneWidget);
    final upgraded = await repository.getAccount(account.uid);
    expect(upgraded?.isAnonymous, false);
  });

  testWidgets('Meal dashboard loads and regenerates', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryUserRepository();
    repository.seedCatalog(
      sportProfile: CatalogSeedData.tennisSport(),
      teamProgram: CatalogSeedData.lincolnHighTennis(),
    );
    final account = await repository.signInAnonymously(
      timezone: 'America/Los_Angeles',
    );
    await repository.completeOnboarding(
      uid: account.uid,
      profile: UserProfile.demoAngela(
        userId: account.uid,
        now: DateTime.now().toUtc(),
      ),
    );

    final mealPlanClient = _FakeMealPlanClient();

    await tester.pumpWidget(
      MealPlanScope(
        client: mealPlanClient,
        child: UserScope(
          repository: repository,
          uid: account.uid,
          child: AppSettingsScope(
            repository: repository,
            uid: account.uid,
            child: const NutriLensApp(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);

    await tester.tap(find.text('Meals'));
    await tester.pumpAndSettle();

    expect(find.text('Meal Plan'), findsOneWidget);
    expect(find.text('New Meal Plan'), findsOneWidget);
    expect(mealPlanClient.callCount, 2);

    await tester.tap(find.text('New Meal Plan'));
    await tester.pumpAndSettle();

    expect(mealPlanClient.callCount, 3);
    await tester.dragUntilVisible(
      find.text('Recovery Oats & Fruit'),
      _mealsScrollable(),
      const Offset(0, -300),
      maxIteration: 20,
    );
    expect(find.text('Recovery Oats & Fruit'), findsOneWidget);
    expect(find.text('Source: Allrecipes'), findsWidgets);

    await tester.tap(find.text('Schedule'));
    await tester.pumpAndSettle();

    expect(find.text('Schedule'), findsWidgets);
    expect(find.text('This week'), findsOneWidget);
    expect(find.text('Timeline'), findsOneWidget);
    expect(find.text('No events or logged meals for this day.'), findsOneWidget);
    expect(find.text("Today's Match"), findsNothing);
    expect(find.text('Conference Finals'), findsNothing);
  });

  testWidgets('Meal dashboard shows today food overview and recent meals', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryUserRepository();
    repository.seedCatalog(
      sportProfile: CatalogSeedData.tennisSport(),
      teamProgram: CatalogSeedData.lincolnHighTennis(),
    );
    final account = await repository.signInAnonymously(
      timezone: 'America/Los_Angeles',
    );
    await repository.completeOnboarding(
      uid: account.uid,
      profile: UserProfile.demoAngela(
        userId: account.uid,
        now: DateTime.now().toUtc(),
      ).copyWith(timezone: 'Asia/Shanghai'),
    );
    final now = DateTime(2026, 6, 15, 12);
    await repository.logMeal(
      account.uid,
      Meal(
        name: 'Greek yogurt bowl',
        nutrition: const NutritionEntry(
          caloriesKcal: 420,
          proteinG: 28,
          carbsG: 52,
          fatsG: 12,
        ),
        source: MealSource.manual,
        loggedAt: now.subtract(const Duration(hours: 2)).toUtc(),
      ),
      'Asia/Shanghai',
    );
    await repository.logMeal(
      account.uid,
      Meal(
        name: 'Turkey rice bowl',
        nutrition: const NutritionEntry(
          caloriesKcal: 680,
          proteinG: 44,
          carbsG: 86,
          fatsG: 18,
        ),
        source: MealSource.manual,
        loggedAt: now.subtract(const Duration(minutes: 40)).toUtc(),
      ),
      'Asia/Shanghai',
    );
    expect(
      await repository.getMealsForDay(account.uid, now, 'Asia/Shanghai'),
      hasLength(2),
    );

    await tester.pumpWidget(
      MealPlanScope(
        client: _FakeMealPlanClient(),
        child: UserScope(
          repository: repository,
          uid: account.uid,
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(body: MealsScreen(now: () => now)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("Today's Food"), findsOneWidget);
    expect(find.textContaining('recently eaten'), findsOneWidget);
    await tester.ensureVisible(find.text('Recently eaten'));
    await tester.pumpAndSettle();
    expect(find.text('Recently eaten'), findsOneWidget);
    expect(find.text('Turkey rice bowl'), findsOneWidget);
    expect(find.text('Greek yogurt bowl'), findsOneWidget);
    expect(find.text('1100'), findsOneWidget);
  });

  testWidgets('Schedule tab shows empty profile schedule without mock data', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryUserRepository();
    final account = await repository.signInAnonymously(
      timezone: 'America/Los_Angeles',
    );
    await repository.completeOnboarding(
      uid: account.uid,
      profile: UserProfile.demoAngela(
        userId: account.uid,
        now: DateTime.now().toUtc(),
      ),
    );

    await tester.pumpWidget(
      UserScope(
        repository: repository,
        uid: account.uid,
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(body: ScheduleScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No events or logged meals for this day.'), findsOneWidget);
    expect(find.text('Home athlete vs Rivera'), findsNothing);
    expect(find.text('Conference Finals'), findsNothing);
  });

  testWidgets('Schedule tab shows logged meals on the selected day', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryUserRepository();
    final account = await repository.signInAnonymously(
      timezone: 'America/Los_Angeles',
    );
    await repository.completeOnboarding(
      uid: account.uid,
      profile: UserProfile.demoAngela(
        userId: account.uid,
        now: DateTime.now().toUtc(),
      ),
    );

    final today = DateUtils.dateOnly(DateTime.now());
    await repository.logMeal(
      account.uid,
      Meal(
        name: 'Post-practice bowl',
        nutrition: const NutritionEntry(
          caloriesKcal: 620,
          proteinG: 42,
          carbsG: 58,
          fatsG: 18,
        ),
        source: MealSource.manual,
        loggedAt: today.add(const Duration(hours: 13)).toUtc(),
      ),
      'America/Los_Angeles',
    );

    await tester.pumpWidget(
      UserScope(
        repository: repository,
        uid: account.uid,
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(body: ScheduleScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Post-practice bowl'), findsOneWidget);
    expect(find.text('620 kcal · 42g protein'), findsOneWidget);
    expect(find.text('Logged meals'), findsWidgets);

    await tester.tap(
      find.descendant(
        of: find.byType(SegmentedButton<ScheduleViewFilter>),
        matching: find.text('Events'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Post-practice bowl'), findsNothing);
    expect(find.text('No events scheduled for this day.'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(SegmentedButton<ScheduleViewFilter>),
        matching: find.text('Logged meals'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Post-practice bowl'), findsOneWidget);
  });

  testWidgets('Previous meals sheet shows at most ten recent meals', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryUserRepository();
    final account = await repository.signInAnonymously(
      timezone: 'America/Los_Angeles',
    );
    await repository.completeOnboarding(
      uid: account.uid,
      profile: UserProfile.demoAngela(
        userId: account.uid,
        now: DateTime.now().toUtc(),
      ),
    );

    final now = DateTime.now().toUtc();
    for (var i = 0; i < 12; i++) {
      await repository.logMeal(
        account.uid,
        Meal(
          name: 'Meal $i',
          nutrition: const NutritionEntry(
            caloriesKcal: 500,
            proteinG: 30,
            carbsG: 40,
            fatsG: 15,
          ),
          source: MealSource.manual,
          loggedAt: now.subtract(Duration(hours: i)),
        ),
        'America/Los_Angeles',
      );
    }

    final recent = await repository.getRecentMeals(
      account.uid,
      limit: 10,
      timezone: 'America/Los_Angeles',
    );
    expect(recent, hasLength(10));
    expect(recent.first.name, 'Meal 0');
    expect(recent.last.name, 'Meal 9');
  });

  testWidgets('Previous meals sheet quick-adds a meal on tap', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryUserRepository();
    final account = await repository.signInAnonymously(
      timezone: 'America/Los_Angeles',
    );
    await repository.completeOnboarding(
      uid: account.uid,
      profile: UserProfile.demoAngela(
        userId: account.uid,
        now: DateTime.now().toUtc(),
      ),
    );

    await repository.logMeal(
      account.uid,
      Meal(
        name: 'Turkey rice bowl',
        nutrition: const NutritionEntry(
          caloriesKcal: 540,
          proteinG: 36,
          carbsG: 52,
          fatsG: 14,
        ),
        source: MealSource.manual,
        loggedAt: DateTime.now().toUtc(),
      ),
      'America/Los_Angeles',
    );

    await tester.pumpWidget(
      UserScope(
        repository: repository,
        uid: account.uid,
        child: MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: Builder(
              builder: (context) => FilledButton(
                onPressed: () => ScanPreviousMealsSheet.open(context),
                child: const Text('Open previous meals'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open previous meals'));
    await tester.pumpAndSettle();

    expect(find.text('Turkey rice bowl'), findsOneWidget);
    await tester.tap(find.text('Turkey rice bowl'));
    await tester.pumpAndSettle();

    final recent = await repository.getRecentMeals(
      account.uid,
      limit: 10,
      timezone: 'America/Los_Angeles',
    );
    expect(recent.where((meal) => meal.name == 'Turkey rice bowl'), hasLength(2));
  });

  testWidgets('Schedule tab toggles between week and month calendar', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryUserRepository();
    final account = await repository.signInAnonymously(
      timezone: 'America/Los_Angeles',
    );
    await repository.completeOnboarding(
      uid: account.uid,
      profile: UserProfile.demoAngela(
        userId: account.uid,
        now: DateTime.now().toUtc(),
      ),
    );

    await tester.pumpWidget(
      UserScope(
        repository: repository,
        uid: account.uid,
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(body: ScheduleScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final now = DateTime.now();
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final monthLabel = monthNames[now.month - 1];

    expect(find.text('This week'), findsOneWidget);
    expect(find.byType(WeekDateSelector), findsOneWidget);

    await tester.tap(find.text(monthLabel));
    await tester.pumpAndSettle();

    expect(find.text('Full month'), findsOneWidget);
    expect(find.byType(MonthDateSelector), findsOneWidget);

    await tester.tap(find.text('$monthLabel ${now.year}'));
    await tester.pumpAndSettle();

    expect(find.text('This week'), findsOneWidget);
    expect(find.byType(WeekDateSelector), findsOneWidget);
  });

  testWidgets('Schedule tab renders profile schedule events by selected day', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryUserRepository();
    final account = await repository.signInAnonymously(
      timezone: 'America/Los_Angeles',
    );
    final today = DateUtils.dateOnly(DateTime.now());
    final tomorrow = today.add(const Duration(days: 1));
    final profile =
        UserProfile.demoAngela(
          userId: account.uid,
          now: DateTime.now().toUtc(),
        ).copyWith(
          scheduleEvents: [
            UserScheduleEvent(
              eventId: 'match_today',
              type: ScheduleEventType.match,
              startAt: today.add(const Duration(hours: 16)).toUtc(),
              title: 'Varsity Match vs Rivera',
              subtitle: '~2h',
              location: 'Lincoln Courts',
              badge: 'CONFERENCE FINALS',
              fuelingHints: const [
                FuelingHint(timing: '3H BEFORE', label: 'Big Carbs'),
              ],
            ),
            UserScheduleEvent(
              eventId: 'training_tomorrow',
              type: ScheduleEventType.training,
              startAt: tomorrow.add(const Duration(hours: 10)).toUtc(),
              title: 'Recovery Stretch',
              subtitle: '20 min · Mobility',
            ),
          ],
        );
    await repository.completeOnboarding(uid: account.uid, profile: profile);

    await tester.pumpWidget(
      UserScope(
        repository: repository,
        uid: account.uid,
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(body: ScheduleScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("Today's Match"), findsOneWidget);
    expect(find.text('Varsity Match vs Rivera'), findsWidgets);
    expect(find.text('Lincoln Courts · 4:00 PM'), findsOneWidget);
    expect(find.text('3H BEFORE Big Carbs'), findsOneWidget);
    expect(find.text('Recovery Stretch'), findsNothing);

    await tester.ensureVisible(
      find.byKey(
        Key(
          'calendar_date_${tomorrow.year}_${tomorrow.month}_${tomorrow.day}',
        ),
      ),
    );
    await tester.tap(
      find.byKey(
        Key(
          'calendar_date_${tomorrow.year}_${tomorrow.month}_${tomorrow.day}',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Recovery Stretch'), findsOneWidget);
    expect(find.text("Today's Match"), findsNothing);
    expect(find.text('Varsity Match vs Rivera'), findsNothing);
  });

  testWidgets('Schedule event creation opens and validates required title', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryUserRepository();
    final account = await repository.signInAnonymously(
      timezone: 'America/Los_Angeles',
    );
    await repository.completeOnboarding(
      uid: account.uid,
      profile: UserProfile.demoAngela(
        userId: account.uid,
        now: DateTime.now().toUtc(),
      ),
    );

    await tester.pumpWidget(
      UserScope(
        repository: repository,
        uid: account.uid,
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(body: ScheduleScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Create Schedule Event'), findsOneWidget);
    expect(find.text('Event type'), findsOneWidget);

    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Required'), findsOneWidget);
    final profile = await repository.getProfile(account.uid);
    expect(profile?.scheduleEvents, isEmpty);
  });

  testWidgets('Schedule event creation saves a training event', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryUserRepository();
    final account = await repository.signInAnonymously(
      timezone: 'America/Los_Angeles',
    );
    await repository.completeOnboarding(
      uid: account.uid,
      profile: UserProfile.demoAngela(
        userId: account.uid,
        now: DateTime.now().toUtc(),
      ),
    );

    await tester.pumpWidget(
      UserScope(
        repository: repository,
        uid: account.uid,
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(body: ScheduleScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Serve practice');
    await tester.enterText(find.byType(TextFormField).at(1), '45 min');
    await tester.enterText(find.byType(TextFormField).at(2), 'Court 2');
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Serve practice'), findsOneWidget);
    expect(find.text('45 min'), findsOneWidget);
    final profile = await repository.getProfile(account.uid);
    expect(profile?.scheduleEvents, hasLength(1));
    expect(profile?.scheduleEvents.single.title, 'Serve practice');
    expect(profile?.scheduleEvents.single.type, ScheduleEventType.training);

    final tomorrow = DateUtils.dateOnly(
      DateTime.now(),
    ).add(const Duration(days: 1));
    await tester.ensureVisible(
      find.byKey(
        Key(
          'calendar_date_${tomorrow.year}_${tomorrow.month}_${tomorrow.day}',
        ),
      ),
    );
    await tester.tap(
      find.byKey(
        Key(
          'calendar_date_${tomorrow.year}_${tomorrow.month}_${tomorrow.day}',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Serve practice'), findsNothing);
  });

  testWidgets('Schedule event creation saves a match with fueling hints', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryUserRepository();
    final account = await repository.signInAnonymously(
      timezone: 'America/Los_Angeles',
    );
    await repository.completeOnboarding(
      uid: account.uid,
      profile: UserProfile.demoAngela(
        userId: account.uid,
        now: DateTime.now().toUtc(),
      ),
    );

    await tester.pumpWidget(
      UserScope(
        repository: repository,
        uid: account.uid,
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(body: ScheduleScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Training'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Match').last);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Championship Match',
    );
    await tester.enterText(find.byType(TextFormField).at(1), '~2h');
    await tester.enterText(find.byType(TextFormField).at(2), 'Main Court');
    await tester.enterText(find.byType(TextFormField).at(3), 'REGIONAL FINAL');
    await tester.ensureVisible(find.text('Add hints'));
    await tester.tap(find.text('Add hints'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(4), '2H BEFORE');
    await tester.enterText(find.byType(TextFormField).at(5), 'Hydrate');

    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text("Today's Match"), findsOneWidget);
    expect(find.text('Championship Match'), findsWidgets);
    expect(find.text('REGIONAL FINAL'), findsOneWidget);
    expect(find.text('2H BEFORE Hydrate'), findsOneWidget);

    final profile = await repository.getProfile(account.uid);
    final event = profile?.scheduleEvents.single;
    expect(event?.type, ScheduleEventType.match);
    expect(event?.location, 'Main Court');
    expect(event?.badge, 'REGIONAL FINAL');
    expect(event?.fuelingHints.single.label, 'Hydrate');
  });

  testWidgets('Meal dashboard shows an error state when the API fails', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryUserRepository();
    repository.seedCatalog(
      sportProfile: CatalogSeedData.tennisSport(),
      teamProgram: CatalogSeedData.lincolnHighTennis(),
    );
    final account = await repository.signInAnonymously(
      timezone: 'America/Los_Angeles',
    );
    await repository.completeOnboarding(
      uid: account.uid,
      profile: UserProfile.demoAngela(
        userId: account.uid,
        now: DateTime.now().toUtc(),
      ),
    );

    await tester.pumpWidget(
      MealPlanScope(
        client: _FailingMealPlanClient(),
        child: UserScope(
          repository: repository,
          uid: account.uid,
          child: AppSettingsScope(
            repository: repository,
            uid: account.uid,
            child: const NutriLensApp(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Meals'));
    await tester.pumpAndSettle();

    expect(find.text('Meal plan unavailable'), findsOneWidget);
    expect(find.textContaining('Edamam failed on purpose'), findsOneWidget);
  });

  testWidgets('Meal date strip starts today and shows the next six days', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryUserRepository();
    repository.seedCatalog(
      sportProfile: CatalogSeedData.tennisSport(),
      teamProgram: CatalogSeedData.lincolnHighTennis(),
    );
    final account = await repository.signInAnonymously(
      timezone: 'America/Los_Angeles',
    );
    await repository.completeOnboarding(
      uid: account.uid,
      profile: UserProfile.demoAngela(
        userId: account.uid,
        now: DateTime(2026, 6, 9).toUtc(),
      ),
    );

    final mealPlanClient = _FakeMealPlanClient();
    final fixedNow = DateTime(2026, 6, 9, 15, 42);

    await tester.pumpWidget(
      MealPlanScope(
        client: mealPlanClient,
        child: UserScope(
          repository: repository,
          uid: account.uid,
          child: MaterialApp(
            home: Scaffold(body: MealsScreen(now: () => fixedNow)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(mealPlanClient.lastStartDate, DateTime(2026, 6, 9));
    expect(find.text('TUE'), findsOneWidget);
    expect(find.text('WED'), findsOneWidget);
    expect(find.text('THU'), findsOneWidget);
    expect(find.text('FRI'), findsOneWidget);
    expect(find.text('SAT'), findsOneWidget);
    expect(find.text('SUN'), findsOneWidget);
    expect(find.text('MON'), findsOneWidget);
    await tester.tap(find.text('SAT'));
    await tester.pumpAndSettle();

    expect(find.text('2102'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('Power Oats & Berries Bowl'),
      _mealsScrollable(),
      const Offset(0, -300),
      maxIteration: 20,
    );
    expect(find.text('Power Oats & Berries Bowl'), findsOneWidget);
  });

  testWidgets('Meal card refresh replaces one meal and updates totals', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryUserRepository();
    repository.seedCatalog(
      sportProfile: CatalogSeedData.tennisSport(),
      teamProgram: CatalogSeedData.lincolnHighTennis(),
    );
    final account = await repository.signInAnonymously(
      timezone: 'America/Los_Angeles',
    );
    await repository.completeOnboarding(
      uid: account.uid,
      profile: UserProfile.demoAngela(
        userId: account.uid,
        now: DateTime(2026, 6, 9).toUtc(),
      ),
    );

    final mealPlanClient = _FakeMealPlanClient();
    final fixedNow = DateTime(2026, 6, 9, 15, 42);

    await tester.pumpWidget(
      MealPlanScope(
        client: mealPlanClient,
        child: UserScope(
          repository: repository,
          uid: account.uid,
          child: MaterialApp(
            home: Scaffold(body: MealsScreen(now: () => fixedNow)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('2090'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('Power Oats & Berries Bowl'),
      _mealsScrollable(),
      const Offset(0, -300),
      maxIteration: 20,
    );
    expect(find.text('Power Oats & Berries Bowl'), findsOneWidget);
    expect(find.text('Refresh meal'), findsWidgets);

    final refreshMealAction = find.text('Refresh meal').first;
    await tester.ensureVisible(refreshMealAction);
    await tester.pumpAndSettle();
    await tester.tap(refreshMealAction);
    await tester.pumpAndSettle();

    expect(mealPlanClient.lastRegeneratedDate, DateTime(2026, 6, 9));
    expect(mealPlanClient.lastRegeneratedSlot, MealSlot.breakfast);
    expect(find.text('Regenerated Breakfast Bowl'), findsOneWidget);
    expect(find.text('Power Oats & Berries Bowl'), findsNothing);

    await tester.drag(find.byType(ListView), const Offset(0, 500));
    await tester.pumpAndSettle();

    expect(find.text('2390'), findsOneWidget);
  });

  testWidgets('Meal card refresh failure keeps the old meal', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryUserRepository();
    repository.seedCatalog(
      sportProfile: CatalogSeedData.tennisSport(),
      teamProgram: CatalogSeedData.lincolnHighTennis(),
    );
    final account = await repository.signInAnonymously(
      timezone: 'America/Los_Angeles',
    );
    await repository.completeOnboarding(
      uid: account.uid,
      profile: UserProfile.demoAngela(
        userId: account.uid,
        now: DateTime(2026, 6, 9).toUtc(),
      ),
    );

    final mealPlanClient = _FailingRefreshMealPlanClient();
    final fixedNow = DateTime(2026, 6, 9, 15, 42);

    await tester.pumpWidget(
      MealPlanScope(
        client: mealPlanClient,
        child: UserScope(
          repository: repository,
          uid: account.uid,
          child: MaterialApp(
            home: Scaffold(body: MealsScreen(now: () => fixedNow)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.dragUntilVisible(
      find.text('Power Oats & Berries Bowl'),
      _mealsScrollable(),
      const Offset(0, -300),
      maxIteration: 20,
    );
    final refreshMealAction = find.text('Refresh meal').first;
    await tester.ensureVisible(refreshMealAction);
    await tester.pumpAndSettle();
    await tester.tap(refreshMealAction);
    await tester.pumpAndSettle();

    expect(find.text('Power Oats & Berries Bowl'), findsOneWidget);
    expect(find.textContaining('Unable to refresh meal'), findsOneWidget);
  });
}

class _FakeMealPlanClient implements MealPlanClient {
  int callCount = 0;
  DateTime? lastStartDate;
  DateTime? lastRegeneratedDate;
  MealSlot? lastRegeneratedSlot;

  @override
  Future<MealPlanWeek> fetchWeeklyPlan({
    required UserProfile profile,
    required DateTime startDate,
  }) async {
    callCount += 1;
    lastStartDate = startDate;
    final titles = callCount == 1
        ? const [
            'Power Oats & Berries Bowl',
            'Chicken & Sweet Potato',
            'Salmon Grain Bowl',
          ]
        : const [
            'Recovery Oats & Fruit',
            'Turkey Rice Bowl',
            'Veggie Pasta Power',
          ];

    final days = List.generate(7, (dayIndex) {
      final date = DateUtils.dateOnly(startDate).add(Duration(days: dayIndex));
      return MealPlanDay(
        date: date,
        meals: [
          _buildMeal(
            slot: MealSlot.breakfast,
            title: titles[0],
            calories: 620 + dayIndex,
            protein: 32,
            carbs: 88,
            fats: 14,
          ),
          _buildMeal(
            slot: MealSlot.lunch,
            title: titles[1],
            calories: 780 + dayIndex,
            protein: 48,
            carbs: 110,
            fats: 18,
          ),
          _buildMeal(
            slot: MealSlot.dinner,
            title: titles[2],
            calories: 690 + dayIndex,
            protein: 38,
            carbs: 94,
            fats: 20,
          ),
        ],
      );
    });

    return MealPlanWeek(generatedAt: DateTime.now().toUtc(), days: days);
  }

  @override
  Future<MealPlanMeal> regenerateMeal({
    required UserProfile profile,
    required DateTime date,
    required MealSlot slot,
  }) async {
    lastRegeneratedDate = DateUtils.dateOnly(date);
    lastRegeneratedSlot = slot;
    return _buildMeal(
      slot: slot,
      title: 'Regenerated ${slot.label} Bowl',
      calories: 920,
      protein: 50,
      carbs: 120,
      fats: 20,
    );
  }

  MealPlanMeal _buildMeal({
    required MealSlot slot,
    required String title,
    required int calories,
    required int protein,
    required int carbs,
    required int fats,
  }) {
    return MealPlanMeal(
      slot: slot,
      timeLabel: slot == MealSlot.breakfast
          ? '7:00 AM'
          : slot == MealSlot.lunch
          ? '12:30 PM'
          : '6:30 PM',
      badgeLabel: slot.label.toUpperCase(),
      recipe: MealPlanRecipe(
        recipeId: '${slot.label}_$title',
        title: title,
        imageUrl: null,
        sourceName: 'Allrecipes',
        sourceUrl: 'https://example.com/$title',
        calories: calories.toDouble(),
        nutrition: NutritionEntry(
          caloriesKcal: calories,
          proteinG: protein,
          carbsG: carbs,
          fatsG: fats,
        ),
      ),
    );
  }
}

Finder _mealsScrollable() {
  return find.byType(Scrollable).first;
}

Future<void> _completeOnboardingMealPrefsStep(WidgetTester tester) async {
  expect(find.text('Meal preferences'), findsOneWidget);
  await tester.ensureVisible(find.text('Meal preferences'));
  await tester.pumpAndSettle();
  final continueButton = find.widgetWithText(FilledButton, 'Continue');
  await tester.ensureVisible(continueButton.last);
  await tester.tap(continueButton.last);
  await tester.pumpAndSettle();
}

Future<void> _completeOnboardingBodyStep(WidgetTester tester) async {
  expect(find.text('Your body metrics'), findsOneWidget);
  await tester.enterText(find.byKey(const Key('onboarding_height_cm')), '175');
  await tester.enterText(find.byKey(const Key('onboarding_weight_kg')), '70');
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
}

Future<void> _pumpOnboarding(
  WidgetTester tester,
  InMemoryUserRepository repository,
  String uid,
) async {
  await tester.pumpWidget(
    MealPlanScope(
      client: _FakeMealPlanClient(),
      child: UserScope(
        repository: repository,
        uid: uid,
        child: AppSettingsScope(
          repository: repository,
          uid: uid,
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const OnboardingFlow(),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpAppShell(
  WidgetTester tester,
  InMemoryUserRepository repository,
  String uid,
) async {
  await tester.pumpWidget(
    MealPlanScope(
      client: _FakeMealPlanClient(),
      child: UserScope(
        repository: repository,
        uid: uid,
        child: AppSettingsScope(
          repository: repository,
          uid: uid,
          child: MaterialApp(theme: AppTheme.dark, home: const AppShell()),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpAccountSettings(
  WidgetTester tester,
  InMemoryUserRepository repository,
  String uid,
) async {
  await tester.pumpWidget(
    UserScope(
      repository: repository,
      uid: uid,
      child: AppSettingsScope(
        repository: repository,
        uid: uid,
        child: SessionScope(
          signOut: () async {},
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const AccountSettingsScreen(),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpSleepDashboard(
  WidgetTester tester,
  InMemoryUserRepository repository,
  String uid,
) async {
  await tester.pumpWidget(
    UserScope(
      repository: repository,
      uid: uid,
      child: MaterialApp(
        theme: AppTheme.dark,
        home: const SleepDashboardScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _FailingMealPlanClient implements MealPlanClient {
  @override
  Future<MealPlanWeek> fetchWeeklyPlan({
    required UserProfile profile,
    required DateTime startDate,
  }) async {
    throw StateError('Edamam failed on purpose');
  }

  @override
  Future<MealPlanMeal> regenerateMeal({
    required UserProfile profile,
    required DateTime date,
    required MealSlot slot,
  }) async {
    throw StateError('Edamam failed on purpose');
  }
}

class _FailingRefreshMealPlanClient extends _FakeMealPlanClient {
  @override
  Future<MealPlanMeal> regenerateMeal({
    required UserProfile profile,
    required DateTime date,
    required MealSlot slot,
  }) async {
    throw StateError('Refresh failed on purpose');
  }
}
