import 'package:nutrilens/models/firestore_map.dart';

class NotificationSettings {
  const NotificationSettings({
    this.eventRemindersEnabled = true,
    this.hydrationRemindersEnabled = true,
    this.sleepRemindersEnabled = false,
    this.mealRemindersEnabled = true,
    this.bedtimeReminderLeadMinutes = 30,
    this.eventReminderLeadMinutes = 30,
  });

  final bool eventRemindersEnabled;
  final bool hydrationRemindersEnabled;
  final bool sleepRemindersEnabled;
  final bool mealRemindersEnabled;
  final int bedtimeReminderLeadMinutes;
  final int eventReminderLeadMinutes;

  factory NotificationSettings.fromMap(
    Map<String, dynamic>? map, {
    bool fallbackMealRemindersEnabled = true,
  }) {
    if (map == null) {
      return NotificationSettings(
        mealRemindersEnabled: fallbackMealRemindersEnabled,
      );
    }

    final legacyBedtime = parseBool(map['bedtimeReminderEnabled']);
    final legacyWake = parseBool(map['wakeReminderEnabled']);

    return NotificationSettings(
      eventRemindersEnabled: parseBool(map['eventRemindersEnabled'], defaultValue: true),
      hydrationRemindersEnabled: parseBool(
        map['hydrationRemindersEnabled'],
        defaultValue: true,
      ),
      sleepRemindersEnabled: parseBool(
        map['sleepRemindersEnabled'],
        defaultValue: legacyBedtime || legacyWake,
      ),
      mealRemindersEnabled: parseBool(
        map['mealRemindersEnabled'],
        defaultValue: fallbackMealRemindersEnabled,
      ),
      bedtimeReminderLeadMinutes:
          parseInt(map['bedtimeReminderLeadMinutes']) ?? 30,
      eventReminderLeadMinutes: parseInt(map['eventReminderLeadMinutes']) ?? 30,
    );
  }

  Map<String, dynamic> toMap() => {
    'eventRemindersEnabled': eventRemindersEnabled,
    'hydrationRemindersEnabled': hydrationRemindersEnabled,
    'sleepRemindersEnabled': sleepRemindersEnabled,
    'mealRemindersEnabled': mealRemindersEnabled,
    'bedtimeReminderLeadMinutes': bedtimeReminderLeadMinutes,
    'eventReminderLeadMinutes': eventReminderLeadMinutes,
    // Legacy keys kept in sync for older builds.
    'bedtimeReminderEnabled': sleepRemindersEnabled,
    'wakeReminderEnabled': sleepRemindersEnabled,
  };

  NotificationSettings copyWith({
    bool? eventRemindersEnabled,
    bool? hydrationRemindersEnabled,
    bool? sleepRemindersEnabled,
    bool? mealRemindersEnabled,
    int? bedtimeReminderLeadMinutes,
    int? eventReminderLeadMinutes,
  }) {
    return NotificationSettings(
      eventRemindersEnabled:
          eventRemindersEnabled ?? this.eventRemindersEnabled,
      hydrationRemindersEnabled:
          hydrationRemindersEnabled ?? this.hydrationRemindersEnabled,
      sleepRemindersEnabled:
          sleepRemindersEnabled ?? this.sleepRemindersEnabled,
      mealRemindersEnabled:
          mealRemindersEnabled ?? this.mealRemindersEnabled,
      bedtimeReminderLeadMinutes:
          bedtimeReminderLeadMinutes ?? this.bedtimeReminderLeadMinutes,
      eventReminderLeadMinutes:
          eventReminderLeadMinutes ?? this.eventReminderLeadMinutes,
    );
  }

  bool get anyEnabled =>
      eventRemindersEnabled ||
      hydrationRemindersEnabled ||
      sleepRemindersEnabled ||
      mealRemindersEnabled;
}
