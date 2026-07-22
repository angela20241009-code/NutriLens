import 'package:flutter/widgets.dart';

class SleepLogRefreshNotifier extends ChangeNotifier {
  int _generation = 0;

  int get generation => _generation;

  void requestRefresh() {
    _generation += 1;
    notifyListeners();
  }
}

class SleepLogRefreshScope extends InheritedNotifier<SleepLogRefreshNotifier> {
  const SleepLogRefreshScope({
    super.key,
    required SleepLogRefreshNotifier notifier,
    required super.child,
  }) : super(notifier: notifier);

  static SleepLogRefreshNotifier of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<SleepLogRefreshScope>();
    if (scope == null) {
      throw FlutterError(
        'SleepLogRefreshScope.of() called with no SleepLogRefreshScope in context.',
      );
    }
    return scope.notifier!;
  }

  static SleepLogRefreshNotifier? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<SleepLogRefreshScope>()
        ?.notifier;
  }
}
