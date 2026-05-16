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
}
