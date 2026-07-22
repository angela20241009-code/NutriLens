import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nutrilens/app.dart';
import 'package:nutrilens/app/app_locale_scope.dart';
import 'package:nutrilens/app/app_settings_scope.dart';
import 'package:nutrilens/app/meal_analysis_scope.dart';
import 'package:nutrilens/app/meal_log_refresh_scope.dart';
import 'package:nutrilens/app/sleep_log_refresh_scope.dart';
import 'package:nutrilens/app/meal_plan_refresh_scope.dart';
import 'package:nutrilens/app/meal_plan_scope.dart';
import 'package:nutrilens/app/session_scope.dart';
import 'package:nutrilens/app/tasty_recipe_scope.dart';
import 'package:nutrilens/app/user_scope.dart';
import 'package:nutrilens/data/catalog_seed_data.dart';
import 'package:nutrilens/features/auth/auth_screen.dart';
import 'package:nutrilens/l10n/app_localizations.dart';
import 'package:nutrilens/models/app_language.dart';
import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/services/in_memory_user_repository.dart';
import 'package:nutrilens/services/meal_analysis_client.dart';
import 'package:nutrilens/services/openai_meal_analysis_client.dart';
import 'package:nutrilens/services/openai_meal_plan_client.dart';
import 'package:nutrilens/services/persisted_meal_plan_client.dart';
import 'package:nutrilens/services/tasty_recipe_client.dart';
import 'package:nutrilens/services/user_repository.dart';
import 'package:nutrilens/theme/app_theme.dart';

import '../services/firestore_user_repository.dart';

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late Future<_BootstrapResult> _bootstrapFuture;
  late final MealAnalysisClient _mealAnalysisClient;
  late final TastyRecipeClient _tastyRecipeClient;
  late final MealPlanRefreshNotifier _mealPlanRefreshNotifier;
  late final MealLogRefreshNotifier _mealLogRefreshNotifier;
  late final SleepLogRefreshNotifier _sleepLogRefreshNotifier;
  bool _firebaseReady = false;

  @override
  void initState() {
    super.initState();
    _mealAnalysisClient = OpenAiMealAnalysisClient.fromEnvironment();
    _tastyRecipeClient = RapidApiTastyRecipeClient.fromEnvironment();
    _mealPlanRefreshNotifier = MealPlanRefreshNotifier();
    _mealLogRefreshNotifier = MealLogRefreshNotifier();
    _sleepLogRefreshNotifier = SleepLogRefreshNotifier();
    _bootstrapFuture = _initializeApp();
  }

  Future<_BootstrapResult> _initializeApp() async {
    try {
      if (!_firebaseReady) {
        await Firebase.initializeApp();
        _firebaseReady = true;
      }
      return _restoreFirebaseSession();
    } catch (error) {
      debugPrint('Firebase unavailable, using local demo data: $error');
      return _initializeLocalDemo();
    }
  }

  Future<_BootstrapResult> _restoreFirebaseSession() async {
    final repository = FirestoreUserRepository();
    if (repository.currentUid == null) {
      return _BootstrapResult(repository: repository);
    }
    final account = await repository.ensureCurrentUserAccount(
      timezone: _defaultTimezone,
    );
    return _BootstrapResult(repository: repository, uid: account.uid);
  }

  Future<_BootstrapResult> _initializeLocalDemo() async {
    final repository = InMemoryUserRepository();
    repository.seedCatalog(
      sportProfile: CatalogSeedData.tennisSport(),
      teamProgram: CatalogSeedData.lincolnHighTennis(),
    );
    return _BootstrapResult(repository: repository);
  }

  void _activateSession(UserRepository repository, UserAccount account) {
    if (!mounted) {
      return;
    }
    setState(() {
      _bootstrapFuture = Future.value(
        _BootstrapResult(repository: repository, uid: account.uid),
      );
    });
  }

  Future<void> _saveInitialDietaryProfile(
    UserRepository repository,
    String uid,
    DietaryProfile dietaryProfile, {
    String? locale,
    int mealsPerDay = 3,
  }) async {
    final profile = await repository.getProfile(uid);
    if (profile == null) {
      return;
    }
    await repository.saveProfile(
      profile.copyWith(
        dietaryProfile: dietaryProfile,
        locale: locale ?? profile.locale,
        nutritionSettings: profile.nutritionSettings.copyWith(
          mealsPerDay: mealsPerDay,
        ),
      ),
    );
  }

  String _currentProfileLocale() {
    if (!mounted) {
      return AppLanguage.english.profileLocale;
    }
    return AppLocaleScope.of(context).language.profileLocale;
  }

  Future<void> _createAccount(
    UserRepository repository,
    String email,
    String password,
    DietaryProfile dietaryProfile,
    int mealsPerDay,
  ) async {
    final account = await repository.createAccountWithEmail(
      email: email,
      password: password,
      timezone: _defaultTimezone,
    );
    await _saveInitialDietaryProfile(
      repository,
      account.uid,
      dietaryProfile,
      locale: _currentProfileLocale(),
      mealsPerDay: mealsPerDay,
    );
    _activateSession(repository, account);
  }

  Future<void> _signIn(
    UserRepository repository,
    String email,
    String password,
  ) async {
    final account = await repository.signInWithEmail(
      email: email,
      password: password,
      timezone: _defaultTimezone,
    );
    _activateSession(repository, account);
  }

  Future<void> _continueAsGuest(
    UserRepository repository,
    DietaryProfile dietaryProfile,
    int mealsPerDay,
  ) async {
    final account = await repository.signInAnonymously(
      timezone: _defaultTimezone,
    );
    await _saveInitialDietaryProfile(
      repository,
      account.uid,
      dietaryProfile,
      locale: _currentProfileLocale(),
      mealsPerDay: mealsPerDay,
    );
    _activateSession(repository, account);
  }

  Future<void> _signOutAndRestart(UserRepository repository) async {
    await repository.signOut();
    if (!mounted) {
      return;
    }
    setState(() {
      _bootstrapFuture = Future.value(_BootstrapResult(repository: repository));
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppLocaleScope(
      child: Builder(
        builder: (context) {
          final localeScope = AppLocaleScope.of(context);
          return ListenableBuilder(
            listenable: localeScope,
            builder: (context, _) {
              final locale = localeScope.ready
                  ? localeScope.locale
                  : AppLanguage.english.locale;

              return FutureBuilder<_BootstrapResult>(
                future: _bootstrapFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return MaterialApp(
                      locale: locale,
                      localizationsDelegates:
                          AppLocalizations.localizationsDelegates,
                      supportedLocales: AppLocalizations.supportedLocales,
                      home: const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return MaterialApp(
                      locale: locale,
                      localizationsDelegates:
                          AppLocalizations.localizationsDelegates,
                      supportedLocales: AppLocalizations.supportedLocales,
                      home: Scaffold(
                        body: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              AppLocalizations.of(context)!
                                  .failedToInitializeApp('${snapshot.error}'),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  final result = snapshot.requireData;
                  if (result.uid == null) {
                    return MaterialApp(
                      title: 'NutriLens',
                      theme: AppTheme.dark,
                      themeMode: ThemeMode.dark,
                      debugShowCheckedModeBanner: false,
                      locale: locale,
                      localizationsDelegates:
                          AppLocalizations.localizationsDelegates,
                      supportedLocales: AppLocalizations.supportedLocales,
                      home: AuthScreen(
                        onCreateAccount:
                            (email, password, dietaryProfile, mealsPerDay) =>
                                _createAccount(
                                  result.repository,
                                  email,
                                  password,
                                  dietaryProfile,
                                  mealsPerDay,
                                ),
                        onSignIn: (email, password) =>
                            _signIn(result.repository, email, password),
                        onContinueAsGuest: (dietaryProfile, mealsPerDay) =>
                            _continueAsGuest(
                          result.repository,
                          dietaryProfile,
                          mealsPerDay,
                        ),
                      ),
                    );
                  }

                  return TastyRecipeScope(
                    client: _tastyRecipeClient,
                    child: SleepLogRefreshScope(
                      notifier: _sleepLogRefreshNotifier,
                      child: MealLogRefreshScope(
                        notifier: _mealLogRefreshNotifier,
                        child: MealPlanRefreshScope(
                          notifier: _mealPlanRefreshNotifier,
                          child: MealAnalysisScope(
                            client: _mealAnalysisClient,
                            child: MealPlanScope(
                              client: PersistedMealPlanClient(
                                delegate: OpenAiMealPlanClient.fromEnvironment(),
                                repository: result.repository,
                              ),
                              child: SessionScope(
                                signOut: () => _signOutAndRestart(result.repository),
                                child: UserScope(
                                  repository: result.repository,
                                  uid: result.uid!,
                                  child: AppSettingsScope(
                                    repository: result.repository,
                                    uid: result.uid!,
                                    child: const NutriLensApp(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

const _defaultTimezone = 'America/Los_Angeles';

class _BootstrapResult {
  _BootstrapResult({required this.repository, this.uid});

  final UserRepository repository;
  final String? uid;
}
