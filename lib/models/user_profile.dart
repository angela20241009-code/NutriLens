import 'package:nutrilens/models/daily_targets.dart';
import 'package:nutrilens/models/dietary_profile.dart';
import 'package:nutrilens/models/firestore_map.dart';
import 'package:nutrilens/models/health_sync.dart';
import 'package:nutrilens/models/nutrition_settings.dart';
import 'package:nutrilens/models/stats_cache.dart';

enum UserRole {
  athlete('athlete'),
  coach('coach');

  const UserRole(this.firestoreValue);
  final String firestoreValue;

  static UserRole fromFirestore(String? value) {
    return UserRole.values.firstWhere(
      (e) => e.firestoreValue == value,
      orElse: () => UserRole.athlete,
    );
  }
}

class UserProfile {
  const UserProfile({
    required this.userId,
    required this.displayName,
    this.firstName,
    this.lastName,
    this.avatarStoragePath,
    this.avatarUrl,
    this.schoolName,
    this.graduationYear,
    required this.timezone,
    this.locale = 'en-US',
    required this.primarySportId,
    required this.primarySportName,
    this.secondarySportIds = const [],
    this.teamProgramId,
    this.teamProgramName,
    this.programTier,
    this.role = UserRole.athlete,
    this.sex,
    this.birthYear,
    this.heightCm,
    this.weightKg,
    this.activityLevel,
    this.trainingDaysPerWeek,
    required this.dailyTargets,
    this.activeGoalId,
    this.dietaryProfile = const DietaryProfile(),
    this.nutritionSettings = const NutritionSettings(),
    this.healthSync = const HealthSync(),
    this.statsCache,
    this.statsCacheUpdatedAt,
    this.onboardingStep,
    this.onboardingCompletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String userId;
  final String displayName;
  final String? firstName;
  final String? lastName;
  final String? avatarStoragePath;
  final String? avatarUrl;
  final String? schoolName;
  final int? graduationYear;
  final String timezone;
  final String locale;
  final String primarySportId;
  final String primarySportName;
  final List<String> secondarySportIds;
  final String? teamProgramId;
  final String? teamProgramName;
  final String? programTier;
  final UserRole role;
  final String? sex;
  final int? birthYear;
  final double? heightCm;
  final double? weightKg;
  final String? activityLevel;
  final int? trainingDaysPerWeek;
  final DailyTargets dailyTargets;
  final String? activeGoalId;
  final DietaryProfile dietaryProfile;
  final NutritionSettings nutritionSettings;
  final HealthSync healthSync;
  final StatsCache? statsCache;
  final DateTime? statsCacheUpdatedAt;
  final String? onboardingStep;
  final DateTime? onboardingCompletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory UserProfile.fromMap(Map<String, dynamic> map, {required String userId}) {
    final statsRaw = map['statsCache'];
    return UserProfile(
      userId: map['userId'] as String? ?? userId,
      displayName: map['displayName'] as String? ?? '',
      firstName: map['firstName'] as String?,
      lastName: map['lastName'] as String?,
      avatarStoragePath: map['avatarStoragePath'] as String?,
      avatarUrl: map['avatarUrl'] as String?,
      schoolName: map['schoolName'] as String?,
      graduationYear: parseInt(map['graduationYear']),
      timezone: map['timezone'] as String? ?? 'UTC',
      locale: map['locale'] as String? ?? 'en-US',
      primarySportId: map['primarySportId'] as String? ?? '',
      primarySportName: map['primarySportName'] as String? ?? '',
      secondarySportIds: parseStringList(map['secondarySportIds']),
      teamProgramId: map['teamProgramId'] as String?,
      teamProgramName: map['teamProgramName'] as String?,
      programTier: map['programTier'] as String?,
      role: UserRole.fromFirestore(map['role'] as String?),
      sex: map['sex'] as String?,
      birthYear: parseInt(map['birthYear']),
      heightCm: parseDouble(map['heightCm']),
      weightKg: parseDouble(map['weightKg']),
      activityLevel: map['activityLevel'] as String?,
      trainingDaysPerWeek: parseInt(map['trainingDaysPerWeek']),
      dailyTargets: DailyTargets.fromMap(
        Map<String, dynamic>.from(map['dailyTargets'] as Map? ?? {}),
      ),
      activeGoalId: map['activeGoalId'] as String?,
      dietaryProfile: DietaryProfile.fromMap(
        map['dietaryProfile'] != null
            ? Map<String, dynamic>.from(map['dietaryProfile'] as Map)
            : null,
      ),
      nutritionSettings: NutritionSettings.fromMap(
        map['nutritionSettings'] != null
            ? Map<String, dynamic>.from(map['nutritionSettings'] as Map)
            : null,
      ),
      healthSync: HealthSync.fromMap(
        map['healthSync'] != null
            ? Map<String, dynamic>.from(map['healthSync'] as Map)
            : null,
      ),
      statsCache: statsRaw != null
          ? StatsCache.fromMap(Map<String, dynamic>.from(statsRaw as Map))
          : null,
      statsCacheUpdatedAt: parseDateTime(map['statsCacheUpdatedAt']),
      onboardingStep: map['onboardingStep'] as String?,
      onboardingCompletedAt: parseDateTime(map['onboardingCompletedAt']),
      createdAt: parseRequiredDateTime(map['createdAt']),
      updatedAt: parseRequiredDateTime(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'displayName': displayName,
    'firstName': firstName,
    'lastName': lastName,
    'avatarStoragePath': avatarStoragePath,
    'avatarUrl': avatarUrl,
    'schoolName': schoolName,
    'graduationYear': graduationYear,
    'timezone': timezone,
    'locale': locale,
    'primarySportId': primarySportId,
    'primarySportName': primarySportName,
    'secondarySportIds': secondarySportIds,
    'teamProgramId': teamProgramId,
    'teamProgramName': teamProgramName,
    'programTier': programTier,
    'role': role.firestoreValue,
    'sex': sex,
    'birthYear': birthYear,
    'heightCm': heightCm,
    'weightKg': weightKg,
    'activityLevel': activityLevel,
    'trainingDaysPerWeek': trainingDaysPerWeek,
    'dailyTargets': dailyTargets.toMap(),
    'activeGoalId': activeGoalId,
    'dietaryProfile': dietaryProfile.toMap(),
    'nutritionSettings': nutritionSettings.toMap(),
    'healthSync': healthSync.toMap(),
    'statsCache': statsCache?.toMap(),
    'statsCacheUpdatedAt': iso8601OrNull(statsCacheUpdatedAt),
    'onboardingStep': onboardingStep,
    'onboardingCompletedAt': iso8601OrNull(onboardingCompletedAt),
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
  };

  factory UserProfile.emptyShell({
    required String userId,
    required DateTime now,
    required String timezone,
  }) {
    return UserProfile(
      userId: userId,
      displayName: '',
      timezone: timezone,
      primarySportId: '',
      primarySportName: '',
      dailyTargets: DailyTargets(
        caloriesKcal: 0,
        proteinG: 0,
        carbsG: 0,
        fatsG: 0,
        hydrationLiters: 0,
        sleepHours: 8,
        source: DailyTargetsSource.sportDefaults,
        effectiveFrom: now,
      ),
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Demo persona aligned with [MockHomeData].
  factory UserProfile.demoAngela({
    required String userId,
    required DateTime now,
  }) {
    return UserProfile(
      userId: userId,
      displayName: 'Angela',
      schoolName: 'Lincoln High',
      timezone: 'America/Los_Angeles',
      primarySportId: 'tennis',
      primarySportName: 'Tennis',
      teamProgramId: 'lincoln_high_tennis',
      teamProgramName: 'Lincoln High Tennis Program',
      programTier: 'FREE',
      dailyTargets: DailyTargets(
        caloriesKcal: 3200,
        proteinG: 180,
        carbsG: 440,
        fatsG: 90,
        hydrationLiters: 3.5,
        sleepHours: 8,
        source: DailyTargetsSource.sportDefaults,
        effectiveFrom: now,
      ),
      onboardingStep: 'completed',
      onboardingCompletedAt: now,
      createdAt: now,
      updatedAt: now,
    );
  }

  UserProfile copyWith({
    String? displayName,
    String? firstName,
    String? lastName,
    String? avatarStoragePath,
    String? avatarUrl,
    String? schoolName,
    int? graduationYear,
    String? timezone,
    String? locale,
    String? primarySportId,
    String? primarySportName,
    List<String>? secondarySportIds,
    String? teamProgramId,
    String? teamProgramName,
    String? programTier,
    UserRole? role,
    String? sex,
    int? birthYear,
    double? heightCm,
    double? weightKg,
    String? activityLevel,
    int? trainingDaysPerWeek,
    DailyTargets? dailyTargets,
    String? activeGoalId,
    DietaryProfile? dietaryProfile,
    NutritionSettings? nutritionSettings,
    HealthSync? healthSync,
    StatsCache? statsCache,
    DateTime? statsCacheUpdatedAt,
    String? onboardingStep,
    DateTime? onboardingCompletedAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      userId: userId,
      displayName: displayName ?? this.displayName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatarStoragePath: avatarStoragePath ?? this.avatarStoragePath,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      schoolName: schoolName ?? this.schoolName,
      graduationYear: graduationYear ?? this.graduationYear,
      timezone: timezone ?? this.timezone,
      locale: locale ?? this.locale,
      primarySportId: primarySportId ?? this.primarySportId,
      primarySportName: primarySportName ?? this.primarySportName,
      secondarySportIds: secondarySportIds ?? this.secondarySportIds,
      teamProgramId: teamProgramId ?? this.teamProgramId,
      teamProgramName: teamProgramName ?? this.teamProgramName,
      programTier: programTier ?? this.programTier,
      role: role ?? this.role,
      sex: sex ?? this.sex,
      birthYear: birthYear ?? this.birthYear,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      trainingDaysPerWeek: trainingDaysPerWeek ?? this.trainingDaysPerWeek,
      dailyTargets: dailyTargets ?? this.dailyTargets,
      activeGoalId: activeGoalId ?? this.activeGoalId,
      dietaryProfile: dietaryProfile ?? this.dietaryProfile,
      nutritionSettings: nutritionSettings ?? this.nutritionSettings,
      healthSync: healthSync ?? this.healthSync,
      statsCache: statsCache ?? this.statsCache,
      statsCacheUpdatedAt: statsCacheUpdatedAt ?? this.statsCacheUpdatedAt,
      onboardingStep: onboardingStep ?? this.onboardingStep,
      onboardingCompletedAt:
          onboardingCompletedAt ?? this.onboardingCompletedAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
