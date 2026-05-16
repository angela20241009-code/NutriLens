import 'package:nutrilens/models/daily_targets.dart';
import 'package:nutrilens/models/firestore_map.dart';

class SportProfile {
  const SportProfile({
    required this.sportId,
    required this.displayName,
    this.iconAsset,
    required this.defaultDailyTargets,
    this.fuelingWindowTemplateIds = const [],
    this.activityLevelHints = const [],
  });

  final String sportId;
  final String displayName;
  final String? iconAsset;
  final DailyTargets defaultDailyTargets;
  final List<String> fuelingWindowTemplateIds;
  final List<String> activityLevelHints;

  factory SportProfile.fromMap(Map<String, dynamic> map, {required String sportId}) {
    return SportProfile(
      sportId: map['sportId'] as String? ?? sportId,
      displayName: map['displayName'] as String? ?? '',
      iconAsset: map['iconAsset'] as String?,
      defaultDailyTargets: DailyTargets.fromMap(
        Map<String, dynamic>.from(map['defaultDailyTargets'] as Map? ?? {}),
      ),
      fuelingWindowTemplateIds: parseStringList(map['fuelingWindowTemplateIds']),
      activityLevelHints: parseStringList(map['activityLevelHints']),
    );
  }

  Map<String, dynamic> toMap() => {
    'sportId': sportId,
    'displayName': displayName,
    'iconAsset': iconAsset,
    'defaultDailyTargets': defaultDailyTargets.toMap(),
    'fuelingWindowTemplateIds': fuelingWindowTemplateIds,
    'activityLevelHints': activityLevelHints,
  };
}
