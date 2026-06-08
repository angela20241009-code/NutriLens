import 'package:flutter/widgets.dart';

class SessionScope extends InheritedWidget {
  const SessionScope({
    super.key,
    required this.signOut,
    required super.child,
  });

  final Future<void> Function() signOut;

  static SessionScope of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<SessionScope>();
    if (result == null) {
      throw FlutterError(
        'SessionScope.of() called with no SessionScope in context.',
      );
    }
    return result;
  }

  @override
  bool updateShouldNotify(covariant SessionScope oldWidget) {
    return signOut != oldWidget.signOut;
  }
}
