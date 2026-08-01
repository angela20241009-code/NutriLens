import 'package:nutrilens/models/firestore_map.dart';

class NotificationSettings {
  const NotificationSettings({
    this.mealRemindersEnabled = true,
    this.bedtimeReminderEnabled = false,
    this.wakeReminderEnabled = false,
    this.bedtimeReminderLeadMinutes = 30,
  });

  final bool mealRemindersEnabled;
  final bool bedtimeReminderEnabled;
  final bool wakeReminderEnabled;
  final int bedtimeReminderLeadMinutes;

  factory NotificationSettings.fromMap(
    Map<String, dynamic>? map, {
    bool fallbackMealRemindersEnabled = true,
  }) {
    if (map == null) {
      return NotificationSettings(
        mealRemindersEnabled: fallbackMealRemindersEnabled,
      );
    }
    return NotificationSettings(
      mealRemindersEnabled: parseBool(
        map['mealRemindersEnabled'],
        defaultValue: fallbackMealRemindersEnabled,
      ),
      bedtimeReminderEnabled: parseBool(map['bedtimeReminderEnabled']),
      wakeReminderEnabled: parseBool(map['wakeReminderEnabled']),
      bedtimeReminderLeadMinutes:
          parseInt(map['bedtimeReminderLeadMinutes']) ?? 30,
    );
  }

  Map<String, dynamic> toMap() => {
    'mealRemindersEnabled': mealRemindersEnabled,
    'bedtimeReminderEnabled': bedtimeReminderEnabled,
    'wakeReminderEnabled': wakeReminderEnabled,
    'bedtimeReminderLeadMinutes': bedtimeReminderLeadMinutes,
  };

  NotificationSettings copyWith({
    bool? mealRemindersEnabled,
    bool? bedtimeReminderEnabled,
    bool? wakeReminderEnabled,
    int? bedtimeReminderLeadMinutes,
  }) {
    return NotificationSettings(
      mealRemindersEnabled:
          mealRemindersEnabled ?? this.mealRemindersEnabled,
      bedtimeReminderEnabled:
          bedtimeReminderEnabled ?? this.bedtimeReminderEnabled,
      wakeReminderEnabled: wakeReminderEnabled ?? this.wakeReminderEnabled,
      bedtimeReminderLeadMinutes:
          bedtimeReminderLeadMinutes ?? this.bedtimeReminderLeadMinutes,
    );
  }
}
