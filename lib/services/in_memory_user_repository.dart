import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/services/firestore_serializer.dart';
import 'package:nutrilens/services/user_repository.dart';

/// Local in-memory implementation for tests and UI before Firebase init.
class InMemoryUserRepository implements UserRepository {
  InMemoryUserRepository({String? seedUid}) : _uid = seedUid;

  String? _uid;
  final Map<String, UserAccount> _accounts = {};
  final Map<String, UserProfile> _profiles = {};
  final Map<String, SportProfile> _sportProfiles = {};
  final Map<String, TeamProgram> _teamPrograms = {};

  @override
  String? get currentUid => _uid;

  @override
  Stream<String?> watchAuthUid() async* {
    yield _uid;
  }

  void seedCatalog({
    SportProfile? sportProfile,
    TeamProgram? teamProgram,
  }) {
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
    final uid = 'local_${now.millisecondsSinceEpoch}';
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
    final account = _accounts[uid];
    if (account == null) {
      throw StateError('No account for uid $uid');
    }
    final now = firestoreNow();
    final linked = account.copyWith(
      email: email,
      emailVerified: false,
      authProviders: [...account.authProviders.where((p) => p != 'anonymous'), 'password'],
      linkedAt: now,
      updatedAt: now,
    );
    _accounts[uid] = linked;
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
}
