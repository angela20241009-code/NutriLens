import 'package:flutter/material.dart';
import 'package:nutrilens/l10n/app_localizations.dart';
import 'package:nutrilens/models/app_language.dart';
import 'package:nutrilens/services/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _localePreferenceKey = 'app_locale';

class AppLocaleController extends ChangeNotifier {
  AppLanguage _language = AppLanguage.english;
  bool _ready = false;

  AppLanguage get language => _language;
  Locale get locale => _language.locale;
  bool get ready => _ready;

  AppLocaleController() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _language = AppLanguage.fromCode(prefs.getString(_localePreferenceKey));
    _ready = true;
    notifyListeners();
  }

  void applyFromProfile(String? profileLocale) {
    final resolved = AppLanguage.fromProfileLocale(profileLocale);
    if (_language == resolved) {
      return;
    }
    _language = resolved;
    notifyListeners();
    _persist(resolved);
  }

  Future<void> setLanguage(
    AppLanguage language, {
    UserRepository? repository,
    String? uid,
  }) async {
    if (_language == language) {
      return;
    }

    _language = language;
    notifyListeners();
    await _persist(language);

    if (repository != null && uid != null) {
      final profile = await repository.getProfile(uid);
      if (profile != null) {
        await repository.saveProfile(
          profile.copyWith(locale: language.profileLocale),
        );
      }
    }
  }

  Future<void> _persist(AppLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localePreferenceKey, language.code);
  }
}

class AppLocaleScope extends StatefulWidget {
  const AppLocaleScope({super.key, required this.child});

  final Widget child;

  static AppLocaleController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<_AppLocaleInherited>();
    if (scope == null) {
      throw FlutterError(
        'AppLocaleScope.of() called with no AppLocaleScope in context.',
      );
    }
    return scope.notifier!;
  }

  static AppLocaleController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_AppLocaleInherited>()
        ?.notifier;
  }

  @override
  State<AppLocaleScope> createState() => _AppLocaleScopeState();
}

class _AppLocaleScopeState extends State<AppLocaleScope> {
  late final AppLocaleController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AppLocaleController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return _AppLocaleInherited(
          controller: _controller,
          child: widget.child,
        );
      },
    );
  }
}

class _AppLocaleInherited extends InheritedNotifier<AppLocaleController> {
  const _AppLocaleInherited({
    required AppLocaleController controller,
    required super.child,
  }) : super(notifier: controller);
}

class LocalizedMaterialApp extends StatelessWidget {
  const LocalizedMaterialApp({
    super.key,
    required this.locale,
    required this.theme,
    this.themeMode = ThemeMode.dark,
    this.title = 'NutriLens',
    this.debugShowCheckedModeBanner = false,
    this.builder,
    required this.home,
  });

  final Locale locale;
  final ThemeData theme;
  final ThemeMode themeMode;
  final String title;
  final bool debugShowCheckedModeBanner;
  final TransitionBuilder? builder;
  final Widget home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: theme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: debugShowCheckedModeBanner,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: builder,
      home: home,
    );
  }
}
