import 'package:flutter/widgets.dart';

class MealLogRefreshNotifier extends ChangeNotifier {
  int _generation = 0;

  int get generation => _generation;

  void requestRefresh() {
    _generation += 1;
    notifyListeners();
  }
}

class MealLogRefreshScope extends InheritedNotifier<MealLogRefreshNotifier> {
  const MealLogRefreshScope({
    super.key,
    required MealLogRefreshNotifier notifier,
    required super.child,
  }) : super(notifier: notifier);

  static MealLogRefreshNotifier of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<MealLogRefreshScope>();
    if (scope == null) {
      throw FlutterError(
        'MealLogRefreshScope.of() called with no MealLogRefreshScope in context.',
      );
    }
    return scope.notifier!;
  }

  static MealLogRefreshNotifier? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MealLogRefreshScope>()
        ?.notifier;
  }
}
