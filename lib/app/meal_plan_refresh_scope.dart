import 'package:flutter/widgets.dart';

class MealPlanRefreshNotifier extends ChangeNotifier {
  int _generation = 0;

  int get generation => _generation;

  void requestRefresh() {
    _generation += 1;
    notifyListeners();
  }
}

class MealPlanRefreshScope extends InheritedNotifier<MealPlanRefreshNotifier> {
  const MealPlanRefreshScope({
    super.key,
    required MealPlanRefreshNotifier notifier,
    required super.child,
  }) : super(notifier: notifier);

  static MealPlanRefreshNotifier of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<MealPlanRefreshScope>();
    if (scope == null) {
      throw FlutterError(
        'MealPlanRefreshScope.of() called with no MealPlanRefreshScope in context.',
      );
    }
    return scope.notifier!;
  }

  static MealPlanRefreshNotifier? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MealPlanRefreshScope>()
        ?.notifier;
  }
}
