import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrilens/app.dart';
import 'package:nutrilens/app/meal_plan_scope.dart';
import 'package:nutrilens/app/user_scope.dart';
import 'package:nutrilens/data/catalog_seed_data.dart';
import 'package:nutrilens/features/auth/auth_screen.dart';
import 'package:nutrilens/features/profile/profile_screen.dart';
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
          onCreateAccount: (_, _) async => createCalled = true,
          onSignIn: (_, _) async => signInCalled = true,
          onContinueAsGuest: () async {},
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
    await tester.tap(find.text('Create account'));
    await tester.pump();

    expect(createCalled, true);
    expect(signInCalled, false);
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

  testWidgets('Meal dashboard loads, switches days, and regenerates',
      (WidgetTester tester) async {
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
          child: const NutriLensApp(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);

    await tester.tap(find.text('Meals'));
    await tester.pumpAndSettle();

    expect(find.text('Meal Plan'), findsOneWidget);
    expect(find.text('Regenerate'), findsOneWidget);
    expect(find.text('MATCH DAY NUTRITION'), findsOneWidget);
    expect(find.text('High-carb loading for your tennis match at 4:00 PM'),
        findsOneWidget);
    expect(find.text('Power Oats & Berries Bowl'), findsOneWidget);
    expect(find.text('Source: Allrecipes'), findsWidgets);
    expect(mealPlanClient.callCount, 1);

    await tester.tap(find.text('MON'));
    await tester.pumpAndSettle();

    expect(
      find.text('Balanced fueling for your tennis training day'),
      findsOneWidget,
    );

    await tester.tap(find.text('Regenerate'));
    await tester.pumpAndSettle();

    expect(mealPlanClient.callCount, 2);
    expect(find.text('Recovery Oats & Fruit'), findsOneWidget);

    await tester.tap(find.text('Schedule'));
    await tester.pumpAndSettle();

    expect(find.text('Schedule'), findsWidgets);
    expect(find.text('Train · Match · Fuel'), findsOneWidget);
    expect(find.text("Today's Match"), findsOneWidget);
    expect(find.text('Timeline'), findsOneWidget);
    expect(find.text('Conference Finals'), findsOneWidget);
  });

  testWidgets('Meal dashboard shows an error state when the API fails',
      (WidgetTester tester) async {
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
          child: const NutriLensApp(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Meals'));
    await tester.pumpAndSettle();

    expect(find.text('Meal plan unavailable'), findsOneWidget);
    expect(find.textContaining('Edamam failed on purpose'), findsOneWidget);
  });
}

class _FakeMealPlanClient implements MealPlanClient {
  int callCount = 0;

  @override
  Future<MealPlanWeek> fetchWeeklyPlan({
    required UserProfile profile,
    required DateTime startDate,
  }) async {
    callCount += 1;
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
      final date = DateTime(2026, 4, 14 + dayIndex);
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

    return MealPlanWeek(
      generatedAt: DateTime.now().toUtc(),
      days: days,
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

class _FailingMealPlanClient implements MealPlanClient {
  @override
  Future<MealPlanWeek> fetchWeeklyPlan({
    required UserProfile profile,
    required DateTime startDate,
  }) async {
    throw StateError('Edamam failed on purpose');
  }
}
