import 'package:flutter/material.dart';
import 'package:nutrilens/l10n/app_localizations.dart';

enum AppLanguage {
  english('en', 'en-US'),
  spanish('es', 'es'),
  chinese('zh', 'zh');

  const AppLanguage(this.code, this.profileLocale);

  final String code;
  final String profileLocale;

  Locale get locale => Locale(code);

  static const supported = [english, spanish, chinese];

  static AppLanguage fromCode(String? code) {
    return supported.firstWhere(
      (language) => language.code == code,
      orElse: () => english,
    );
  }

  static AppLanguage fromProfileLocale(String? value) {
    if (value == null || value.isEmpty) {
      return english;
    }
    if (value.startsWith('es')) {
      return spanish;
    }
    if (value.startsWith('zh')) {
      return chinese;
    }
    return english;
  }

  static AppLanguage fromLocale(Locale? locale) {
    if (locale == null) {
      return english;
    }
    return fromCode(locale.languageCode);
  }

  String label(AppLocalizations l10n) => switch (this) {
    AppLanguage.english => l10n.languageEnglish,
    AppLanguage.spanish => l10n.languageSpanish,
    AppLanguage.chinese => l10n.languageChinese,
  };
}
