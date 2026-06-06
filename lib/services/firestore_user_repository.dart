import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/services/date_key.dart';
import 'package:nutrilens/services/firestore_paths.dart';
import 'package:nutrilens/services/firestore_serializer.dart';
import 'package:nutrilens/services/user_repository.dart';
import 'package:timezone/timezone.dart' as tz;

class FirestoreUserRepository implements UserRepository {
  FirestoreUserRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
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
    return UserAccount.fromMap(
      fromFirestoreMap(snap.data()!),
      uid: uid,
    );
  }

  @override
  Future<UserProfile?> getProfile(String uid) async {
    final snap = await _col(FirestorePaths.userProfiles).doc(uid).get();
    if (!snap.exists || snap.data() == null) return null;
    return UserProfile.fromMap(
      fromFirestoreMap(snap.data()!),
      userId: uid,
    );
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
    final uid = credential.user!.uid;
    final now = firestoreNow();

    final account = UserAccount.anonymousShell(uid: uid, now: now);
    final profile = UserProfile.emptyShell(
      userId: uid,
      now: now,
      timezone: timezone,
    );

    await _col(FirestorePaths.users)
        .doc(uid)
        .set(toFirestoreMap(account.toMap()), SetOptions(merge: true));
    await _col(FirestorePaths.userProfiles)
        .doc(uid)
        .set(toFirestoreMap(profile.toMap()), SetOptions(merge: true));

    return account;
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
    final providers = <String>{
      ...?existing?.authProviders,
      'password',
    }..remove('anonymous');

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
    await _col(FirestorePaths.userProfiles)
        .doc(profile.userId)
        .set(toFirestoreMap(data), SetOptions(merge: true));
  }

  @override
  Future<void> saveAccount(UserAccount account) async {
    final data = account.copyWith(updatedAt: firestoreNow()).toMap();
    await _col(FirestorePaths.users)
        .doc(account.uid)
        .set(toFirestoreMap(data), SetOptions(merge: true));
  }

  // ── Meal logging ──────────────────────────────────────────────────────────

  @override
  Future<Meal> logMeal(String uid, Meal meal, String timezone) async {
    final dateKey = dateKeyFor(meal.loggedAt, timezone);

    // Create the auto-ID doc ref BEFORE entering the transaction so the ID
    // is known when we construct the saved Meal to return.
    final mealRef = _firestore
        .collection(FirestorePaths.meals(uid))
        .doc();
    final mealId = mealRef.id;
    final savedMeal = meal.copyWith(mealId: mealId);

    final summaryRef = _firestore
        .doc(FirestorePaths.dailySummaryDoc(uid, dateKey));

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
      final tzDate = tz.TZDateTime.from(date.toUtc(), location);
      final dayStart = tz.TZDateTime(
        location,
        tzDate.year,
        tzDate.month,
        tzDate.day,
      );
      // Use the TZDateTime constructor to compute "next local midnight" so that
      // DST transitions (23-hour and 25-hour days) are handled correctly.
      // Day overflow (e.g. day 32) normalises exactly as DateTime does.
      final dayEnd = tz.TZDateTime(
        location,
        tzDate.year,
        tzDate.month,
        tzDate.day + 1,
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
      final updates = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(now),
      };
      if (hydrationLiters != null) updates['hydrationLiters'] = hydrationLiters;
      if (sleepHours != null) updates['sleepHours'] = sleepHours;
      await ref.set(updates, SetOptions(merge: true));
    }
  }
}
