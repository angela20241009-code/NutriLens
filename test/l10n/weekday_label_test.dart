import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrilens/l10n/app_localizations.dart';
import 'package:nutrilens/l10n/l10n_extensions.dart';

void main() {
  testWidgets('formatLocalizedWeekdayShort matches Dart weekday values', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            expect(
              formatLocalizedWeekdayShort(context, DateTime.saturday),
              'Sat',
            );
            expect(
              formatLocalizedWeekdayShort(context, DateTime.sunday),
              'Sun',
            );
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  });
}
