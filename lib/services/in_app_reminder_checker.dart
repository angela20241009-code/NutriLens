import 'package:nutrilens/features/sleep/sleep_logging.dart';
import 'package:nutrilens/models/reminder_kind.dart';
import 'package:nutrilens/models/user_profile.dart';
import 'package:nutrilens/services/notification_scheduler.dart';
import 'package:timezone/timezone.dart' as tz;

class DueReminder {
  const DueReminder({
    required this.kind,
    required this.minutesOfDay,
    this.mealIndex,
    this.hydrationIndex,
    this.eventId,
  });

  final ReminderKind kind;
  final int minutesOfDay;
  final int? mealIndex;
  final int? hydrationIndex;
  final String? eventId;

  String storageKey(String dateKey) {
    return switch (kind) {
      ReminderKind.meal => '${kind.name}_${mealIndex ?? 'none'}_$dateKey',
      ReminderKind.hydration =>
        '${kind.name}_${hydrationIndex ?? 'none'}_$dateKey',
      ReminderKind.event => '${kind.name}_${eventId ?? 'none'}_$dateKey',
      _ => '${kind.name}_none_$dateKey',
    };
  }
}

abstract final class InAppReminderChecker {
  static List<DueReminder> dueReminders({
    required UserProfile profile,
    required int currentMinutesOfDay,
    DateTime? nowUtc,
  }) {
    final settings = profile.notificationSettings;
    final reminders = <DueReminder>[];
    final instant = nowUtc ?? DateTime.now().toUtc();

    if (settings.mealRemindersEnabled) {
      final mealTimes = NotificationScheduler.mealReminderMinutes(profile);
      for (var index = 0; index < mealTimes.length; index++) {
        if (mealTimes[index] == currentMinutesOfDay) {
          reminders.add(
            DueReminder(
              kind: ReminderKind.meal,
              minutesOfDay: mealTimes[index],
              mealIndex: index,
            ),
          );
        }
      }
    }

    if (settings.hydrationRemindersEnabled) {
      final hydrationTimes = NotificationScheduler.hydrationReminderMinutes(
        profile,
      );
      for (var index = 0; index < hydrationTimes.length; index++) {
        if (hydrationTimes[index] == currentMinutesOfDay) {
          reminders.add(
            DueReminder(
              kind: ReminderKind.hydration,
              minutesOfDay: hydrationTimes[index],
              hydrationIndex: index,
            ),
          );
        }
      }
    }

    if (settings.sleepRemindersEnabled) {
      final bedtime = profile.usualBedtimeMinutes ?? 22 * 60;
      final lead = settings.bedtimeReminderLeadMinutes.clamp(5, 120);
      final bedtimeMinutes = normalizeMinutes(bedtime - lead);
      if (bedtimeMinutes == currentMinutesOfDay) {
        reminders.add(
          DueReminder(
            kind: ReminderKind.bedtime,
            minutesOfDay: bedtimeMinutes,
          ),
        );
      }

      final wake = profile.usualWakeTimeMinutes ?? 7 * 60;
      if (wake == currentMinutesOfDay) {
        reminders.add(
          DueReminder(kind: ReminderKind.wake, minutesOfDay: wake),
        );
      }
    }

    if (settings.eventRemindersEnabled && profile.scheduleEvents.isNotEmpty) {
      final location = _locationFor(profile.timezone);
      final nowLocal = tz.TZDateTime.from(instant, location);
      final lead = settings.eventReminderLeadMinutes.clamp(5, 120);

      for (final event in profile.scheduleEvents) {
        final eventLocal = tz.TZDateTime.from(event.startAt.toUtc(), location);
        final reminderLocal = eventLocal.subtract(Duration(minutes: lead));
        if (reminderLocal.year == nowLocal.year &&
            reminderLocal.month == nowLocal.month &&
            reminderLocal.day == nowLocal.day &&
            reminderLocal.hour == nowLocal.hour &&
            reminderLocal.minute == nowLocal.minute) {
          reminders.add(
            DueReminder(
              kind: ReminderKind.event,
              minutesOfDay: currentMinutesOfDay,
              eventId: event.eventId,
            ),
          );
        }
      }
    }

    return reminders;
  }

  static tz.Location _locationFor(String timezone) {
    try {
      return tz.getLocation(timezone);
    } catch (_) {
      return tz.local;
    }
  }
}
