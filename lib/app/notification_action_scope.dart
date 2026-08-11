import 'package:flutter/widgets.dart';
import 'package:nutrilens/models/reminder_kind.dart';

typedef ReminderOpenedHandler = Future<void> Function(ReminderKind kind);

class NotificationActionScope extends InheritedWidget {
  const NotificationActionScope({
    super.key,
    required this.onReminderOpened,
    required super.child,
  });

  final ReminderOpenedHandler onReminderOpened;

  static NotificationActionScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NotificationActionScope>();
  }

  @override
  bool updateShouldNotify(covariant NotificationActionScope oldWidget) {
    return onReminderOpened != oldWidget.onReminderOpened;
  }
}
