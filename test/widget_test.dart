import 'package:flutter_test/flutter_test.dart';
import 'package:nutrilens/app.dart';
import 'package:nutrilens/app/user_scope.dart';
import 'package:nutrilens/data/catalog_seed_data.dart';
import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/services/in_memory_user_repository.dart';

void main() {
  testWidgets('Meal home dashboard and mode switch', (WidgetTester tester) async {
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
      UserScope(
        repository: repository,
        uid: account.uid,
        child: const NutriLensApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Angela'), findsOneWidget);
    expect(find.text("TODAY'S FUEL"), findsOneWidget);
    expect(find.text("Today's Meal Plan"), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);

    await tester.tap(find.text('Sleep'));
    await tester.pumpAndSettle();

    expect(find.text('Sleep insights coming soon'), findsOneWidget);

    await tester.tap(find.text('Meal Tracking'));
    await tester.pumpAndSettle();

    expect(find.text("TODAY'S FUEL"), findsOneWidget);

    await tester.tap(find.text('Meals'));
    await tester.pumpAndSettle();

    expect(find.text('Meals'), findsWidgets);
  });
}
