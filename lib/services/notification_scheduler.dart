import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nutrilens/features/sleep/sleep_logging.dart';
import 'package:nutrilens/models/user_profile.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationScheduler {
  NotificationScheduler._();

  static final NotificationScheduler instance = NotificationScheduler._();

  static const _channelId = 'nutrilens_reminders';
  static const _channelName = 'NutriLens reminders';
  static const _mealBaseId = 1000;
  static const _bedtimeId = 2000;
  static const _wakeId = 2001;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
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
          description: 'Meal, bedtime, and wake-up reminders',
          importance: Importance.high,
        ),
      );
    }

    _initialized = true;
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
    if (!settings.mealRemindersEnabled &&
        !settings.bedtimeReminderEnabled &&
        !settings.wakeReminderEnabled) {
      return;
    }

    final location = _locationFor(profile.timezone);
    final details = _notificationDetails();

    if (settings.mealRemindersEnabled) {
      final mealTimes = _mealReminderMinutes(profile);
      for (var index = 0; index < mealTimes.length; index++) {
        await _scheduleDaily(
          id: _mealBaseId + index,
          title: 'Time to fuel up',
          body: 'Log your meal to stay on track with your nutrition plan.',
          minutes: mealTimes[index],
          location: location,
          details: details,
        );
      }
    }

    if (settings.bedtimeReminderEnabled) {
      final bedtime = profile.usualBedtimeMinutes ?? 22 * 60;
      final lead = settings.bedtimeReminderLeadMinutes.clamp(5, 120);
      await _scheduleDaily(
        id: _bedtimeId,
        title: 'Wind down soon',
        body: 'Your bedtime is coming up. Start winding down for better recovery.',
        minutes: normalizeMinutes(bedtime - lead),
        location: location,
        details: details,
      );
    }

    if (settings.wakeReminderEnabled) {
      final wake = profile.usualWakeTimeMinutes ?? 7 * 60;
      await _scheduleDaily(
        id: _wakeId,
        title: 'Good morning',
        body: 'Time to wake up and log how you slept.',
        minutes: wake,
        location: location,
        details: details,
      );
    }
  }

  Future<void> _scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int minutes,
    required tz.Location location,
    required NotificationDetails details,
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
    );
  }

  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'Meal, bedtime, and wake-up reminders',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  static List<int> mealReminderMinutes(UserProfile profile) {
    return _mealReminderMinutes(profile);
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
