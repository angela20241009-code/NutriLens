enum ReminderKind {
  event,
  hydration,
  meal,
  bedtime,
  wake;

  static ReminderKind? fromPayload(String? payload) {
    return switch (payload) {
      'event' => ReminderKind.event,
      'hydration' => ReminderKind.hydration,
      'meal' => ReminderKind.meal,
      'bedtime' => ReminderKind.bedtime,
      'wake' => ReminderKind.wake,
      _ => null,
    };
  }

  String get payload => name;
}
