import 'package:cloud_firestore/cloud_firestore.dart';

/// Converts model maps for Firestore writes (ISO strings → Timestamp).
Map<String, dynamic> toFirestoreMap(Map<String, dynamic> map) {
  final result = <String, dynamic>{};
  map.forEach((key, value) {
    result[key] = _toFirestoreValue(value);
  });
  return result;
}

dynamic _toFirestoreValue(dynamic value) {
  if (value == null) return null;
  if (value is String && _looksLikeIso8601(value)) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return Timestamp.fromDate(parsed.toUtc());
  }
  if (value is Map) {
    return toFirestoreMap(Map<String, dynamic>.from(value));
  }
  if (value is List) {
    return value.map(_toFirestoreValue).toList();
  }
  return value;
}

bool _looksLikeIso8601(String value) {
  return value.contains('T') && value.contains('-');
}

/// Converts a Firestore document map for model parsing.
Map<String, dynamic> fromFirestoreMap(Map<String, dynamic> map) {
  final result = <String, dynamic>{};
  map.forEach((key, value) {
    result[key] = _fromFirestoreValue(value);
  });
  return result;
}

dynamic _fromFirestoreValue(dynamic value) {
  if (value is Timestamp) {
    return value.toDate().toUtc().toIso8601String();
  }
  if (value is Map) {
    return fromFirestoreMap(Map<String, dynamic>.from(value));
  }
  if (value is List) {
    return value.map(_fromFirestoreValue).toList();
  }
  return value;
}

DateTime firestoreNow() => DateTime.now().toUtc();
