import 'package:nutrilens/models/firestore_map.dart';

class HealthSync {
  const HealthSync({
    this.appleHealthEnabled = false,
    this.googleFitEnabled = false,
    this.lastSyncAt,
    this.scopesGranted = const [],
  });

  final bool appleHealthEnabled;
  final bool googleFitEnabled;
  final DateTime? lastSyncAt;
  final List<String> scopesGranted;

  factory HealthSync.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const HealthSync();
    return HealthSync(
      appleHealthEnabled: parseBool(map['appleHealthEnabled']),
      googleFitEnabled: parseBool(map['googleFitEnabled']),
      lastSyncAt: parseDateTime(map['lastSyncAt']),
      scopesGranted: parseStringList(map['scopesGranted']),
    );
  }

  Map<String, dynamic> toMap() => {
    'appleHealthEnabled': appleHealthEnabled,
    'googleFitEnabled': googleFitEnabled,
    'lastSyncAt': iso8601OrNull(lastSyncAt),
    'scopesGranted': scopesGranted,
  };

  HealthSync copyWith({
    bool? appleHealthEnabled,
    bool? googleFitEnabled,
    DateTime? lastSyncAt,
    List<String>? scopesGranted,
  }) {
    return HealthSync(
      appleHealthEnabled: appleHealthEnabled ?? this.appleHealthEnabled,
      googleFitEnabled: googleFitEnabled ?? this.googleFitEnabled,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      scopesGranted: scopesGranted ?? this.scopesGranted,
    );
  }
}
