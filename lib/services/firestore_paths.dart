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
}
