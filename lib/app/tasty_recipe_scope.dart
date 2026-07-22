import 'package:flutter/widgets.dart';
import 'package:nutrilens/services/tasty_recipe_client.dart';

class TastyRecipeScope extends InheritedWidget {
  const TastyRecipeScope({
    super.key,
    required this.client,
    required super.child,
  });

  final TastyRecipeClient client;

  static TastyRecipeScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TastyRecipeScope>();
  }

  static TastyRecipeClient of(BuildContext context) {
    final scope = maybeOf(context);
    if (scope == null) {
      throw FlutterError(
        'TastyRecipeScope.of() called with no TastyRecipeScope in context.',
      );
    }
    return scope.client;
  }

  @override
  bool updateShouldNotify(covariant TastyRecipeScope oldWidget) {
    return client != oldWidget.client;
  }
}
