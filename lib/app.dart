import 'package:flutter/material.dart';
import 'package:nutrilens/app/app_settings_scope.dart';
import 'package:nutrilens/app/app_locale_scope.dart';
import 'package:nutrilens/app/user_scope.dart';
import 'package:nutrilens/features/onboarding/onboarding_flow.dart';
import 'package:nutrilens/features/shell/app_shell.dart';
import 'package:nutrilens/l10n/app_localizations.dart';
import 'package:nutrilens/models/app_language.dart';
import 'package:nutrilens/models/user_account.dart';
import 'package:nutrilens/theme/app_theme.dart';
import 'package:nutrilens/theme/theme_palette_scope.dart';

class NutriLensApp extends StatelessWidget {
  const NutriLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsScope.of(context);
    final localeScope = AppLocaleScope.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge([settings, localeScope]),
      builder: (context, _) {
        final palette = settings.themePalette;
        final textScale = settings.textScale.scaleFactor;
        final accessibility = settings.accessibilityModeEnabled;
        final locale = localeScope.ready
            ? localeScope.locale
            : AppLanguage.english.locale;

        return MaterialApp(
          title: 'NutriLens',
          theme: AppTheme.build(palette: palette),
          themeMode: ThemeMode.dark,
          debugShowCheckedModeBanner: false,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            return ThemePaletteScope(
              palette: palette,
              child: MediaQuery(
                data: mediaQuery.copyWith(
                  textScaler: TextScaler.linear(textScale),
                  boldText: accessibility || mediaQuery.boldText,
                ),
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
          home: const _AppEntryGate(),
        );
      },
    );
  }
}

class _AppEntryGate extends StatefulWidget {
  const _AppEntryGate();

  @override
  State<_AppEntryGate> createState() => _AppEntryGateState();
}

class _AppEntryGateState extends State<_AppEntryGate> {
  Future<UserAccount?>? _accountFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _accountFuture ??= () {
      final scope = UserScope.of(context);
      return scope.repository.getAccount(scope.uid);
    }();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<UserAccount?>(
      future: _accountFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.failedToLoadAccount('${snapshot.error}'),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final account = snapshot.data;
        if (account?.onboardingCompleted == true) {
          return const AppShell();
        }

        return const OnboardingFlow();
      },
    );
  }
}
