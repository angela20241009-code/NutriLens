import 'package:flutter/widgets.dart';
import 'package:nutrilens/models/in_app_notification.dart';

class InAppNotificationController extends ChangeNotifier {
  InAppNotification? _current;

  InAppNotification? get current => _current;

  void show(InAppNotification notification) {
    _current = notification;
    notifyListeners();
  }

  void dismiss() {
    if (_current == null) {
      return;
    }
    _current = null;
    notifyListeners();
  }
}

class InAppNotificationScope extends InheritedNotifier<InAppNotificationController> {
  const InAppNotificationScope({
    super.key,
    required InAppNotificationController notifier,
    required super.child,
  }) : super(notifier: notifier);

  static InAppNotificationController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<InAppNotificationScope>();
    if (scope == null) {
      throw FlutterError(
        'InAppNotificationScope.of() called with no InAppNotificationScope in context.',
      );
    }
    return scope.notifier!;
  }

  static InAppNotificationController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<InAppNotificationScope>()
        ?.notifier;
  }
}
