import 'package:flutter/widgets.dart';
import 'package:nutrilens/services/meal_analysis_client.dart';

class MealAnalysisScope extends InheritedWidget {
  const MealAnalysisScope({
    super.key,
    required this.client,
    required super.child,
  });

  final MealAnalysisClient client;

  static MealAnalysisClient of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<MealAnalysisScope>();
    if (scope == null) {
      throw FlutterError(
        'MealAnalysisScope.of() called with no MealAnalysisScope in context.',
      );
    }
    return scope.client;
  }

  @override
  bool updateShouldNotify(covariant MealAnalysisScope oldWidget) {
    return client != oldWidget.client;
  }
}
