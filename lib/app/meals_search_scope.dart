import 'package:flutter/widgets.dart';

class MealsSearchController extends ChangeNotifier {
  int _generation = 0;
  String _query = '';

  int get generation => _generation;
  String get query => _query;

  void openSearch(String query) {
    _query = query.trim();
    _generation++;
    notifyListeners();
  }
}

class MealsSearchScope extends InheritedNotifier<MealsSearchController> {
  const MealsSearchScope({
    super.key,
    required MealsSearchController controller,
    required super.child,
  }) : super(notifier: controller);

  static MealsSearchController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<MealsSearchScope>();
    if (scope == null) {
      throw FlutterError(
        'MealsSearchScope.of() called with no MealsSearchScope in context.',
      );
    }
    return scope.notifier!;
  }

  static MealsSearchController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MealsSearchScope>()?.notifier;
  }
}
