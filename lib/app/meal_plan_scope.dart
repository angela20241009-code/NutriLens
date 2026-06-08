import 'package:flutter/widgets.dart';
import 'package:nutrilens/services/meal_plan_client.dart';

class MealPlanScope extends InheritedWidget {
  const MealPlanScope({
    super.key,
    required this.client,
    required super.child,
  });

  final MealPlanClient client;

  static MealPlanScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MealPlanScope>();
  }

  static MealPlanClient of(BuildContext context) {
    final scope = maybeOf(context);
    if (scope == null) {
      throw FlutterError(
        'MealPlanScope.of() called with no MealPlanScope in context.',
      );
    }
    return scope.client;
  }

  @override
  bool updateShouldNotify(covariant MealPlanScope oldWidget) {
    return client != oldWidget.client;
  }
}
