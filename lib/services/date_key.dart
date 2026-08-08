import 'package:timezone/timezone.dart' as tz;

/// Returns the calendar date for [instant] in the given IANA [timezone].
///
/// Falls back to the UTC calendar date if [timezone] is unknown.
DateTime calendarDateFor(DateTime instant, String timezone) {
  try {
    final location = tz.getLocation(timezone);
    final tzDateTime = tz.TZDateTime.from(instant.toUtc(), location);
    return DateTime(tzDateTime.year, tzDateTime.month, tzDateTime.day);
  } catch (_) {
    final utc = instant.toUtc();
    return DateTime.utc(utc.year, utc.month, utc.day);
  }
}

/// Returns a `yyyy-MM-dd` date key for a calendar date in the given IANA [timezone].
///
/// Uses local noon to avoid device-timezone drift when converting bare dates.
String dateKeyForCalendarDate(
  int year,
  int month,
  int day,
  String timezone,
) {
  try {
    final location = tz.getLocation(timezone);
    final localMidday = tz.TZDateTime(location, year, month, day, 12);
    return dateKeyFor(localMidday.toUtc(), timezone);
  } catch (_) {
    return '${year.toString().padLeft(4, '0')}-'
        '${month.toString().padLeft(2, '0')}-'
        '${day.toString().padLeft(2, '0')}';
  }
}

/// Returns a `yyyy-MM-dd` date key for [date]'s year/month/day in [timezone].
String dateKeyForCalendarDateTime(DateTime date, String timezone) {
  return dateKeyForCalendarDate(date.year, date.month, date.day, timezone);
}

/// Returns a `yyyy-MM-dd` date key for [instant] in the given IANA [timezone].
///
/// Uses the `timezone` package's IANA database for correct DST handling.
/// Falls back to UTC if [timezone] is unknown (unrecognized zone name).
String dateKeyFor(DateTime instant, String timezone) {
  late DateTime local;
  try {
    final location = tz.getLocation(timezone);
    final tzDateTime = tz.TZDateTime.from(instant.toUtc(), location);
    local = tzDateTime;
  } catch (_) {
    // Unknown timezone — fall back to UTC.
    local = instant.toUtc();
  }

  final year = local.year.toString().padLeft(4, '0');
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
