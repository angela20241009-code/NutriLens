/// Firestore collection and document path helpers.
abstract final class FirestorePaths {
  static const users = 'users';
  static const userProfiles = 'userProfiles';
  static const sportProfiles = 'sportProfiles';
  static const teamPrograms = 'teamPrograms';

  static String userDoc(String uid) => '$users/$uid';
  static String userProfileDoc(String uid) => '$userProfiles/$uid';
  static String sportProfileDoc(String sportId) => '$sportProfiles/$sportId';
  static String teamProgramDoc(String programId) => '$teamPrograms/$programId';

  // ── Meal logging ──────────────────────────────────────────────────────────

  /// Collection of meal entries for a user: `meals/{uid}/entries`
  static String meals(String uid) => 'meals/$uid/entries';

  /// A specific meal document: `meals/{uid}/entries/{mealId}`
  static String mealDoc(String uid, String mealId) =>
      'meals/$uid/entries/$mealId';

  // ── Daily summaries ───────────────────────────────────────────────────────

  /// Collection of daily summaries for a user: `dailySummaries/{uid}/days`
  static String dailySummaries(String uid) => 'dailySummaries/$uid/days';

  /// A specific daily summary document: `dailySummaries/{uid}/days/{dateKey}`
  static String dailySummaryDoc(String uid, String dateKey) =>
      'dailySummaries/$uid/days/$dateKey';

  // ── Meal plans ────────────────────────────────────────────────────────────

  /// Current cached weekly meal plan: `mealPlans/{uid}`
  static String mealPlanDoc(String uid) => 'mealPlans/$uid';
}
