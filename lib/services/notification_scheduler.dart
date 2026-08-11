import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nutrilens/features/sleep/sleep_logging.dart';
import 'package:nutrilens/models/reminder_kind.dart';
import 'package:nutrilens/models/user_profile.dart';
import 'package:timezone/timezone.dart' as tz;

typedef NotificationResponseHandler = void Function(NotificationResponse response);

class NotificationScheduler {
  NotificationScheduler._();

  static final NotificationScheduler instance = NotificationScheduler._();

  static const _channelId = 'nutrilens_reminders';
  static const _channelName = 'NutriLens reminders';
  static const _mealBaseId = 1000;
  static const _bedtimeId = 2000;
  static const _wakeId = 2001;
  static const _hydrationBaseId = 3000;
  static const _eventBaseId = 4000;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  NotificationResponseHandler? _responseHandler;

  void setResponseHandler(NotificationResponseHandler? handler) {
    _responseHandler = handler;
  }

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      defaultPresentAlert: false,
      defaultPresentBadge: false,
      defaultPresentSound: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: 'Event, hydration, sleep, and meal reminders',
          importance: Importance.high,
        ),
      );
    }

    _initialized = true;
  }

  Future<NotificationAppLaunchDetails?> launchDetails() async {
    await initialize();
    return _plugin.getNotificationAppLaunchDetails();
  }

  Future<bool> requestPermissions() async {
    await initialize();

    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      final iosPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      return await iosPlugin?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await androidPlugin?.requestNotificationsPermission() ?? true;
    }

    return true;
  }

  Future<void> syncFromProfile(UserProfile profile) async {
    await initialize();
    await _plugin.cancelAll();

    final settings = profile.notificationSettings;
    if (!settings.anyEnabled) {
      return;
    }

    final location = _locationFor(profile.timezone);
    final details = _notificationDetails();

    if (settings.mealRemindersEnabled) {
      final mealTimes = mealReminderMinutes(profile);
      for (var index = 0; index < mealTimes.length; index++) {
        await _scheduleDaily(
          id: _mealBaseId + index,
          title: 'Time to fuel up',
          body: 'Log your meal to stay on track with your nutrition plan.',
          minutes: mealTimes[index],
          location: location,
          details: details,
          payload: ReminderKind.meal.payload,
        );
      }
    }

    if (settings.hydrationRemindersEnabled) {
      final hydrationTimes = hydrationReminderMinutes(profile);
      for (var index = 0; index < hydrationTimes.length; index++) {
        await _scheduleDaily(
          id: _hydrationBaseId + index,
          title: 'Stay hydrated',
          body: 'Take a moment to drink water and log your hydration.',
          minutes: hydrationTimes[index],
          location: location,
          details: details,
          payload: ReminderKind.hydration.payload,
        );
      }
    }

    if (settings.sleepRemindersEnabled) {
      final bedtime = profile.usualBedtimeMinutes ?? 22 * 60;
      final lead = settings.bedtimeReminderLeadMinutes.clamp(5, 120);
      await _scheduleDaily(
        id: _bedtimeId,
        title: 'Wind down soon',
        body: 'Your bedtime is coming up. Start winding down for better recovery.',
        minutes: normalizeMinutes(bedtime - lead),
        location: location,
        details: details,
        payload: ReminderKind.bedtime.payload,
      );

      final wake = profile.usualWakeTimeMinutes ?? 7 * 60;
      await _scheduleDaily(
        id: _wakeId,
        title: 'Good morning',
        body: 'Time to wake up and log how you slept.',
        minutes: wake,
        location: location,
        details: details,
        payload: ReminderKind.wake.payload,
      );
    }

    if (settings.eventRemindersEnabled) {
      final lead = settings.eventReminderLeadMinutes.clamp(5, 120);
      final now = tz.TZDateTime.now(location);
      for (final event in profile.scheduleEvents) {
        final eventLocal = tz.TZDateTime.from(event.startAt.toUtc(), location);
        final reminder = eventLocal.subtract(Duration(minutes: lead));
        if (!reminder.isAfter(now)) {
          continue;
        }

        await _plugin.zonedSchedule(
          id: _eventBaseId + event.eventId.hashCode.abs() % 500,
          title: 'Upcoming event',
          body: '${event.title} starts soon. Check your schedule.',
          scheduledDate: reminder,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: ReminderKind.event.payload,
        );
      }
    }
  }

  Future<void> _scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int minutes,
    required tz.Location location,
    required NotificationDetails details,
    required String payload,
  }) async {
    final now = tz.TZDateTime.now(location);
    final hour = (minutes ~/ 60) % 24;
    final minute = minutes % 60;
    var scheduled = tz.TZDateTime(
      location,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduled,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'Event, hydration, sleep, and meal reminders',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  void _handleNotificationResponse(NotificationResponse response) {
    if (response.notificationResponseType ==
        NotificationResponseType.notificationDismissed) {
      return;
    }
    _responseHandler?.call(response);
  }

  static List<int> mealReminderMinutes(UserProfile profile) {
    return _mealReminderMinutes(profile);
  }

  static List<int> hydrationReminderMinutes(UserProfile profile) {
    final wake = profile.usualWakeTimeMinutes ?? 7 * 60;
    final bedtime = profile.usualBedtimeMinutes ?? 22 * 60;
    var window = bedtime - wake;
    if (window <= 0) {
      window += 24 * 60;
    }

    return List.generate(3, (index) {
      final step = window ~/ 4;
      return normalizeMinutes(wake + step * (index + 1));
    });
  }

  static List<int> _mealReminderMinutes(UserProfile profile) {
    final wake = profile.usualWakeTimeMinutes ?? 7 * 60;
    final bedtime = profile.usualBedtimeMinutes ?? 22 * 60;
    final meals = profile.nutritionSettings.mealsPerDay.clamp(2, 5);
    var window = bedtime - wake;
    if (window <= 0) {
      window += 24 * 60;
    }
    final step = window ~/ (meals + 1);
    return List.generate(
      meals,
      (index) => normalizeMinutes(wake + step * (index + 1)),
    );
  }

  static tz.Location _locationFor(String timezone) {
    try {
      return tz.getLocation(timezone);
    } catch (_) {
      return tz.local;
    }
  }
}
