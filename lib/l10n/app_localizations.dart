import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'NutriLens'**
  String get appTitle;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get languageChinese;

  /// No description provided for @languagePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languagePickerTitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'{feature} coming soon'**
  String comingSoon(String feature);

  /// No description provided for @authCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get authCreateTitle;

  /// No description provided for @authWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authWelcomeBack;

  /// No description provided for @authCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get authCreate;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// No description provided for @authMealPreferences.
  ///
  /// In en, this message translates to:
  /// **'Meal preferences'**
  String get authMealPreferences;

  /// No description provided for @authMealPreferencesHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us what you like and what to avoid before you sign in.'**
  String get authMealPreferencesHint;

  /// No description provided for @authMealsPerDay.
  ///
  /// In en, this message translates to:
  /// **'Meals per day'**
  String get authMealsPerDay;

  /// No description provided for @authMealsPerDayHint.
  ///
  /// In en, this message translates to:
  /// **'How many meals do you usually eat?'**
  String get authMealsPerDayHint;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccount;

  /// No description provided for @authContinueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get authContinueAsGuest;

  /// No description provided for @authValidationEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter an email'**
  String get authValidationEmailRequired;

  /// No description provided for @authValidationEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get authValidationEmailInvalid;

  /// No description provided for @authValidationPasswordMin.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get authValidationPasswordMin;

  /// No description provided for @authErrorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Use a stronger password.'**
  String get authErrorWeakPassword;

  /// No description provided for @authErrorEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'That email already has an account.'**
  String get authErrorEmailInUse;

  /// No description provided for @authErrorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get authErrorInvalidEmail;

  /// No description provided for @authErrorWrongCredentials.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect.'**
  String get authErrorWrongCredentials;

  /// No description provided for @authErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get authErrorNetwork;

  /// No description provided for @authErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Try again.'**
  String get authErrorGeneric;

  /// No description provided for @mealStylesTitle.
  ///
  /// In en, this message translates to:
  /// **'Food styles you like'**
  String get mealStylesTitle;

  /// No description provided for @mealStyleHighProtein.
  ///
  /// In en, this message translates to:
  /// **'High protein'**
  String get mealStyleHighProtein;

  /// No description provided for @mealStyleMediterranean.
  ///
  /// In en, this message translates to:
  /// **'Mediterranean'**
  String get mealStyleMediterranean;

  /// No description provided for @mealStyleVegetarian.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get mealStyleVegetarian;

  /// No description provided for @mealStyleVegan.
  ///
  /// In en, this message translates to:
  /// **'Vegan'**
  String get mealStyleVegan;

  /// No description provided for @mealStyleGlutenFree.
  ///
  /// In en, this message translates to:
  /// **'Gluten-free'**
  String get mealStyleGlutenFree;

  /// No description provided for @mealStyleLowCarb.
  ///
  /// In en, this message translates to:
  /// **'Low carb'**
  String get mealStyleLowCarb;

  /// No description provided for @mealStyleBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get mealStyleBalanced;

  /// No description provided for @mealStyleAsianInspired.
  ///
  /// In en, this message translates to:
  /// **'Asian-inspired'**
  String get mealStyleAsianInspired;

  /// No description provided for @mealStyleOthers.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get mealStyleOthers;

  /// No description provided for @mealStyleOtherLabel.
  ///
  /// In en, this message translates to:
  /// **'OTHER FOOD STYLE'**
  String get mealStyleOtherLabel;

  /// No description provided for @mealStyleOtherHelper.
  ///
  /// In en, this message translates to:
  /// **'Describe your preferred food style'**
  String get mealStyleOtherHelper;

  /// No description provided for @allergensLabel.
  ///
  /// In en, this message translates to:
  /// **'ALLERGENS'**
  String get allergensLabel;

  /// No description provided for @allergensHelper.
  ///
  /// In en, this message translates to:
  /// **'Use commas or new lines. Example: peanuts, shellfish'**
  String get allergensHelper;

  /// No description provided for @restrictionsLabel.
  ///
  /// In en, this message translates to:
  /// **'DIETARY RESTRICTIONS'**
  String get restrictionsLabel;

  /// No description provided for @restrictionsHelper.
  ///
  /// In en, this message translates to:
  /// **'Use commas or new lines. Example: halal, dairy-free'**
  String get restrictionsHelper;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @sectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get sectionAccount;

  /// No description provided for @sectionPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get sectionPersonal;

  /// No description provided for @sectionAthlete.
  ///
  /// In en, this message translates to:
  /// **'Athlete'**
  String get sectionAthlete;

  /// No description provided for @sectionNutritionGoals.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Goals'**
  String get sectionNutritionGoals;

  /// No description provided for @sectionDietary.
  ///
  /// In en, this message translates to:
  /// **'Dietary'**
  String get sectionDietary;

  /// No description provided for @sectionDisplay.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get sectionDisplay;

  /// No description provided for @sectionApp.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get sectionApp;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get displayName;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @notLinked.
  ///
  /// In en, this message translates to:
  /// **'Not linked'**
  String get notLinked;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @selectGender.
  ///
  /// In en, this message translates to:
  /// **'Select gender'**
  String get selectGender;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderNonBinary.
  ///
  /// In en, this message translates to:
  /// **'Non-binary'**
  String get genderNonBinary;

  /// No description provided for @genderPreferNotToSay.
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get genderPreferNotToSay;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @birthYear.
  ///
  /// In en, this message translates to:
  /// **'Birth year'**
  String get birthYear;

  /// No description provided for @enterValidYear.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid year'**
  String get enterValidYear;

  /// No description provided for @heightCm.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get heightCm;

  /// No description provided for @weightKg.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightKg;

  /// No description provided for @primarySport.
  ///
  /// In en, this message translates to:
  /// **'Primary sport'**
  String get primarySport;

  /// No description provided for @noSportSelected.
  ///
  /// In en, this message translates to:
  /// **'No sport selected'**
  String get noSportSelected;

  /// No description provided for @school.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get school;

  /// No description provided for @graduationYear.
  ///
  /// In en, this message translates to:
  /// **'Graduation year'**
  String get graduationYear;

  /// No description provided for @trainingDaysPerWeek.
  ///
  /// In en, this message translates to:
  /// **'Training days per week'**
  String get trainingDaysPerWeek;

  /// No description provided for @selectTrainingDays.
  ///
  /// In en, this message translates to:
  /// **'Select training days'**
  String get selectTrainingDays;

  /// No description provided for @trainingDaysCount.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String trainingDaysCount(int count);

  /// No description provided for @activityLevel.
  ///
  /// In en, this message translates to:
  /// **'Activity level'**
  String get activityLevel;

  /// No description provided for @selectActivityLevel.
  ///
  /// In en, this message translates to:
  /// **'Select activity level'**
  String get selectActivityLevel;

  /// No description provided for @activityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get activityLow;

  /// No description provided for @activityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get activityModerate;

  /// No description provided for @activityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get activityHigh;

  /// No description provided for @activityVeryHigh.
  ///
  /// In en, this message translates to:
  /// **'Very high'**
  String get activityVeryHigh;

  /// No description provided for @caloriesKcal.
  ///
  /// In en, this message translates to:
  /// **'Calories (kcal)'**
  String get caloriesKcal;

  /// No description provided for @proteinG.
  ///
  /// In en, this message translates to:
  /// **'Protein (g)'**
  String get proteinG;

  /// No description provided for @carbsG.
  ///
  /// In en, this message translates to:
  /// **'Carbs (g)'**
  String get carbsG;

  /// No description provided for @fatsG.
  ///
  /// In en, this message translates to:
  /// **'Fats (g)'**
  String get fatsG;

  /// No description provided for @hydrationL.
  ///
  /// In en, this message translates to:
  /// **'Hydration (L)'**
  String get hydrationL;

  /// No description provided for @sleepHrs.
  ///
  /// In en, this message translates to:
  /// **'Sleep (hrs)'**
  String get sleepHrs;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// No description provided for @enterNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a number'**
  String get enterNumber;

  /// No description provided for @accessibilityMode.
  ///
  /// In en, this message translates to:
  /// **'Accessibility mode'**
  String get accessibilityMode;

  /// No description provided for @textSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get textSize;

  /// No description provided for @themeColors.
  ///
  /// In en, this message translates to:
  /// **'Theme colors'**
  String get themeColors;

  /// No description provided for @textScaleSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get textScaleSmall;

  /// No description provided for @textScaleMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get textScaleMedium;

  /// No description provided for @textScaleLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get textScaleLarge;

  /// No description provided for @textScaleExtraLarge.
  ///
  /// In en, this message translates to:
  /// **'Extra large'**
  String get textScaleExtraLarge;

  /// No description provided for @textScaleSmallDesc.
  ///
  /// In en, this message translates to:
  /// **'Compact labels and body text.'**
  String get textScaleSmallDesc;

  /// No description provided for @textScaleMediumDesc.
  ///
  /// In en, this message translates to:
  /// **'Default app text size.'**
  String get textScaleMediumDesc;

  /// No description provided for @textScaleLargeDesc.
  ///
  /// In en, this message translates to:
  /// **'Easier to read on most screens.'**
  String get textScaleLargeDesc;

  /// No description provided for @textScaleExtraLargeDesc.
  ///
  /// In en, this message translates to:
  /// **'Maximum readability.'**
  String get textScaleExtraLargeDesc;

  /// No description provided for @themeClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic lime'**
  String get themeClassic;

  /// No description provided for @themeOcean.
  ///
  /// In en, this message translates to:
  /// **'Ocean blue'**
  String get themeOcean;

  /// No description provided for @themeSunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset coral'**
  String get themeSunset;

  /// No description provided for @themeForest.
  ///
  /// In en, this message translates to:
  /// **'Forest green'**
  String get themeForest;

  /// No description provided for @themePaletteDesc.
  ///
  /// In en, this message translates to:
  /// **'Accent and highlight colors across the app.'**
  String get themePaletteDesc;

  /// No description provided for @sleepMode.
  ///
  /// In en, this message translates to:
  /// **'Sleep Mode'**
  String get sleepMode;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get units;

  /// No description provided for @changesSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved'**
  String get changesSaved;

  /// No description provided for @failedToSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save: {error}'**
  String failedToSave(String error);

  /// No description provided for @unableToLoadSettings.
  ///
  /// In en, this message translates to:
  /// **'Unable to load settings: {error}'**
  String unableToLoadSettings(String error);

  /// No description provided for @unableToUpdateTextSize.
  ///
  /// In en, this message translates to:
  /// **'Unable to update text size: {error}'**
  String unableToUpdateTextSize(String error);

  /// No description provided for @unableToUpdateTheme.
  ///
  /// In en, this message translates to:
  /// **'Unable to update theme: {error}'**
  String unableToUpdateTheme(String error);

  /// No description provided for @unableToUpdateLanguage.
  ///
  /// In en, this message translates to:
  /// **'Unable to update language: {error}'**
  String unableToUpdateLanguage(String error);

  /// No description provided for @unableToSignOut.
  ///
  /// In en, this message translates to:
  /// **'Unable to sign out: {error}'**
  String unableToSignOut(String error);

  /// No description provided for @unableToDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Unable to delete account: {error}'**
  String unableToDeleteAccount(String error);

  /// No description provided for @failedToInitializeApp.
  ///
  /// In en, this message translates to:
  /// **'Failed to initialize the app:\n{error}'**
  String failedToInitializeApp(String error);

  /// No description provided for @failedToLoadAccount.
  ///
  /// In en, this message translates to:
  /// **'Failed to load account:\n{error}'**
  String failedToLoadAccount(String error);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
