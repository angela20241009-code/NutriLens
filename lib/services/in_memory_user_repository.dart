import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/services/date_key.dart';
import 'package:nutrilens/services/firestore_serializer.dart';
import 'package:nutrilens/services/user_repository.dart';

/// Local in-memory implementation for tests and UI before Firebase init.
class InMemoryUserRepository implements UserRepository {
  InMemoryUserRepository({String? seedUid}) : _uid = seedUid;

  String? _uid;
  final Map<String, UserAccount> _accounts = {};
  final Map<String, UserProfile> _profiles = {};
  final Map<String, String> _emailToUid = {};
  final Map<String, String> _passwordByUid = {};
  final Map<String, SportProfile> _sportProfiles = {};
  final Map<String, TeamProgram> _teamPrograms = {};

  // uid → list of meals
  final Map<String, List<Meal>> _meals = {};
  // uid → (dateKey → DailySummary)
  final Map<String, Map<String, DailySummary>> _dailySummaries = {};
  int _accountCounter = 0;
  int _mealCounter = 0;

  @override
  String? get currentUid => _uid;

  @override
  Stream<String?> watchAuthUid() async* {
    yield _uid;
  }

  void seedCatalog({SportProfile? sportProfile, TeamProgram? teamProgram}) {
    if (sportProfile != null) {
      _sportProfiles[sportProfile.sportId] = sportProfile;
    }
    if (teamProgram != null) {
      _teamPrograms[teamProgram.programId] = teamProgram;
    }
  }

  @override
  Future<UserAccount?> getAccount(String uid) async => _accounts[uid];

  @override
  Future<UserProfile?> getProfile(String uid) async => _profiles[uid];

  @override
  Future<SportProfile?> getSportProfile(String sportId) async =>
      _sportProfiles[sportId];

  @override
  Future<TeamProgram?> getTeamProgram(String programId) async =>
      _teamPrograms[programId];

  @override
  Future<UserAccount> signInAnonymously({required String timezone}) async {
    final now = firestoreNow();
    final uid = 'local_${++_accountCounter}';
    _uid = uid;
    final account = UserAccount.anonymousShell(uid: uid, now: now);
    final profile = UserProfile.emptyShell(
      userId: uid,
      now: now,
      timezone: timezone,
    );
    _accounts[uid] = account;
    _profiles[uid] = profile;
    return account;
  }

  @override
  Future<UserAccount> createAccountWithEmail({
    required String email,
    required String password,
    required String timezone,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (_emailToUid.containsKey(normalizedEmail)) {
      throw StateError('email-already-in-use');
    }

    final now = firestoreNow();
    final uid = 'local_email_${++_accountCounter}';
    _uid = uid;
    final account = UserAccount(
      uid: uid,
      authProviders: const ['password'],
      email: normalizedEmail,
      emailVerified: false,
      accountStatus: AccountStatus.active,
      onboardingCompleted: false,
      createdAt: now,
      updatedAt: now,
      lastSeenAt: now,
    );
    final profile = UserProfile.emptyShell(
      userId: uid,
      now: now,
      timezone: timezone,
    );

    _accounts[uid] = account;
    _profiles[uid] = profile;
    _emailToUid[normalizedEmail] = uid;
    _passwordByUid[uid] = password;
    return account;
  }

  @override
  Future<UserAccount> signInWithEmail({
    required String email,
    required String password,
    required String timezone,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final uid = _emailToUid[normalizedEmail];
    if (uid == null || _passwordByUid[uid] != password) {
      throw StateError('invalid-credential');
    }
    _uid = uid;
    return ensureCurrentUserAccount(timezone: timezone);
  }

  @override
  Future<UserAccount> ensureCurrentUserAccount({
    required String timezone,
  }) async {
    final uid = _uid;
    if (uid == null) {
      throw StateError('No signed-in user');
    }
    final account = _accounts[uid];
    if (account == null) {
      final now = firestoreNow();
      final created = UserAccount.anonymousShell(uid: uid, now: now);
      _accounts[uid] = created;
      _profiles[uid] = UserProfile.emptyShell(
        userId: uid,
        now: now,
        timezone: timezone,
      );
      return created;
    }
    final updated = account.copyWith(lastSeenAt: firestoreNow());
    _accounts[uid] = updated;
    _profiles.putIfAbsent(
      uid,
      () => UserProfile.emptyShell(
        userId: uid,
        now: firestoreNow(),
        timezone: timezone,
      ),
    );
    return updated;
  }

  @override
  Future<UserProfile> completeOnboarding({
    required String uid,
    required UserProfile profile,
  }) async {
    final now = firestoreNow();
    final completed = profile.copyWith(
      onboardingStep: 'completed',
      onboardingCompletedAt: now,
      updatedAt: now,
    );
    _profiles[uid] = completed;
    final account = _accounts[uid];
    if (account != null) {
      _accounts[uid] = account.copyWith(
        onboardingCompleted: true,
        updatedAt: now,
      );
    }
    return completed;
  }

  @override
  Future<UserAccount> linkEmail({
    required String uid,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final existingUid = _emailToUid[normalizedEmail];
    if (existingUid != null && existingUid != uid) {
      throw StateError('email-already-in-use');
    }
    final account = _accounts[uid];
    if (account == null) {
      throw StateError('No account for uid $uid');
    }
    final now = firestoreNow();
    final linked = account.copyWith(
      email: email,
      emailVerified: false,
      authProviders: [
        ...account.authProviders.where((p) => p != 'anonymous'),
        'password',
      ],
      linkedAt: now,
      updatedAt: now,
    );
    _accounts[uid] = linked;
    _emailToUid[normalizedEmail] = uid;
    _passwordByUid[uid] = password;
    return linked;
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    _profiles[profile.userId] = profile.copyWith(updatedAt: firestoreNow());
  }

  @override
  Future<void> saveAccount(UserAccount account) async {
    _accounts[account.uid] = account.copyWith(updatedAt: firestoreNow());
  }

  // ── Meal logging ──────────────────────────────────────────────────────────

  @override
  Future<Meal> logMeal(String uid, Meal meal, String timezone) async {
    final mealId = 'local_meal_${++_mealCounter}';
    final savedMeal = meal.copyWith(mealId: mealId);
    _meals.putIfAbsent(uid, () => []).add(savedMeal);

    final dateKey = dateKeyFor(meal.loggedAt, timezone);
    final summaries = _dailySummaries.putIfAbsent(uid, () => {});
    final now = firestoreNow();
    final existing = summaries[dateKey];
    if (existing != null) {
      summaries[dateKey] = existing.copyWith(
        totals: existing.totals + meal.nutrition,
        mealCount: existing.mealCount + 1,
        updatedAt: now,
      );
    } else {
      summaries[dateKey] = DailySummary(
        uid: uid,
        dateKey: dateKey,
        totals: meal.nutrition,
        mealCount: 1,
        updatedAt: now,
      );
    }

    return savedMeal;
  }

  @override
  Future<List<Meal>> getMealsForDay(
    String uid,
    DateTime date,
    String timezone,
  ) async {
    final targetKey = dateKeyFor(date, timezone);
    final userMeals = _meals[uid] ?? [];
    return userMeals
        .where((m) => dateKeyFor(m.loggedAt, timezone) == targetKey)
        .toList()
      ..sort((a, b) => a.loggedAt.compareTo(b.loggedAt));
  }

  @override
  Future<List<Meal>> getRecentMeals(
    String uid, {
    required int limit,
    required String timezone,
  }) async {
    final meals = List<Meal>.from(_meals[uid] ?? [])
      ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
    return meals.take(limit).toList();
  }

  @override
  Future<Set<String>> getMealDateKeysInRange(
    String uid, {
    required String startDateKey,
    required String endDateKey,
  }) async {
    final summaries = _dailySummaries[uid] ?? {};
    return summaries.entries
        .where(
          (entry) =>
              entry.key.compareTo(startDateKey) >= 0 &&
              entry.key.compareTo(endDateKey) <= 0 &&
              entry.value.mealCount > 0,
        )
        .map((entry) => entry.key)
        .toSet();
  }

  @override
  Future<Set<String>> getSleepDateKeysInRange(
    String uid, {
    required String startDateKey,
    required String endDateKey,
  }) async {
    final summaries = _dailySummaries[uid] ?? {};
    return summaries.entries
        .where(
          (entry) =>
              entry.key.compareTo(startDateKey) >= 0 &&
              entry.key.compareTo(endDateKey) <= 0 &&
              entry.value.sleepHours > 0,
        )
        .map((entry) => entry.key)
        .toSet();
  }

  @override
  Future<Map<String, DailySummary>> getDailySummariesInRange(
    String uid, {
    required String startDateKey,
    required String endDateKey,
  }) async {
    final summaries = _dailySummaries[uid] ?? {};
    return Map.fromEntries(
      summaries.entries.where(
        (entry) =>
            entry.key.compareTo(startDateKey) >= 0 &&
            entry.key.compareTo(endDateKey) <= 0,
      ),
    );
  }

  // ── Daily summaries ───────────────────────────────────────────────────────

  @override
  Future<DailySummary?> getDailySummary(String uid, String dateKey) async {
    return _dailySummaries[uid]?[dateKey];
  }

  @override
  Future<void> updateDailySummary(
    String uid,
    String dateKey, {
    double? hydrationLiters,
    double? sleepHours,
  }) async {
    final summaries = _dailySummaries.putIfAbsent(uid, () => {});
    final now = firestoreNow();
    final existing = summaries[dateKey];
    if (existing != null) {
      summaries[dateKey] = existing.copyWith(
        hydrationLiters: hydrationLiters ?? existing.hydrationLiters,
        sleepHours: sleepHours ?? existing.sleepHours,
        updatedAt: now,
      );
    } else {
      summaries[dateKey] = DailySummary(
        uid: uid,
        dateKey: dateKey,
        totals: const NutritionEntry(),
        mealCount: 0,
        hydrationLiters: hydrationLiters ?? 0,
        sleepHours: sleepHours ?? 0,
        updatedAt: now,
      );
    }
  }

  @override
  Future<void> deleteAccount(String uid) async {
    final account = _accounts[uid];
    final email = account?.email?.trim().toLowerCase();
    if (email != null && email.isNotEmpty) {
      _emailToUid.remove(email);
    }
    _passwordByUid.remove(uid);
    _accounts.remove(uid);
    _profiles.remove(uid);
    _meals.remove(uid);
    _dailySummaries.remove(uid);
    if (_uid == uid) {
      _uid = null;
    }
  }

  @override
  Future<void> signOut() async {
    _uid = null;
  }
}
