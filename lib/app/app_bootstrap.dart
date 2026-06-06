import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nutrilens/firebase_options.dart';
import 'package:nutrilens/app.dart';
import 'package:nutrilens/app/user_scope.dart';
import 'package:nutrilens/data/catalog_seed_data.dart';
import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/services/firestore_user_repository.dart';
import 'package:nutrilens/services/in_memory_user_repository.dart';
import 'package:nutrilens/services/user_repository.dart';

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late final Future<_BootstrapResult> _bootstrapFuture;

  @override
  void initState() {
    super.initState();
    _bootstrapFuture = _initializeApp();
  }

  Future<_BootstrapResult> _initializeApp() async {
    const timezone = 'America/Los_Angeles';

    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      final repository = FirestoreUserRepository();
      final account = await repository.signInAnonymously(timezone: timezone);
      return _BootstrapResult(repository: repository, uid: account.uid);
    } catch (error) {
      debugPrint('Firebase unavailable, using local demo data: $error');
      return _initializeLocalDemo(timezone: timezone);
    }
  }

  Future<_BootstrapResult> _initializeLocalDemo({required String timezone}) async {
    final repository = InMemoryUserRepository();
    repository.seedCatalog(
      sportProfile: CatalogSeedData.tennisSport(),
      teamProgram: CatalogSeedData.lincolnHighTennis(),
    );
    final account = await repository.signInAnonymously(timezone: timezone);
    await repository.completeOnboarding(
      uid: account.uid,
      profile: UserProfile.demoAngela(
        userId: account.uid,
        now: DateTime.now().toUtc(),
      ),
    );
    return _BootstrapResult(repository: repository, uid: account.uid);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_BootstrapResult>(
      future: _bootstrapFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Failed to initialize the app:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }

        final result = snapshot.requireData;
        return UserScope(
          repository: result.repository,
          uid: result.uid,
          child: const NutriLensApp(),
        );
      },
    );
  }
}

class _BootstrapResult {
  _BootstrapResult({
    required this.repository,
    required this.uid,
  });

  final UserRepository repository;
  final String uid;
}
