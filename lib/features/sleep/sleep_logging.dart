import 'package:flutter/material.dart';
import 'package:nutrilens/models/models.dart';
import 'package:timezone/timezone.dart' as tz;

const _minutesPerDay = 24 * 60;

int normalizeMinutes(int minutes) {
  final normalized = minutes % _minutesPerDay;
  return normalized < 0 ? normalized + _minutesPerDay : normalized;
}

int sleepDurationMinutes({
  required int bedtimeMinutes,
  required int wakeTimeMinutes,
}) {
  final bedtime = normalizeMinutes(bedtimeMinutes);
  final wakeTime = normalizeMinutes(wakeTimeMinutes);
  var duration = wakeTime - bedtime;
  if (duration <= 0) {
    duration += _minutesPerDay;
  }
  return duration;
}

double sleepDurationHours({
  required int bedtimeMinutes,
  required int wakeTimeMinutes,
}) {
  final durationMinutes = sleepDurationMinutes(
    bedtimeMinutes: bedtimeMinutes,
    wakeTimeMinutes: wakeTimeMinutes,
  );
  return durationMinutes / 60;
}

String formatMinutesAsClock(int minutes) {
  final time = TimeOfDay(
    hour: normalizeMinutes(minutes) ~/ 60,
    minute: normalizeMinutes(minutes) % 60,
  );
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minute $period';
}

String formatDurationMinutes(int minutes) {
  final hours = minutes ~/ 60;
  final remainder = minutes % 60;
  if (remainder == 0) {
    return '${hours}h';
  }
  return '${hours}h ${remainder}m';
}

String formatSleepHours(double hours) {
  final durationMinutes = (hours * 60).round();
  return formatDurationMinutes(durationMinutes);
}

DateTime localDateTimeFor(DateTime instantUtc, String timezone) {
  try {
    final location = tz.getLocation(timezone);
    return tz.TZDateTime.from(instantUtc.toUtc(), location);
  } catch (_) {
    return instantUtc.toLocal();
  }
}

class SleepAdvice {
  const SleepAdvice({
    required this.title,
    required this.shortLine,
    required this.details,
    required this.recommendedBedtimeMinutes,
    required this.recommendedWakeTimeMinutes,
  });

  final String title;
  final String shortLine;
  final String details;
  final int recommendedBedtimeMinutes;
  final int recommendedWakeTimeMinutes;
}

SleepAdvice buildSleepAdvice({
  required UserProfile profile,
  required double sleepHours,
  required int wakeTimeMinutes,
  required DateTime referenceUtc,
}) {
  final targetHours = profile.dailyTargets.sleepHours;
  final targetMinutes = (targetHours * 60).round();
  final loggedMinutes = (sleepHours * 60).round();
  final deficitMinutes = targetMinutes - loggedMinutes;

  final wakeRecommendation = _recommendedWakeTime(
    profile: profile,
    fallbackWakeTimeMinutes: wakeTimeMinutes,
    referenceUtc: referenceUtc,
  );
  final bedtime = normalizeMinutes(
    wakeRecommendation.wakeTimeMinutes - targetMinutes,
  );

  if (deficitMinutes <= -30) {
    return SleepAdvice(
      title: 'Recovery is ahead',
      shortLine:
          'You slept ${formatSleepHours(sleepHours)}, above your ${targetHours.toStringAsFixed(1)}h target.',
      details:
          'Keep bedtime near ${formatMinutesAsClock(bedtime)} and wake around ${formatMinutesAsClock(wakeRecommendation.wakeTimeMinutes)} to stay consistent.',
      recommendedBedtimeMinutes: bedtime,
      recommendedWakeTimeMinutes: wakeRecommendation.wakeTimeMinutes,
    );
  }

  if (deficitMinutes <= 30) {
    return SleepAdvice(
      title: 'On target',
      shortLine:
          'You slept ${formatSleepHours(sleepHours)}, matching your ${targetHours.toStringAsFixed(1)}h goal.',
      details:
          'Stay on rhythm with bedtime around ${formatMinutesAsClock(bedtime)} and wake around ${formatMinutesAsClock(wakeRecommendation.wakeTimeMinutes)}.',
      recommendedBedtimeMinutes: bedtime,
      recommendedWakeTimeMinutes: wakeRecommendation.wakeTimeMinutes,
    );
  }

  final deficitHours = deficitMinutes / 60;
  final eventNote = wakeRecommendation.reason == null
      ? ''
      : ' ${wakeRecommendation.reason}';
  return SleepAdvice(
    title: 'Sleep needs a boost',
    shortLine:
        'You are about ${deficitHours.toStringAsFixed(1)}h under your ${targetHours.toStringAsFixed(1)}h target.',
    details:
        'Tonight, aim for bedtime near ${formatMinutesAsClock(bedtime)} so you can wake at ${formatMinutesAsClock(wakeRecommendation.wakeTimeMinutes)} with better recovery.$eventNote',
    recommendedBedtimeMinutes: bedtime,
    recommendedWakeTimeMinutes: wakeRecommendation.wakeTimeMinutes,
  );
}

class _WakeRecommendation {
  const _WakeRecommendation({required this.wakeTimeMinutes, this.reason});

  final int wakeTimeMinutes;
  final String? reason;
}

_WakeRecommendation _recommendedWakeTime({
  required UserProfile profile,
  required int fallbackWakeTimeMinutes,
  required DateTime referenceUtc,
}) {
  final defaultWake = profile.usualWakeTimeMinutes ?? fallbackWakeTimeMinutes;
  final nextEvent = _nextTrainingOrMatch(profile, referenceUtc);
  if (nextEvent == null) {
    return _WakeRecommendation(wakeTimeMinutes: defaultWake);
  }

  final eventLocal = localDateTimeFor(nextEvent.startAt, profile.timezone);
  final eventMinutes = eventLocal.hour * 60 + eventLocal.minute;
  final prepWake = (eventMinutes - 120).clamp(0, _minutesPerDay - 1);
  if (prepWake >= defaultWake) {
    return _WakeRecommendation(wakeTimeMinutes: defaultWake);
  }

  return _WakeRecommendation(
    wakeTimeMinutes: prepWake,
    reason:
        'An earlier wake is suggested before ${nextEvent.title} at ${formatMinutesAsClock(eventMinutes)}.',
  );
}

UserScheduleEvent? _nextTrainingOrMatch(
  UserProfile profile,
  DateTime referenceUtc,
) {
  final now = referenceUtc.toUtc();
  final cutoff = now.add(const Duration(hours: 36));
  final upcoming =
      profile.scheduleEvents
          .where(
            (event) =>
                (event.type == ScheduleEventType.training ||
                    event.type == ScheduleEventType.match) &&
                event.startAt.isAfter(now) &&
                event.startAt.isBefore(cutoff),
          )
          .toList()
        ..sort((a, b) => a.startAt.compareTo(b.startAt));
  return upcoming.firstOrNull;
}
