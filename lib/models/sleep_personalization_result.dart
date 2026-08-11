class SleepPersonalizationResult {
  const SleepPersonalizationResult({
    required this.sleepHours,
    required this.bedtimeMinutes,
    required this.wakeTimeMinutes,
    required this.summary,
  });

  final double sleepHours;
  final int bedtimeMinutes;
  final int wakeTimeMinutes;
  final String summary;
}
