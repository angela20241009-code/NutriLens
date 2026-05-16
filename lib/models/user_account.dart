import 'package:nutrilens/models/firestore_map.dart';

enum AccountStatus {
  active('active'),
  disabled('disabled'),
  deleted('deleted');

  const AccountStatus(this.firestoreValue);
  final String firestoreValue;

  static AccountStatus fromFirestore(String? value) {
    return AccountStatus.values.firstWhere(
      (e) => e.firestoreValue == value,
      orElse: () => AccountStatus.active,
    );
  }
}

class UserAccount {
  const UserAccount({
    required this.uid,
    required this.authProviders,
    this.email,
    required this.emailVerified,
    this.displayName,
    required this.accountStatus,
    required this.onboardingCompleted,
    required this.createdAt,
    required this.updatedAt,
    this.lastSeenAt,
    this.linkedAt,
  });

  final String uid;
  final List<String> authProviders;
  final String? email;
  final bool emailVerified;
  final String? displayName;
  final AccountStatus accountStatus;
  final bool onboardingCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSeenAt;
  final DateTime? linkedAt;

  bool get isAnonymous => authProviders.contains('anonymous');

  factory UserAccount.fromMap(Map<String, dynamic> map, {required String uid}) {
    return UserAccount(
      uid: map['uid'] as String? ?? uid,
      authProviders: parseStringList(map['authProviders']),
      email: map['email'] as String?,
      emailVerified: parseBool(map['emailVerified']),
      displayName: map['displayName'] as String?,
      accountStatus: AccountStatus.fromFirestore(map['accountStatus'] as String?),
      onboardingCompleted: parseBool(map['onboardingCompleted']),
      createdAt: parseRequiredDateTime(map['createdAt']),
      updatedAt: parseRequiredDateTime(map['updatedAt']),
      lastSeenAt: parseDateTime(map['lastSeenAt']),
      linkedAt: parseDateTime(map['linkedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'authProviders': authProviders,
    'email': email,
    'emailVerified': emailVerified,
    'displayName': displayName,
    'accountStatus': accountStatus.firestoreValue,
    'onboardingCompleted': onboardingCompleted,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'lastSeenAt': iso8601OrNull(lastSeenAt),
    'linkedAt': iso8601OrNull(linkedAt),
  };

  factory UserAccount.anonymousShell({
    required String uid,
    required DateTime now,
  }) {
    return UserAccount(
      uid: uid,
      authProviders: const ['anonymous'],
      email: null,
      emailVerified: false,
      displayName: null,
      accountStatus: AccountStatus.active,
      onboardingCompleted: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  UserAccount copyWith({
    List<String>? authProviders,
    String? email,
    bool? emailVerified,
    String? displayName,
    AccountStatus? accountStatus,
    bool? onboardingCompleted,
    DateTime? updatedAt,
    DateTime? lastSeenAt,
    DateTime? linkedAt,
  }) {
    return UserAccount(
      uid: uid,
      authProviders: authProviders ?? this.authProviders,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
      displayName: displayName ?? this.displayName,
      accountStatus: accountStatus ?? this.accountStatus,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      linkedAt: linkedAt ?? this.linkedAt,
    );
  }
}
