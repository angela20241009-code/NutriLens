import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutrilens/l10n/app_localizations.dart';
import 'package:nutrilens/models/app_language.dart';
import 'package:nutrilens/models/app_text_scale.dart';
import 'package:nutrilens/models/app_theme_palette.dart';

String localizedMealStyle(AppLocalizations l10n, String style) {
  return switch (style) {
    'High protein' => l10n.mealStyleHighProtein,
    'Mediterranean' => l10n.mealStyleMediterranean,
    'Vegetarian' => l10n.mealStyleVegetarian,
    'Vegan' => l10n.mealStyleVegan,
    'Gluten-free' => l10n.mealStyleGlutenFree,
    'Low carb' => l10n.mealStyleLowCarb,
    'Balanced' => l10n.mealStyleBalanced,
    'Asian-inspired' => l10n.mealStyleAsianInspired,
    'Others' => l10n.mealStyleOthers,
    _ => style,
  };
}

String localizedTextScaleLabel(AppLocalizations l10n, AppTextScale scale) {
  return switch (scale) {
    AppTextScale.small => l10n.textScaleSmall,
    AppTextScale.medium => l10n.textScaleMedium,
    AppTextScale.large => l10n.textScaleLarge,
    AppTextScale.extraLarge => l10n.textScaleExtraLarge,
  };
}

String localizedTextScaleDescription(AppLocalizations l10n, AppTextScale scale) {
  return switch (scale) {
    AppTextScale.small => l10n.textScaleSmallDesc,
    AppTextScale.medium => l10n.textScaleMediumDesc,
    AppTextScale.large => l10n.textScaleLargeDesc,
    AppTextScale.extraLarge => l10n.textScaleExtraLargeDesc,
  };
}

String localizedThemePaletteLabel(AppLocalizations l10n, AppThemePalette palette) {
  return switch (palette) {
    AppThemePalette.classic => l10n.themeClassic,
    AppThemePalette.ocean => l10n.themeOcean,
    AppThemePalette.sunset => l10n.themeSunset,
    AppThemePalette.forest => l10n.themeForest,
  };
}

String friendlyAuthErrorMessage(AppLocalizations l10n, Object error) {
  final message = error.toString();
  if (message.contains('email-already-in-use')) {
    return l10n.authErrorEmailInUse;
  }
  if (message.contains('invalid-credential')) {
    return l10n.authErrorWrongCredentials;
  }

  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'weak-password' => l10n.authErrorWeakPassword,
      'email-already-in-use' => l10n.authErrorEmailInUse,
      'invalid-email' => l10n.authErrorInvalidEmail,
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' => l10n.authErrorWrongCredentials,
      'network-request-failed' => l10n.authErrorNetwork,
      _ => error.message ?? l10n.authErrorGeneric,
    };
  }

  return l10n.authErrorGeneric;
}

Map<String, String> localizedGenderOptions(AppLocalizations l10n) {
  return {
    'female': l10n.genderFemale,
    'male': l10n.genderMale,
    'non_binary': l10n.genderNonBinary,
    'prefer_not_to_say': l10n.genderPreferNotToSay,
  };
}

Map<String, String> localizedActivityOptions(AppLocalizations l10n) {
  return {
    'low': l10n.activityLow,
    'moderate': l10n.activityModerate,
    'high': l10n.activityHigh,
    'very_high': l10n.activityVeryHigh,
  };
}
