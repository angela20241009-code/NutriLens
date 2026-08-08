import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nutrilens/l10n/app_localizations.dart';
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

String localizedSportName(AppLocalizations l10n, String sportId) {
  return switch (sportId) {
    'tennis' => l10n.sportTennis,
    'basketball' => l10n.sportBasketball,
    'soccer' => l10n.sportSoccer,
    'american_football' => l10n.sportAmericanFootball,
    'baseball' => l10n.sportBaseball,
    'softball' => l10n.sportSoftball,
    'volleyball' => l10n.sportVolleyball,
    'swimming' => l10n.sportSwimming,
    'track_and_field' => l10n.sportTrackAndField,
    'cross_country' => l10n.sportCrossCountry,
    'wrestling' => l10n.sportWrestling,
    'lacrosse' => l10n.sportLacrosse,
    'hockey' => l10n.sportHockey,
    'golf' => l10n.sportGolf,
    'gymnastics' => l10n.sportGymnastics,
    'cycling' => l10n.sportCycling,
    'other' => l10n.sportOther,
    'none' => l10n.sportNone,
    _ => sportId,
  };
}

String localizedGreeting(AppLocalizations l10n, int hour) {
  if (hour < 12) return l10n.goodMorning;
  if (hour < 18) return l10n.goodAfternoon;
  return l10n.goodEvening;
}

String localizedScheduleFilter(AppLocalizations l10n, String filterKey) {
  return switch (filterKey) {
    'all' => l10n.scheduleFilterAll,
    'events' => l10n.scheduleFilterEvents,
    'loggedMeals' || 'meals' => l10n.scheduleFilterMeals,
    'sleep' => l10n.scheduleFilterSleep,
    _ => filterKey,
  };
}

String localizedScheduleEventType(AppLocalizations l10n, String type) {
  return switch (type) {
    'meal' => l10n.scheduleEventMeal,
    'training' || 'practice' => l10n.scheduleEventTraining,
    'match' || 'game' => l10n.scheduleEventMatch,
    'workout' => l10n.scheduleEventWorkout,
    'other' => l10n.scheduleEventOther,
    _ => type,
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

String localizedTextScaleDescription(
  AppLocalizations l10n,
  AppTextScale scale,
) {
  return switch (scale) {
    AppTextScale.small => l10n.textScaleSmallDesc,
    AppTextScale.medium => l10n.textScaleMediumDesc,
    AppTextScale.large => l10n.textScaleLargeDesc,
    AppTextScale.extraLarge => l10n.textScaleExtraLargeDesc,
  };
}

String localizedThemePaletteLabel(
  AppLocalizations l10n,
  AppThemePalette palette,
) {
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
      'requires-recent-login' => l10n.authErrorRequiresRecentLogin,
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

String formatLocalizedMonth(BuildContext context, int month) {
  assert(month >= DateTime.january && month <= DateTime.december);
  return DateFormat.MMMM(
    Localizations.localeOf(context).toString(),
  ).format(DateTime(2000, month));
}

String formatLocalizedWeekdayShort(BuildContext context, int weekday) {
  assert(weekday >= DateTime.monday && weekday <= DateTime.sunday);
  return DateFormat.E(
    Localizations.localeOf(context).toString(),
  ).format(DateTime(2000, 1, 2 + weekday));
}

String localizedMealType(AppLocalizations l10n, String mealType) {
  return switch (mealType.toUpperCase()) {
    'BREAKFAST' => l10n.mealTypeBreakfast,
    'LUNCH' => l10n.mealTypeLunch,
    'DINNER' => l10n.mealTypeDinner,
    'SNACK' => l10n.mealTypeSnack,
    _ => mealType,
  };
}
