import 'package:flutter/widgets.dart';
import 'package:nutrilens/services/user_repository.dart';

class UserScope extends InheritedWidget {
  const UserScope({
    super.key,
    required this.repository,
    required this.uid,
    required super.child,
  });

  final UserRepository repository;
  final String uid;

  static UserScope of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<UserScope>();
    if (result == null) {
      throw FlutterError('UserScope.of() called with no UserScope in context.');
    }
    return result;
  }

  @override
  bool updateShouldNotify(covariant UserScope oldWidget) {
    return uid != oldWidget.uid || repository != oldWidget.repository;
  }
}
