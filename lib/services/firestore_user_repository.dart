import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/services/date_key.dart';
import 'package:nutrilens/services/firestore_paths.dart';
import 'package:nutrilens/services/firestore_serializer.dart';
import 'package:nutrilens/services/user_repository.dart';
import 'package:timezone/timezone.dart' as tz;

class FirestoreUserRepository implements UserRepository {
  FirestoreUserRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  String? get currentUid => _auth.currentUser?.uid;

  @override
  Stream<String?> watchAuthUid() {
    return _auth.authStateChanges().map((user) => user?.uid);
  }

  CollectionReference<Map<String, dynamic>> _col(String name) =>
      _firestore.collection(name);

  @override
  Future<UserAccount?> getAccount(String uid) async {
    final snap = await _col(FirestorePaths.users).doc(uid).get();
    if (!snap.exists || snap.data() == null) return null;
    return UserAccount.fromMap(fromFirestoreMap(snap.data()!), uid: uid);
  }

  @override
  Future<UserProfile?> getProfile(String uid) async {
    final snap = await _col(FirestorePaths.userProfiles).doc(uid).get();
    if (!snap.exists || snap.data() == null) return null;
    return UserProfile.fromMap(fromFirestoreMap(snap.data()!), userId: uid);
  }

  @override
  Future<SportProfile?> getSportProfile(String sportId) async {
    final snap = await _col(FirestorePaths.sportProfiles).doc(sportId).get();
    if (!snap.exists || snap.data() == null) return null;
    return SportProfile.fromMap(
      fromFirestoreMap(snap.data()!),
      sportId: sportId,
    );
  }

  @override
  Future<TeamProgram?> getTeamProgram(String programId) async {
    final snap = await _col(FirestorePaths.teamPrograms).doc(programId).get();
    if (!snap.exists || snap.data() == null) return null;
    return TeamProgram.fromMap(
      fromFirestoreMap(snap.data()!),
      programId: programId,
    );
  }

  @override
  Future<UserAccount> signInAnonymously({required String timezone}) async {
    final credential = await _auth.signInAnonymously();
    return _ensureFirebaseUserAccount(
      user: credential.user!,
      timezone: timezone,
      anonymous: true,
    );
  }

  @override
  Future<UserAccount> createAccountWithEmail({
    required String email,
    required String password,
    required String timezone,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _ensureFirebaseUserAccount(
      user: credential.user!,
      timezone: timezone,
      anonymous: false,
    );
  }

  @override
  Future<UserAccount> signInWithEmail({
    required String email,
    required String password,
    required String timezone,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _ensureFirebaseUserAccount(
      user: credential.user!,
      timezone: timezone,
      anonymous: false,
    );
  }

  @override
  Future<UserAccount> ensureCurrentUserAccount({
    required String timezone,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No signed-in Firebase user');
    }
    return _ensureFirebaseUserAccount(
      user: user,
      timezone: timezone,
      anonymous: user.isAnonymous,
    );
  }

  Future<UserAccount> _ensureFirebaseUserAccount({
    required User user,
    required String timezone,
    required bool anonymous,
  }) async {
    final uid = user.uid;
    final now = firestoreNow();
    final existingAccount = await getAccount(uid);
    final existingProfile = await getProfile(uid);

    final account =
        existingAccount ??
        UserAccount(
          uid: uid,
          authProviders: anonymous ? const ['anonymous'] : const ['password'],
          email: user.email,
          emailVerified: user.emailVerified,
          displayName: user.displayName,
          accountStatus: AccountStatus.active,
          onboardingCompleted: false,
          createdAt: now,
          updatedAt: now,
        );

    final providers = <String>{
      ...account.authProviders,
      if (anonymous) 'anonymous' else 'password',
    };
    if (!anonymous) {
      providers.remove('anonymous');
    }

    final updatedAccount = account.copyWith(
      authProviders: providers.toList(),
      email: user.email,
      emailVerified: user.emailVerified,
      displayName: user.displayName,
      lastSeenAt: now,
      updatedAt: now,
    );

    final profile =
        existingProfile ??
        UserProfile.emptyShell(userId: uid, now: now, timezone: timezone);

    await _col(FirestorePaths.users)
        .doc(uid)
        .set(toFirestoreMap(updatedAccount.toMap()), SetOptions(merge: true));
    await _col(
      FirestorePaths.userProfiles,
    ).doc(uid).set(toFirestoreMap(profile.toMap()), SetOptions(merge: true));

    return updatedAccount;
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

    final batch = _firestore.batch();
    final profileRef = _col(FirestorePaths.userProfiles).doc(uid);
    final userRef = _col(FirestorePaths.users).doc(uid);

    batch.set(
      profileRef,
      toFirestoreMap(completed.toMap()),
      SetOptions(merge: true),
    );
    batch.set(
      userRef,
      toFirestoreMap({
        'onboardingCompleted': true,
        'updatedAt': now.toUtc().toIso8601String(),
      }),
      SetOptions(merge: true),
    );
    await batch.commit();
    return completed;
  }

  @override
  Future<UserAccount> linkEmail({
    required String uid,
    required String email,
    required String password,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.uid != uid) {
      throw StateError('No signed-in user matching uid $uid');
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await user.linkWithCredential(credential);

    final now = firestoreNow();
    final existing = await getAccount(uid);
    final providers = <String>{...?existing?.authProviders, 'password'}
      ..remove('anonymous');

    final updated = (existing ?? UserAccount.anonymousShell(uid: uid, now: now))
        .copyWith(
          email: email,
          emailVerified: user.emailVerified,
          authProviders: providers.toList(),
          linkedAt: now,
          updatedAt: now,
        );

    await saveAccount(updated);
    return updated;
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    final data = profile.copyWith(updatedAt: firestoreNow()).toMap();
    await _col(
      FirestorePaths.userProfiles,
    ).doc(profile.userId).set(toFirestoreMap(data), SetOptions(merge: true));
  }

  @override
  Future<void> saveAccount(UserAccount account) async {
    final data = account.copyWith(updatedAt: firestoreNow()).toMap();
    await _col(
      FirestorePaths.users,
    ).doc(account.uid).set(toFirestoreMap(data), SetOptions(merge: true));
  }

  // ── Meal logging ──────────────────────────────────────────────────────────

  @override
  Future<Meal> logMeal(String uid, Meal meal, String timezone) async {
    final dateKey = dateKeyFor(meal.loggedAt, timezone);

    // Create the auto-ID doc ref BEFORE entering the transaction so the ID
    // is known when we construct the saved Meal to return.
    final mealRef = _firestore.collection(FirestorePaths.meals(uid)).doc();
    final mealId = mealRef.id;
    final savedMeal = meal.copyWith(mealId: mealId);

    final summaryRef = _firestore.doc(
      FirestorePaths.dailySummaryDoc(uid, dateKey),
    );

    await _firestore.runTransaction((tx) async {
      // All reads must come before any write in a Firestore transaction.
      final summarySnap = await tx.get(summaryRef);

      // Compute updated summary.
      final now = firestoreNow();
      final Map<String, dynamic> summaryData;
      if (summarySnap.exists && summarySnap.data() != null) {
        final existing = DailySummary.fromMap(
          fromFirestoreMap(summarySnap.data()!),
        );
        final updated = existing.copyWith(
          totals: existing.totals + meal.nutrition,
          mealCount: existing.mealCount + 1,
          updatedAt: now,
        );
        summaryData = toFirestoreMap(updated.toMap());
      } else {
        final created = DailySummary(
          uid: uid,
          dateKey: dateKey,
          totals: meal.nutrition,
          mealCount: 1,
          updatedAt: now,
        );
        summaryData = toFirestoreMap(created.toMap());
      }

      // Writes.
      tx.set(mealRef, toFirestoreMap(savedMeal.toMap()));
      tx.set(summaryRef, summaryData);
    });

    return savedMeal;
  }

  @override
  Future<List<Meal>> getMealsForDay(
    String uid,
    DateTime date,
    String timezone,
  ) async {
    // Compute the UTC bounds for the start and end of the calendar day in
    // the given timezone (handles DST correctly).
    DateTime startUtc;
    DateTime endUtc;
    try {
      final location = tz.getLocation(timezone);
      final dayStart = tz.TZDateTime(
        location,
        date.year,
        date.month,
        date.day,
      );
      final dayEnd = tz.TZDateTime(
        location,
        date.year,
        date.month,
        date.day + 1,
      );
      startUtc = dayStart.toUtc();
      endUtc = dayEnd.toUtc();
    } catch (_) {
      // Unknown timezone — fall back to UTC.
      final d = date.toUtc();
      startUtc = DateTime.utc(d.year, d.month, d.day);
      endUtc = startUtc.add(const Duration(days: 1));
    }

    final snap = await _firestore
        .collection(FirestorePaths.meals(uid))
        .where(
          'loggedAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startUtc),
          isLessThan: Timestamp.fromDate(endUtc),
        )
        .orderBy('loggedAt')
        .get();

    return snap.docs.map((doc) {
      return Meal.fromMap(fromFirestoreMap(doc.data()), mealId: doc.id);
    }).toList();
  }

  @override
  Future<List<Meal>> getRecentMeals(
    String uid, {
    required int limit,
    required String timezone,
  }) async {
    final snap = await _firestore
        .collection(FirestorePaths.meals(uid))
        .orderBy('loggedAt', descending: true)
        .limit(limit)
        .get();

    return snap.docs
        .map((doc) => Meal.fromMap(fromFirestoreMap(doc.data()), mealId: doc.id))
        .toList();
  }

  @override
  Future<Set<String>> getMealDateKeysInRange(
    String uid, {
    required String startDateKey,
    required String endDateKey,
  }) async {
    final snap = await _firestore
        .collection(FirestorePaths.dailySummaries(uid))
        .where('dateKey', isGreaterThanOrEqualTo: startDateKey)
        .where('dateKey', isLessThanOrEqualTo: endDateKey)
        .get();

    return snap.docs
        .where((doc) {
          final data = doc.data();
          final mealCount = data['mealCount'];
          if (mealCount is int) {
            return mealCount > 0;
          }
          if (mealCount is num) {
            return mealCount > 0;
          }
          return false;
        })
        .map((doc) => doc.data()['dateKey'] as String? ?? doc.id)
        .toSet();
  }

  // ── Daily summaries ───────────────────────────────────────────────────────

  @override
  Future<DailySummary?> getDailySummary(String uid, String dateKey) async {
    final snap = await _firestore
        .doc(FirestorePaths.dailySummaryDoc(uid, dateKey))
        .get();
    if (!snap.exists || snap.data() == null) return null;
    return DailySummary.fromMap(fromFirestoreMap(snap.data()!));
  }

  @override
  Future<void> updateDailySummary(
    String uid,
    String dateKey, {
    double? hydrationLiters,
    double? sleepHours,
  }) async {
    final ref = _firestore.doc(FirestorePaths.dailySummaryDoc(uid, dateKey));
    final snap = await ref.get();
    final now = firestoreNow();

    if (!snap.exists || snap.data() == null) {
      // Create a well-formed summary with zero totals.
      final created = DailySummary(
        uid: uid,
        dateKey: dateKey,
        totals: const NutritionEntry(),
        mealCount: 0,
        hydrationLiters: hydrationLiters ?? 0,
        sleepHours: sleepHours ?? 0,
        updatedAt: now,
      );
      await ref.set(toFirestoreMap(created.toMap()));
    } else {
      // Partial update — only touch the provided fields + updatedAt.
      final updates = <String, dynamic>{'updatedAt': Timestamp.fromDate(now)};
      if (hydrationLiters != null) updates['hydrationLiters'] = hydrationLiters;
      if (sleepHours != null) updates['sleepHours'] = sleepHours;
      await ref.set(updates, SetOptions(merge: true));
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
