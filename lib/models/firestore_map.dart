/// Helpers for converting Firestore document maps to Dart types.
DateTime? parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  // cloud_firestore Timestamp exposes seconds/nanoseconds via dynamic map.
  if (value is Map) {
    final seconds = value['seconds'];
    if (seconds is int) {
      return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    }
  }
  final seconds = _timestampSeconds(value);
  if (seconds is int) {
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  }
  return null;
}

int? _timestampSeconds(dynamic value) {
  try {
    final seconds = (value as dynamic).seconds;
    if (seconds is int) return seconds;
  } catch (_) {}
  return null;
}

DateTime parseRequiredDateTime(dynamic value, {String field = 'timestamp'}) {
  return parseDateTime(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
}

String? parseString(dynamic value) => value?.toString();

int? parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.round();
  return int.tryParse(value.toString());
}

double? parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

bool parseBool(dynamic value, {bool defaultValue = false}) {
  if (value is bool) return value;
  return defaultValue;
}

List<String> parseStringList(dynamic value) {
  if (value is! List) return const [];
  return value.map((e) => e.toString()).toList();
}

String? iso8601OrNull(DateTime? value) => value?.toUtc().toIso8601String();
