import 'package:nutrilens/models/firestore_map.dart';

class TeamProgram {
  const TeamProgram({
    required this.programId,
    required this.name,
    required this.schoolName,
    required this.tier,
    this.primarySportId,
    this.memberCount,
  });

  final String programId;
  final String name;
  final String schoolName;
  final String tier;
  final String? primarySportId;
  final int? memberCount;

  factory TeamProgram.fromMap(Map<String, dynamic> map, {required String programId}) {
    return TeamProgram(
      programId: map['programId'] as String? ?? programId,
      name: map['name'] as String? ?? '',
      schoolName: map['schoolName'] as String? ?? '',
      tier: map['tier'] as String? ?? 'FREE',
      primarySportId: map['primarySportId'] as String?,
      memberCount: parseInt(map['memberCount']),
    );
  }

  Map<String, dynamic> toMap() => {
    'programId': programId,
    'name': name,
    'schoolName': schoolName,
    'tier': tier,
    'primarySportId': primarySportId,
    'memberCount': memberCount,
  };
}
