import 'package:timezone/timezone.dart' as tz;

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
