import 'package:nutrilens/models/models.dart';

/// Persistence and auth lifecycle for user account + athlete profile.
abstract class UserRepository {
  String? get currentUid;

  Stream<String?> watchAuthUid();

  Future<UserAccount?> getAccount(String uid);

  Future<UserProfile?> getProfile(String uid);

  Future<SportProfile?> getSportProfile(String sportId);

  Future<TeamProgram?> getTeamProgram(String programId);

  /// Signs in anonymously and creates `users/{uid}` + empty `userProfiles/{uid}`.
  Future<UserAccount> signInAnonymously({required String timezone});

  /// Creates an email/password account and initializes account/profile docs.
  Future<UserAccount> createAccountWithEmail({
    required String email,
    required String password,
    required String timezone,
  });

  /// Signs in with email/password and ensures account/profile docs exist.
  Future<UserAccount> signInWithEmail({
    required String email,
    required String password,
    required String timezone,
  });

  /// Ensures the current authenticated user has account/profile docs.
  Future<UserAccount> ensureCurrentUserAccount({required String timezone});

  /// Persists onboarding profile fields and marks account onboarding complete.
  Future<UserProfile> completeOnboarding({
    required String uid,
    required UserProfile profile,
  });

  /// Links email to an anonymous account (Auth + Firestore `users` doc).
  Future<UserAccount> linkEmail({
    required String uid,
    required String email,
    required String password,
  });

  Future<void> saveProfile(UserProfile profile);

  Future<void> saveAccount(UserAccount account);

  // ── Meal logging ──────────────────────────────────────────────────────────

  /// Persists [meal] under `meals/{uid}/entries` and updates the
  /// `DailySummary` for the meal's calendar day in a single transaction.
  ///
  /// [timezone] (IANA name) is used to derive the `dateKey` for the summary.
  /// Returns the saved [Meal] with the assigned `mealId`.
  Future<Meal> logMeal(String uid, Meal meal, String timezone);

  /// Returns all meals for [uid] on the calendar day of [date] in [timezone],
  /// ordered by [Meal.loggedAt] ascending.
  Future<List<Meal>> getMealsForDay(String uid, DateTime date, String timezone);

  /// Returns up to [limit] most recently logged meals for [uid].
  Future<List<Meal>> getRecentMeals(
    String uid, {
    required int limit,
    required String timezone,
  });

  /// Returns date keys (`yyyy-MM-dd`) with at least one logged meal in the
  /// inclusive [startDateKey, endDateKey] range.
  Future<Set<String>> getMealDateKeysInRange(
    String uid, {
    required String startDateKey,
    required String endDateKey,
  });

  // ── Daily summaries ───────────────────────────────────────────────────────

  /// Returns the [DailySummary] for [uid] on [dateKey] (`yyyy-MM-dd`),
  /// or null if no summary exists for that day.
  Future<DailySummary?> getDailySummary(String uid, String dateKey);

  /// Partially updates the [DailySummary] for [uid]/[dateKey].
  ///
  /// If no summary exists, creates one with zero [NutritionEntry] totals,
  /// `mealCount` 0, and the provided field(s). Only the non-null named
  /// parameters are written.
  Future<void> updateDailySummary(
    String uid,
    String dateKey, {
    double? hydrationLiters,
    double? sleepHours,
  });

  Future<void> signOut();
}
