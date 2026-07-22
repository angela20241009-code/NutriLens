import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrilens/app/app_locale_scope.dart';
import 'package:nutrilens/l10n/app_localizations.dart';
import 'package:nutrilens/models/app_language.dart';
import 'package:nutrilens/theme/app_theme.dart';

Widget wrapLocaleScope({required Widget child}) {
  return AppLocaleScope(child: child);
}

Widget wrapLocalized({required Widget child}) {
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

            return MaterialApp(
              theme: AppTheme.dark,
              locale: locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: child,
            );
          },
        );
      },
    ),
  );
}

Future<void> pumpLocalized(
  WidgetTester tester,
  Widget child,
) async {
  await tester.pumpWidget(wrapLocalized(child: child));
  await tester.pump();
  await tester.pumpAndSettle();
}
