import 'package:flutter_test/flutter_test.dart';
import 'package:nutrilens/app.dart';

void main() {
  testWidgets('Meal home dashboard and mode switch', (WidgetTester tester) async {
    await tester.pumpWidget(const NutriLensApp());
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
