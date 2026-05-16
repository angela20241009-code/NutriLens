import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/services/firestore_paths.dart';
import 'package:nutrilens/services/firestore_serializer.dart';
import 'package:nutrilens/services/user_repository.dart';

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
}
