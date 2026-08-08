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

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @profileUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Profile unavailable'**
  String get profileUnavailable;

  /// No description provided for @unableToLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Unable to load profile: {error}'**
  String unableToLoadProfile(Object error);

  /// No description provided for @noNameSet.
  ///
  /// In en, this message translates to:
  /// **'No name set'**
  String get noNameSet;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @sport.
  ///
  /// In en, this message translates to:
  /// **'Sport'**
  String get sport;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @trainingDays.
  ///
  /// In en, this message translates to:
  /// **'Training days'**
  String get trainingDays;

  /// No description provided for @sleepTarget.
  ///
  /// In en, this message translates to:
  /// **'Sleep target'**
  String get sleepTarget;

  /// No description provided for @allergens.
  ///
  /// In en, this message translates to:
  /// **'Allergens'**
  String get allergens;

  /// No description provided for @restrictions.
  ///
  /// In en, this message translates to:
  /// **'Restrictions'**
  String get restrictions;

  /// No description provided for @editProfileAndSettings.
  ///
  /// In en, this message translates to:
  /// **'Edit profile & settings'**
  String get editProfileAndSettings;

  /// No description provided for @guestCreateAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get guestCreateAccountTitle;

  /// No description provided for @guestCreateAccountBody.
  ///
  /// In en, this message translates to:
  /// **'Sign up to save your profile, nutrition goals, and training data.'**
  String get guestCreateAccountBody;

  /// No description provided for @guestAccountNotice.
  ///
  /// In en, this message translates to:
  /// **'You are using a guest account without cloud sync. Profile editing is disabled until you create an account to save your data.'**
  String get guestAccountNotice;

  /// No description provided for @signOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutTitle;

  /// No description provided for @signOutGuestBody.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t linked an email. Signing out may lose your data on this device.'**
  String get signOutGuestBody;

  /// No description provided for @signOutAccountBody.
  ///
  /// In en, this message translates to:
  /// **'Sign out of {account}?'**
  String signOutAccountBody(String account);

  /// No description provided for @yourAccount.
  ///
  /// In en, this message translates to:
  /// **'your account'**
  String get yourAccount;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteGuestAccountBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your guest account and all logged meals, sleep, and profile data on this device. This cannot be undone.'**
  String get deleteGuestAccountBody;

  /// No description provided for @deleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes {account} and all associated data. This cannot be undone.'**
  String deleteAccountBody(String account);

  /// No description provided for @mealPreferencesDescription.
  ///
  /// In en, this message translates to:
  /// **'Pick food styles and allergies so we can personalize your meal plan.'**
  String get mealPreferencesDescription;

  /// No description provided for @unableToSavePreferences.
  ///
  /// In en, this message translates to:
  /// **'Unable to save preferences: {error}'**
  String unableToSavePreferences(String error);

  /// No description provided for @unableToLoadProfileShort.
  ///
  /// In en, this message translates to:
  /// **'Unable to load your profile.'**
  String get unableToLoadProfileShort;

  /// No description provided for @saveAndRefreshMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Save & refresh meal plan'**
  String get saveAndRefreshMealPlan;

  /// No description provided for @accountCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully'**
  String get accountCreatedSuccessfully;

  /// No description provided for @emailVerificationSent.
  ///
  /// In en, this message translates to:
  /// **'Verification sent — check your inbox to confirm.'**
  String get emailVerificationSent;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get passwordUpdated;

  /// No description provided for @unableToUpdateAccessibilityMode.
  ///
  /// In en, this message translates to:
  /// **'Unable to update accessibility mode: {error}'**
  String unableToUpdateAccessibilityMode(String error);

  /// No description provided for @unableToUpdateSleepMode.
  ///
  /// In en, this message translates to:
  /// **'Unable to update Sleep Mode: {error}'**
  String unableToUpdateSleepMode(String error);

  /// No description provided for @modeSwitcher.
  ///
  /// In en, this message translates to:
  /// **'Mode switcher'**
  String get modeSwitcher;

  /// No description provided for @minimalTabs.
  ///
  /// In en, this message translates to:
  /// **'Minimal tabs'**
  String get minimalTabs;

  /// No description provided for @minimalTabsDescription.
  ///
  /// In en, this message translates to:
  /// **'Slim top tabs with an active underline.'**
  String get minimalTabsDescription;

  /// No description provided for @classicPill.
  ///
  /// In en, this message translates to:
  /// **'Classic pill'**
  String get classicPill;

  /// No description provided for @classicPillDescription.
  ///
  /// In en, this message translates to:
  /// **'Original rounded segmented control.'**
  String get classicPillDescription;

  /// No description provided for @unableToUpdateModeSwitcher.
  ///
  /// In en, this message translates to:
  /// **'Unable to update mode switcher: {error}'**
  String unableToUpdateModeSwitcher(String error);

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @changeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get changeEmail;

  /// No description provided for @newEmail.
  ///
  /// In en, this message translates to:
  /// **'New email'**
  String get newEmail;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @passwordMinCharacters.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get passwordMinCharacters;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @sleepGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get sleepGreetingMorning;

  /// No description provided for @sleepGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get sleepGreetingAfternoon;

  /// No description provided for @sleepGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get sleepGreetingEvening;

  /// No description provided for @athlete.
  ///
  /// In en, this message translates to:
  /// **'Athlete'**
  String get athlete;

  /// No description provided for @logSleep.
  ///
  /// In en, this message translates to:
  /// **'Log sleep'**
  String get logSleep;

  /// No description provided for @sleepSchedule.
  ///
  /// In en, this message translates to:
  /// **'Sleep Schedule'**
  String get sleepSchedule;

  /// No description provided for @unableToSaveSleepSchedule.
  ///
  /// In en, this message translates to:
  /// **'Unable to save sleep schedule: {error}'**
  String unableToSaveSleepSchedule(String error);

  /// No description provided for @sleepProfileUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'We need your profile before planning sleep.'**
  String get sleepProfileUnavailableBody;

  /// No description provided for @wakeTimePlanning.
  ///
  /// In en, this message translates to:
  /// **'Wake-time planning'**
  String get wakeTimePlanning;

  /// No description provided for @setSleepSchedule.
  ///
  /// In en, this message translates to:
  /// **'Set your sleep schedule'**
  String get setSleepSchedule;

  /// No description provided for @wakeTimePlanningDescription.
  ///
  /// In en, this message translates to:
  /// **'We use your usual bedtime and wake time to protect recovery before training and match days.'**
  String get wakeTimePlanningDescription;

  /// No description provided for @setSleepScheduleDescription.
  ///
  /// In en, this message translates to:
  /// **'Add your usual bedtime and wake time so Sleep Mode can plan recovery and track sleep statistics.'**
  String get setSleepScheduleDescription;

  /// No description provided for @bedtime.
  ///
  /// In en, this message translates to:
  /// **'Bedtime'**
  String get bedtime;

  /// No description provided for @wakeTime.
  ///
  /// In en, this message translates to:
  /// **'Wake time'**
  String get wakeTime;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @saveSleepSchedule.
  ///
  /// In en, this message translates to:
  /// **'Save sleep schedule'**
  String get saveSleepSchedule;

  /// No description provided for @targetSleep.
  ///
  /// In en, this message translates to:
  /// **'Target sleep'**
  String get targetSleep;

  /// No description provided for @tonightBedtime.
  ///
  /// In en, this message translates to:
  /// **'Tonight bedtime'**
  String get tonightBedtime;

  /// No description provided for @earlierWakeSuggested.
  ///
  /// In en, this message translates to:
  /// **'Earlier wake suggested for {event} at {time}.'**
  String earlierWakeSuggested(String event, String time);

  /// No description provided for @customBedtimeLimit.
  ///
  /// In en, this message translates to:
  /// **'You can add up to 3 custom bedtime items.'**
  String get customBedtimeLimit;

  /// No description provided for @unableToSaveBedtimeItems.
  ///
  /// In en, this message translates to:
  /// **'Unable to save bedtime items: {error}'**
  String unableToSaveBedtimeItems(String error);

  /// No description provided for @enterValidTime.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid time like 10:30 PM or 22:30.'**
  String get enterValidTime;

  /// No description provided for @addCustomBedtime.
  ///
  /// In en, this message translates to:
  /// **'Add custom bedtime'**
  String get addCustomBedtime;

  /// No description provided for @editCustomBedtime.
  ///
  /// In en, this message translates to:
  /// **'Edit custom bedtime'**
  String get editCustomBedtime;

  /// No description provided for @bedtimeHint.
  ///
  /// In en, this message translates to:
  /// **'10:30 PM or 22:30'**
  String get bedtimeHint;

  /// No description provided for @pickTime.
  ///
  /// In en, this message translates to:
  /// **'Pick time'**
  String get pickTime;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @sleepLoggedForDay.
  ///
  /// In en, this message translates to:
  /// **'Saved {duration} for {day}. {advice}'**
  String sleepLoggedForDay(String duration, String day, String advice);

  /// No description provided for @sleepAppliedForDays.
  ///
  /// In en, this message translates to:
  /// **'Applied {duration} to {count} days. {advice}'**
  String sleepAppliedForDays(String duration, int count, String advice);

  /// No description provided for @unableToLoadSleepSchedule.
  ///
  /// In en, this message translates to:
  /// **'Unable to load sleep schedule:\n{error}'**
  String unableToLoadSleepSchedule(String error);

  /// No description provided for @sleepScheduleUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Sleep schedule unavailable'**
  String get sleepScheduleUnavailable;

  /// No description provided for @sleepScheduleDescription.
  ///
  /// In en, this message translates to:
  /// **'Pick a day, enter hours and minutes, then save one day or apply the same sleep duration for the next week.'**
  String get sleepScheduleDescription;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutes;

  /// No description provided for @selectedDuration.
  ///
  /// In en, this message translates to:
  /// **'Selected duration: {duration}'**
  String selectedDuration(String duration);

  /// No description provided for @targetDuration.
  ///
  /// In en, this message translates to:
  /// **'Target {duration}'**
  String targetDuration(String duration);

  /// No description provided for @presetBedtimes.
  ///
  /// In en, this message translates to:
  /// **'Preset bedtimes'**
  String get presetBedtimes;

  /// No description provided for @customBedtimeItems.
  ///
  /// In en, this message translates to:
  /// **'Custom bedtime items ({count}/{max})'**
  String customBedtimeItems(int count, int max);

  /// No description provided for @noCustomBedtimeItems.
  ///
  /// In en, this message translates to:
  /// **'No custom bedtime items yet. Add up to 3.'**
  String get noCustomBedtimeItems;

  /// No description provided for @editTime.
  ///
  /// In en, this message translates to:
  /// **'Edit time'**
  String get editTime;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @bedtimeItemsDescription.
  ///
  /// In en, this message translates to:
  /// **'Bedtime items use wake time {time} to calculate your sleep duration.'**
  String bedtimeItemsDescription(String time);

  /// No description provided for @saveDay.
  ///
  /// In en, this message translates to:
  /// **'Save day'**
  String get saveDay;

  /// No description provided for @applyNextSevenDays.
  ///
  /// In en, this message translates to:
  /// **'Apply next 7 days'**
  String get applyNextSevenDays;

  /// No description provided for @automaticTrackingStatus.
  ///
  /// In en, this message translates to:
  /// **'Automatic tracking status'**
  String get automaticTrackingStatus;

  /// No description provided for @automaticTrackingDescription.
  ///
  /// In en, this message translates to:
  /// **'Clock-only background tracking is not reliable on iOS/Android due to background limits. Use this planner for manual scheduling and keep health sync as a future auto option.'**
  String get automaticTrackingDescription;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @mondayShort.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mondayShort;

  /// No description provided for @tuesdayShort.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesdayShort;

  /// No description provided for @wednesdayShort.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesdayShort;

  /// No description provided for @thursdayShort.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursdayShort;

  /// No description provided for @fridayShort.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fridayShort;

  /// No description provided for @saturdayShort.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get saturdayShort;

  /// No description provided for @sundayShort.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sundayShort;

  /// No description provided for @sleepDurationInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter valid hours and minutes (0–59 for minutes).'**
  String get sleepDurationInvalid;

  /// No description provided for @sleepDurationRange.
  ///
  /// In en, this message translates to:
  /// **'Sleep duration should be between 2 and 16 hours.'**
  String get sleepDurationRange;

  /// No description provided for @sleepTotal.
  ///
  /// In en, this message translates to:
  /// **'Total: {duration}'**
  String sleepTotal(String duration);

  /// No description provided for @sleepTargetHours.
  ///
  /// In en, this message translates to:
  /// **'Target: {hours}h'**
  String sleepTargetHours(String hours);

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @saveSleep.
  ///
  /// In en, this message translates to:
  /// **'Save sleep'**
  String get saveSleep;

  /// No description provided for @sleepCheckInDescription.
  ///
  /// In en, this message translates to:
  /// **'How long did you sleep? Enter hours and minutes, or skip for now.'**
  String get sleepCheckInDescription;

  /// No description provided for @sleepLogged.
  ///
  /// In en, this message translates to:
  /// **'Logged {duration}. {advice}'**
  String sleepLogged(String duration, String advice);

  /// No description provided for @unableToSaveSleepLog.
  ///
  /// In en, this message translates to:
  /// **'Unable to save sleep log: {error}'**
  String unableToSaveSleepLog(String error);

  /// No description provided for @recoveryAhead.
  ///
  /// In en, this message translates to:
  /// **'Recovery is ahead'**
  String get recoveryAhead;

  /// No description provided for @sleepAboveTarget.
  ///
  /// In en, this message translates to:
  /// **'You slept {slept}, above your {target}h target.'**
  String sleepAboveTarget(String slept, String target);

  /// No description provided for @sleepConsistencyAdvice.
  ///
  /// In en, this message translates to:
  /// **'Keep bedtime near {bedtime} and wake around {wakeTime} to stay consistent.'**
  String sleepConsistencyAdvice(String bedtime, String wakeTime);

  /// No description provided for @onTarget.
  ///
  /// In en, this message translates to:
  /// **'On target'**
  String get onTarget;

  /// No description provided for @sleepMatchesTarget.
  ///
  /// In en, this message translates to:
  /// **'You slept {slept}, matching your {target}h goal.'**
  String sleepMatchesTarget(String slept, String target);

  /// No description provided for @sleepRhythmAdvice.
  ///
  /// In en, this message translates to:
  /// **'Stay on rhythm with bedtime around {bedtime} and wake around {wakeTime}.'**
  String sleepRhythmAdvice(String bedtime, String wakeTime);

  /// No description provided for @sleepNeedsBoost.
  ///
  /// In en, this message translates to:
  /// **'Sleep needs a boost'**
  String get sleepNeedsBoost;

  /// No description provided for @sleepBelowTarget.
  ///
  /// In en, this message translates to:
  /// **'You are about {deficit}h under your {target}h target.'**
  String sleepBelowTarget(String deficit, String target);

  /// No description provided for @sleepRecoveryAdvice.
  ///
  /// In en, this message translates to:
  /// **'Tonight, aim for bedtime near {bedtime} so you can wake at {wakeTime} with better recovery.{eventNote}'**
  String sleepRecoveryAdvice(String bedtime, String wakeTime, String eventNote);

  /// No description provided for @earlierWakeRecommendation.
  ///
  /// In en, this message translates to:
  /// **'An earlier wake is suggested before {event} at {time}.'**
  String earlierWakeRecommendation(String event, String time);

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
  /// **'Tell us what you like and what to avoid after you sign up.'**
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

  /// No description provided for @authLegalAgreement.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Privacy Policy and Terms & Conditions'**
  String get authLegalAgreement;

  /// No description provided for @authPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get authPrivacyPolicy;

  /// No description provided for @authTermsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get authTermsAndConditions;

  /// No description provided for @authValidationLegalRequired.
  ///
  /// In en, this message translates to:
  /// **'Accept the Privacy Policy and Terms & Conditions to continue'**
  String get authValidationLegalRequired;

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

  /// No description provided for @deleteAccountReauthTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get deleteAccountReauthTitle;

  /// No description provided for @deleteAccountReauthBody.
  ///
  /// In en, this message translates to:
  /// **'For your security, enter your password to permanently delete this account.'**
  String get deleteAccountReauthBody;

  /// No description provided for @deleteAccountReauthPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get deleteAccountReauthPassword;

  /// No description provided for @authErrorRequiresRecentLogin.
  ///
  /// In en, this message translates to:
  /// **'For your security, confirm your password and try again.'**
  String get authErrorRequiresRecentLogin;

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

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @finishSetup.
  ///
  /// In en, this message translates to:
  /// **'Finish setup'**
  String get finishSetup;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @maybe.
  ///
  /// In en, this message translates to:
  /// **'Maybe'**
  String get maybe;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @enterPositiveNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a positive number'**
  String get enterPositiveNumber;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navMeals.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get navMeals;

  /// No description provided for @navSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get navSchedule;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get navSleep;

  /// No description provided for @navLog.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get navLog;

  /// No description provided for @modeMealTracking.
  ///
  /// In en, this message translates to:
  /// **'Meal Tracking'**
  String get modeMealTracking;

  /// No description provided for @modeSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get modeSleep;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @sportTennis.
  ///
  /// In en, this message translates to:
  /// **'Tennis'**
  String get sportTennis;

  /// No description provided for @sportBasketball.
  ///
  /// In en, this message translates to:
  /// **'Basketball'**
  String get sportBasketball;

  /// No description provided for @sportSoccer.
  ///
  /// In en, this message translates to:
  /// **'Soccer'**
  String get sportSoccer;

  /// No description provided for @sportAmericanFootball.
  ///
  /// In en, this message translates to:
  /// **'American Football'**
  String get sportAmericanFootball;

  /// No description provided for @sportBaseball.
  ///
  /// In en, this message translates to:
  /// **'Baseball'**
  String get sportBaseball;

  /// No description provided for @sportSoftball.
  ///
  /// In en, this message translates to:
  /// **'Softball'**
  String get sportSoftball;

  /// No description provided for @sportVolleyball.
  ///
  /// In en, this message translates to:
  /// **'Volleyball'**
  String get sportVolleyball;

  /// No description provided for @sportSwimming.
  ///
  /// In en, this message translates to:
  /// **'Swimming'**
  String get sportSwimming;

  /// No description provided for @sportTrackAndField.
  ///
  /// In en, this message translates to:
  /// **'Track & Field'**
  String get sportTrackAndField;

  /// No description provided for @sportCrossCountry.
  ///
  /// In en, this message translates to:
  /// **'Cross Country'**
  String get sportCrossCountry;

  /// No description provided for @sportWrestling.
  ///
  /// In en, this message translates to:
  /// **'Wrestling'**
  String get sportWrestling;

  /// No description provided for @sportLacrosse.
  ///
  /// In en, this message translates to:
  /// **'Lacrosse'**
  String get sportLacrosse;

  /// No description provided for @sportHockey.
  ///
  /// In en, this message translates to:
  /// **'Hockey'**
  String get sportHockey;

  /// No description provided for @sportGolf.
  ///
  /// In en, this message translates to:
  /// **'Golf'**
  String get sportGolf;

  /// No description provided for @sportGymnastics.
  ///
  /// In en, this message translates to:
  /// **'Gymnastics'**
  String get sportGymnastics;

  /// No description provided for @sportCycling.
  ///
  /// In en, this message translates to:
  /// **'Cycling'**
  String get sportCycling;

  /// No description provided for @sportOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get sportOther;

  /// No description provided for @sportNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get sportNone;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'NutriLens'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fuel smarter. Train harder.'**
  String get onboardingWelcomeSubtitle;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingYourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get onboardingYourName;

  /// No description provided for @onboardingFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'FULL NAME'**
  String get onboardingFullNameLabel;

  /// No description provided for @onboardingAboutSport.
  ///
  /// In en, this message translates to:
  /// **'About your sport'**
  String get onboardingAboutSport;

  /// No description provided for @onboardingPlaySportQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you currently play a sport?'**
  String get onboardingPlaySportQuestion;

  /// No description provided for @onboardingPlaySportYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, I play a sport'**
  String get onboardingPlaySportYes;

  /// No description provided for @onboardingPlaySportNo.
  ///
  /// In en, this message translates to:
  /// **'No, not currently'**
  String get onboardingPlaySportNo;

  /// No description provided for @onboardingYourSportLabel.
  ///
  /// In en, this message translates to:
  /// **'YOUR SPORT'**
  String get onboardingYourSportLabel;

  /// No description provided for @onboardingEnterSport.
  ///
  /// In en, this message translates to:
  /// **'Enter your sport'**
  String get onboardingEnterSport;

  /// No description provided for @onboardingNoSportTargets.
  ///
  /// In en, this message translates to:
  /// **'No problem — we\'ll estimate your nutrition targets from your body metrics.'**
  String get onboardingNoSportTargets;

  /// No description provided for @onboardingChooseOption.
  ///
  /// In en, this message translates to:
  /// **'Choose an option above to continue.'**
  String get onboardingChooseOption;

  /// No description provided for @onboardingYourSchool.
  ///
  /// In en, this message translates to:
  /// **'Your school'**
  String get onboardingYourSchool;

  /// No description provided for @onboardingSchoolNameLabel.
  ///
  /// In en, this message translates to:
  /// **'SCHOOL NAME (OPTIONAL)'**
  String get onboardingSchoolNameLabel;

  /// No description provided for @onboardingGraduationYearLabel.
  ///
  /// In en, this message translates to:
  /// **'GRADUATION YEAR (OPTIONAL)'**
  String get onboardingGraduationYearLabel;

  /// No description provided for @onboardingEnterFourDigitYear.
  ///
  /// In en, this message translates to:
  /// **'Enter a 4-digit year'**
  String get onboardingEnterFourDigitYear;

  /// No description provided for @onboardingSleepCheck.
  ///
  /// In en, this message translates to:
  /// **'Sleep check'**
  String get onboardingSleepCheck;

  /// No description provided for @onboardingSleepCheckIntro.
  ///
  /// In en, this message translates to:
  /// **'Three quick questions. Tap a choice to select it — tap again to clear.'**
  String get onboardingSleepCheckIntro;

  /// No description provided for @sleepQuestionWakeTired.
  ///
  /// In en, this message translates to:
  /// **'Do you wake up tired?'**
  String get sleepQuestionWakeTired;

  /// No description provided for @sleepQuestionWakeTiredHint.
  ///
  /// In en, this message translates to:
  /// **'Think about a typical school week.'**
  String get sleepQuestionWakeTiredHint;

  /// No description provided for @sleepQuestionBedtimeChanges.
  ///
  /// In en, this message translates to:
  /// **'Does your bedtime change a lot?'**
  String get sleepQuestionBedtimeChanges;

  /// No description provided for @sleepQuestionBedtimeChangesHint.
  ///
  /// In en, this message translates to:
  /// **'Games, practice, or homework can push sleep later.'**
  String get sleepQuestionBedtimeChangesHint;

  /// No description provided for @sleepQuestionReminder.
  ///
  /// In en, this message translates to:
  /// **'Would a bedtime reminder help?'**
  String get sleepQuestionReminder;

  /// No description provided for @sleepQuestionReminderHint.
  ///
  /// In en, this message translates to:
  /// **'A gentle nudge before your target sleep time.'**
  String get sleepQuestionReminderHint;

  /// No description provided for @sleepAnswerNotOften.
  ///
  /// In en, this message translates to:
  /// **'Not often'**
  String get sleepAnswerNotOften;

  /// No description provided for @sleepAnswerSometimes.
  ///
  /// In en, this message translates to:
  /// **'Sometimes'**
  String get sleepAnswerSometimes;

  /// No description provided for @sleepAnswerOften.
  ///
  /// In en, this message translates to:
  /// **'Often'**
  String get sleepAnswerOften;

  /// No description provided for @onboardingUseSleepMode.
  ///
  /// In en, this message translates to:
  /// **'Use Sleep Mode'**
  String get onboardingUseSleepMode;

  /// No description provided for @onboardingSleepRecommended.
  ///
  /// In en, this message translates to:
  /// **'We recommend Sleep Mode'**
  String get onboardingSleepRecommended;

  /// No description provided for @onboardingSleepOptional.
  ///
  /// In en, this message translates to:
  /// **'Sleep Mode is optional'**
  String get onboardingSleepOptional;

  /// No description provided for @onboardingSleepRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Based on your answers, Sleep Mode could help you recover.'**
  String get onboardingSleepRecommendation;

  /// No description provided for @onboardingSleepOptionalBody.
  ///
  /// In en, this message translates to:
  /// **'You can turn it on later in Settings if your schedule changes.'**
  String get onboardingSleepOptionalBody;

  /// No description provided for @onboardingBodyMetrics.
  ///
  /// In en, this message translates to:
  /// **'Your body metrics'**
  String get onboardingBodyMetrics;

  /// No description provided for @onboardingBodyMetricsHint.
  ///
  /// In en, this message translates to:
  /// **'We use height and weight to estimate your daily nutrition targets.'**
  String get onboardingBodyMetricsHint;

  /// No description provided for @onboardingHeightLabel.
  ///
  /// In en, this message translates to:
  /// **'HEIGHT (CM)'**
  String get onboardingHeightLabel;

  /// No description provided for @onboardingWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'WEIGHT (KG)'**
  String get onboardingWeightLabel;

  /// No description provided for @onboardingMaximumHeight.
  ///
  /// In en, this message translates to:
  /// **'Maximum height is {height} cm'**
  String onboardingMaximumHeight(int height);

  /// No description provided for @onboardingMaximumWeight.
  ///
  /// In en, this message translates to:
  /// **'Maximum weight is {weight} kg'**
  String onboardingMaximumWeight(int weight);

  /// No description provided for @onboardingNutritionTargets.
  ///
  /// In en, this message translates to:
  /// **'Daily nutrition targets'**
  String get onboardingNutritionTargets;

  /// No description provided for @onboardingTargetsFromSport.
  ///
  /// In en, this message translates to:
  /// **'We estimated these from your sport, height, and weight. You can adjust.'**
  String get onboardingTargetsFromSport;

  /// No description provided for @onboardingTargetsFromMetrics.
  ///
  /// In en, this message translates to:
  /// **'We estimated these from your height and weight. You can adjust.'**
  String get onboardingTargetsFromMetrics;

  /// No description provided for @homeTodayMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Meal Plan'**
  String get homeTodayMealPlan;

  /// No description provided for @homeNoMealsPlanned.
  ///
  /// In en, this message translates to:
  /// **'No meals planned for today yet.'**
  String get homeNoMealsPlanned;

  /// No description provided for @homeMealPlanUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Meal plan is unavailable right now.'**
  String get homeMealPlanUnavailable;

  /// No description provided for @homeMealPlanRefreshed.
  ///
  /// In en, this message translates to:
  /// **'Meal plan refreshed with your preferences'**
  String get homeMealPlanRefreshed;

  /// No description provided for @homeUnableToSaveHydration.
  ///
  /// In en, this message translates to:
  /// **'Unable to save hydration: {error}'**
  String homeUnableToSaveHydration(String error);

  /// No description provided for @homeFailedToLoadData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load home data:\n{error}'**
  String homeFailedToLoadData(String error);

  /// No description provided for @homeThisWeeksFuel.
  ///
  /// In en, this message translates to:
  /// **'This week\'s fuel'**
  String get homeThisWeeksFuel;

  /// No description provided for @homeTodayFuel.
  ///
  /// In en, this message translates to:
  /// **'Today\'s fuel'**
  String get homeTodayFuel;

  /// No description provided for @homeHydration.
  ///
  /// In en, this message translates to:
  /// **'Hydration'**
  String get homeHydration;

  /// No description provided for @homeProgramTitle.
  ///
  /// In en, this message translates to:
  /// **'Your program'**
  String get homeProgramTitle;

  /// No description provided for @homeProgramSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stay consistent and fuel your training.'**
  String get homeProgramSubtitle;

  /// No description provided for @homeWeeklySleep.
  ///
  /// In en, this message translates to:
  /// **'Weekly sleep'**
  String get homeWeeklySleep;

  /// No description provided for @homeLogged.
  ///
  /// In en, this message translates to:
  /// **'Logged'**
  String get homeLogged;

  /// No description provided for @homeTargetHours.
  ///
  /// In en, this message translates to:
  /// **'Target {hours}h'**
  String homeTargetHours(String hours);

  /// No description provided for @scheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get scheduleTitle;

  /// No description provided for @scheduleTimeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get scheduleTimeline;

  /// No description provided for @scheduleMeals.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get scheduleMeals;

  /// No description provided for @scheduleEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get scheduleEvents;

  /// No description provided for @scheduleSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get scheduleSleep;

  /// No description provided for @scheduleLogSleep.
  ///
  /// In en, this message translates to:
  /// **'Log sleep'**
  String get scheduleLogSleep;

  /// No description provided for @scheduleLogSleepForDay.
  ///
  /// In en, this message translates to:
  /// **'Log sleep for this day'**
  String get scheduleLogSleepForDay;

  /// No description provided for @scheduleNewMealReady.
  ///
  /// In en, this message translates to:
  /// **'New {meal} meal ready'**
  String scheduleNewMealReady(String meal);

  /// No description provided for @scheduleMealGenerationFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not generate a new meal: {error}'**
  String scheduleMealGenerationFailed(String error);

  /// No description provided for @scheduleDeleteEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete event?'**
  String get scheduleDeleteEventTitle;

  /// No description provided for @scheduleDeleteEventBody.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\" from your schedule?'**
  String scheduleDeleteEventBody(String title);

  /// No description provided for @scheduleDeleteEventFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete event.'**
  String get scheduleDeleteEventFailed;

  /// No description provided for @scheduleEventDeleted.
  ///
  /// In en, this message translates to:
  /// **'Event deleted.'**
  String get scheduleEventDeleted;

  /// No description provided for @scheduleNoItems.
  ///
  /// In en, this message translates to:
  /// **'Nothing scheduled for this day.'**
  String get scheduleNoItems;

  /// No description provided for @scheduleCreateEvent.
  ///
  /// In en, this message translates to:
  /// **'Create event'**
  String get scheduleCreateEvent;

  /// No description provided for @scheduleEventCreated.
  ///
  /// In en, this message translates to:
  /// **'Event created'**
  String get scheduleEventCreated;

  /// No description provided for @scheduleEventType.
  ///
  /// In en, this message translates to:
  /// **'Event type'**
  String get scheduleEventType;

  /// No description provided for @scheduleEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get scheduleEventTitle;

  /// No description provided for @scheduleDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get scheduleDate;

  /// No description provided for @scheduleTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get scheduleTime;

  /// No description provided for @scheduleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Subtitle'**
  String get scheduleSubtitle;

  /// No description provided for @scheduleLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get scheduleLocation;

  /// No description provided for @scheduleBadge.
  ///
  /// In en, this message translates to:
  /// **'Badge'**
  String get scheduleBadge;

  /// No description provided for @scheduleFuelingHints.
  ///
  /// In en, this message translates to:
  /// **'Fueling hints'**
  String get scheduleFuelingHints;

  /// No description provided for @scheduleTiming.
  ///
  /// In en, this message translates to:
  /// **'Timing'**
  String get scheduleTiming;

  /// No description provided for @scheduleHint.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get scheduleHint;

  /// No description provided for @scheduleFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get scheduleFilterAll;

  /// No description provided for @scheduleFilterMeals.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get scheduleFilterMeals;

  /// No description provided for @scheduleFilterEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get scheduleFilterEvents;

  /// No description provided for @scheduleFilterSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get scheduleFilterSleep;

  /// No description provided for @scheduleEventPractice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get scheduleEventPractice;

  /// No description provided for @scheduleEventGame.
  ///
  /// In en, this message translates to:
  /// **'Game'**
  String get scheduleEventGame;

  /// No description provided for @scheduleEventWorkout.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get scheduleEventWorkout;

  /// No description provided for @scheduleEventOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get scheduleEventOther;

  /// No description provided for @scheduleEventMeal.
  ///
  /// In en, this message translates to:
  /// **'Meal'**
  String get scheduleEventMeal;

  /// No description provided for @scheduleEventTraining.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get scheduleEventTraining;

  /// No description provided for @scheduleEventMatch.
  ///
  /// In en, this message translates to:
  /// **'Match'**
  String get scheduleEventMatch;

  /// No description provided for @mealsTitle.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get mealsTitle;

  /// No description provided for @mealsLogMeal.
  ///
  /// In en, this message translates to:
  /// **'Log meal'**
  String get mealsLogMeal;

  /// No description provided for @mealsMealLogged.
  ///
  /// In en, this message translates to:
  /// **'Meal logged successfully'**
  String get mealsMealLogged;

  /// No description provided for @mealsMealName.
  ///
  /// In en, this message translates to:
  /// **'Meal name'**
  String get mealsMealName;

  /// No description provided for @mealsCalories.
  ///
  /// In en, this message translates to:
  /// **'Calories kcal'**
  String get mealsCalories;

  /// No description provided for @mealsProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get mealsProtein;

  /// No description provided for @mealsCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get mealsCarbs;

  /// No description provided for @mealsFats.
  ///
  /// In en, this message translates to:
  /// **'Fats'**
  String get mealsFats;

  /// No description provided for @mealsSaveMeal.
  ///
  /// In en, this message translates to:
  /// **'Save meal'**
  String get mealsSaveMeal;

  /// No description provided for @mealsFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get mealsFavorites;

  /// No description provided for @mealsFavoriteLogged.
  ///
  /// In en, this message translates to:
  /// **'{title} logged'**
  String mealsFavoriteLogged(String title);

  /// No description provided for @mealsRecipeDetails.
  ///
  /// In en, this message translates to:
  /// **'Recipe details'**
  String get mealsRecipeDetails;

  /// No description provided for @mealsIngredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get mealsIngredients;

  /// No description provided for @mealsInstructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get mealsInstructions;

  /// No description provided for @mealsMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String mealsMinutes(int count);

  /// No description provided for @mealsServings.
  ///
  /// In en, this message translates to:
  /// **'{count} servings'**
  String mealsServings(int count);

  /// No description provided for @sleepDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Sleep Schedule'**
  String get sleepDashboardTitle;

  /// No description provided for @sleepProfileUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Profile unavailable'**
  String get sleepProfileUnavailable;

  /// No description provided for @sleepBedtime.
  ///
  /// In en, this message translates to:
  /// **'Bedtime'**
  String get sleepBedtime;

  /// No description provided for @sleepWakeTime.
  ///
  /// In en, this message translates to:
  /// **'Wake time'**
  String get sleepWakeTime;

  /// No description provided for @sleepSaveSchedule.
  ///
  /// In en, this message translates to:
  /// **'Save sleep schedule'**
  String get sleepSaveSchedule;

  /// No description provided for @sleepUnableToSaveSchedule.
  ///
  /// In en, this message translates to:
  /// **'Unable to save sleep schedule: {error}'**
  String sleepUnableToSaveSchedule(String error);

  /// No description provided for @sleepTargetSleep.
  ///
  /// In en, this message translates to:
  /// **'Target sleep'**
  String get sleepTargetSleep;

  /// No description provided for @sleepTonightBedtime.
  ///
  /// In en, this message translates to:
  /// **'Tonight bedtime'**
  String get sleepTonightBedtime;

  /// No description provided for @sleepRecoveryAhead.
  ///
  /// In en, this message translates to:
  /// **'Recovery is ahead'**
  String get sleepRecoveryAhead;

  /// No description provided for @sleepOnTarget.
  ///
  /// In en, this message translates to:
  /// **'On target'**
  String get sleepOnTarget;

  /// No description provided for @sleepUnableToSaveLog.
  ///
  /// In en, this message translates to:
  /// **'Unable to save sleep log: {error}'**
  String sleepUnableToSaveLog(String error);

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileSignOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get profileSignOutTitle;

  /// No description provided for @profileSignOutBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get profileSignOutBody;

  /// No description provided for @profileDeleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get profileDeleteAccountTitle;

  /// No description provided for @profileDeleteGuestBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your guest account and all logged meals, sleep, and profile data on this device. This cannot be undone.'**
  String get profileDeleteGuestBody;

  /// No description provided for @profileDeleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes {email} and all associated data. This cannot be undone.'**
  String profileDeleteAccountBody(String email);

  /// No description provided for @profileAccountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully'**
  String get profileAccountCreated;

  /// No description provided for @profileVerificationSent.
  ///
  /// In en, this message translates to:
  /// **'Verification sent — check your inbox to confirm.'**
  String get profileVerificationSent;

  /// No description provided for @profilePasswordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get profilePasswordUpdated;

  /// No description provided for @profileCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get profileCreateAccount;

  /// No description provided for @profileLinkEmail.
  ///
  /// In en, this message translates to:
  /// **'Link email'**
  String get profileLinkEmail;

  /// No description provided for @profileGuestNotice.
  ///
  /// In en, this message translates to:
  /// **'Create an account to back up your data and use it across devices.'**
  String get profileGuestNotice;

  /// No description provided for @profileSaveRefreshMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Save & refresh meal plan'**
  String get profileSaveRefreshMealPlan;

  /// No description provided for @profileUnableToUpdateAccessibility.
  ///
  /// In en, this message translates to:
  /// **'Unable to update accessibility mode: {error}'**
  String profileUnableToUpdateAccessibility(String error);

  /// No description provided for @profileUnableToUpdateSleepMode.
  ///
  /// In en, this message translates to:
  /// **'Unable to update Sleep Mode: {error}'**
  String profileUnableToUpdateSleepMode(String error);

  /// No description provided for @profileModeSwitcher.
  ///
  /// In en, this message translates to:
  /// **'Mode switcher'**
  String get profileModeSwitcher;

  /// No description provided for @profileMinimalTabs.
  ///
  /// In en, this message translates to:
  /// **'Minimal tabs'**
  String get profileMinimalTabs;

  /// No description provided for @profileMinimalTabsDescription.
  ///
  /// In en, this message translates to:
  /// **'Slim top tabs with an active underline.'**
  String get profileMinimalTabsDescription;

  /// No description provided for @profileClassicPill.
  ///
  /// In en, this message translates to:
  /// **'Classic pill'**
  String get profileClassicPill;

  /// No description provided for @profileClassicPillDescription.
  ///
  /// In en, this message translates to:
  /// **'Original rounded segmented control.'**
  String get profileClassicPillDescription;

  /// No description provided for @profileUnableToUpdateModeSwitcher.
  ///
  /// In en, this message translates to:
  /// **'Unable to update mode switcher: {error}'**
  String profileUnableToUpdateModeSwitcher(String error);

  /// No description provided for @scheduleMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Meal plan'**
  String get scheduleMealPlan;

  /// No description provided for @scheduleNoMealsPlanned.
  ///
  /// In en, this message translates to:
  /// **'No meals planned for this day.'**
  String get scheduleNoMealsPlanned;

  /// No description provided for @scheduleMealPlanUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Meal plan is unavailable right now.'**
  String get scheduleMealPlanUnavailable;

  /// No description provided for @scheduleGenerating.
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get scheduleGenerating;

  /// No description provided for @scheduleNewMeal.
  ///
  /// In en, this message translates to:
  /// **'New meal'**
  String get scheduleNewMeal;

  /// No description provided for @scheduleSleepLogged.
  ///
  /// In en, this message translates to:
  /// **'Sleep logged'**
  String get scheduleSleepLogged;

  /// No description provided for @scheduleThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get scheduleThisWeek;

  /// No description provided for @scheduleFullMonth.
  ///
  /// In en, this message translates to:
  /// **'Full month'**
  String get scheduleFullMonth;

  /// No description provided for @scheduleTodaysMatch.
  ///
  /// In en, this message translates to:
  /// **'Today\'s match'**
  String get scheduleTodaysMatch;

  /// No description provided for @scheduleAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add title'**
  String get scheduleAddTitle;

  /// No description provided for @scheduleAddSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add subtitle'**
  String get scheduleAddSubtitle;

  /// No description provided for @scheduleAddLocation.
  ///
  /// In en, this message translates to:
  /// **'Add location'**
  String get scheduleAddLocation;

  /// No description provided for @scheduleAddBadge.
  ///
  /// In en, this message translates to:
  /// **'Add badge'**
  String get scheduleAddBadge;

  /// No description provided for @scheduleAddHints.
  ///
  /// In en, this message translates to:
  /// **'Add hints'**
  String get scheduleAddHints;

  /// No description provided for @scheduleHintCount.
  ///
  /// In en, this message translates to:
  /// **'{count} hints'**
  String scheduleHintCount(int count);

  /// No description provided for @scheduleTimingHint.
  ///
  /// In en, this message translates to:
  /// **'2h before'**
  String get scheduleTimingHint;

  /// No description provided for @scheduleHydrate.
  ///
  /// In en, this message translates to:
  /// **'Hydrate'**
  String get scheduleHydrate;

  /// No description provided for @scheduleRemoveHint.
  ///
  /// In en, this message translates to:
  /// **'Remove hint'**
  String get scheduleRemoveHint;

  /// No description provided for @scheduleLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load schedule.'**
  String get scheduleLoadFailed;

  /// No description provided for @scheduleLogSleepEmpty.
  ///
  /// In en, this message translates to:
  /// **'No sleep logged for this day.'**
  String get scheduleLogSleepEmpty;

  /// No description provided for @scheduleNoEvents.
  ///
  /// In en, this message translates to:
  /// **'No events scheduled for this day.'**
  String get scheduleNoEvents;

  /// No description provided for @scheduleNoMeals.
  ///
  /// In en, this message translates to:
  /// **'No logged meals for this day.'**
  String get scheduleNoMeals;

  /// No description provided for @scheduleNoEntries.
  ///
  /// In en, this message translates to:
  /// **'No events, meals, or sleep logged for this day.'**
  String get scheduleNoEntries;

  /// No description provided for @mealSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Find dishes'**
  String get mealSearchTitle;

  /// No description provided for @mealSearchDescription.
  ///
  /// In en, this message translates to:
  /// **'Search recipes and view ingredients and steps in the app.'**
  String get mealSearchDescription;

  /// No description provided for @mealSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search chicken, pasta, salad...'**
  String get mealSearchHint;

  /// No description provided for @mealSearchResultsFor.
  ///
  /// In en, this message translates to:
  /// **'Results for \"{query}\"'**
  String mealSearchResultsFor(String query);

  /// No description provided for @mealPopularDishes.
  ///
  /// In en, this message translates to:
  /// **'Popular dishes'**
  String get mealPopularDishes;

  /// No description provided for @mealUnableToLoadDishes.
  ///
  /// In en, this message translates to:
  /// **'Unable to load dishes'**
  String get mealUnableToLoadDishes;

  /// No description provided for @mealNoDishesFound.
  ///
  /// In en, this message translates to:
  /// **'No dishes found. Try another search.'**
  String get mealNoDishesFound;

  /// No description provided for @mealEnterDishName.
  ///
  /// In en, this message translates to:
  /// **'Enter a dish name and tap Search on your keyboard.'**
  String get mealEnterDishName;

  /// No description provided for @mealUnableToLog.
  ///
  /// In en, this message translates to:
  /// **'Unable to log meal: {error}'**
  String mealUnableToLog(String error);

  /// No description provided for @mealEnterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get mealEnterValidNumber;

  /// No description provided for @mealLogFavorite.
  ///
  /// In en, this message translates to:
  /// **'Log favorite'**
  String get mealLogFavorite;

  /// No description provided for @mealUnableToLogFavorite.
  ///
  /// In en, this message translates to:
  /// **'Unable to log favorite: {error}'**
  String mealUnableToLogFavorite(String error);

  /// No description provided for @mealEditBeforeLogging.
  ///
  /// In en, this message translates to:
  /// **'Edit before logging'**
  String get mealEditBeforeLogging;

  /// No description provided for @mealSavedToProfile.
  ///
  /// In en, this message translates to:
  /// **'Saved to profile'**
  String get mealSavedToProfile;

  /// No description provided for @mealServingCount.
  ///
  /// In en, this message translates to:
  /// **'{count} serving'**
  String mealServingCount(int count);

  /// No description provided for @mealProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get mealProtein;

  /// No description provided for @mealCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get mealCarbs;

  /// No description provided for @mealFats.
  ///
  /// In en, this message translates to:
  /// **'Fats'**
  String get mealFats;

  /// No description provided for @mealUnableToLoadRecipeDetails.
  ///
  /// In en, this message translates to:
  /// **'Unable to load recipe details'**
  String get mealUnableToLoadRecipeDetails;

  /// No description provided for @mealFavoriteBerryYogurtBowl.
  ///
  /// In en, this message translates to:
  /// **'Berry yogurt bowl'**
  String get mealFavoriteBerryYogurtBowl;

  /// No description provided for @mealFavoriteSalmonBowl.
  ///
  /// In en, this message translates to:
  /// **'Salmon bowl'**
  String get mealFavoriteSalmonBowl;

  /// No description provided for @mealFavoriteChickenBowl.
  ///
  /// In en, this message translates to:
  /// **'Chicken bowl'**
  String get mealFavoriteChickenBowl;

  /// No description provided for @homeHydrationReminder.
  ///
  /// In en, this message translates to:
  /// **'Hydration reminder'**
  String get homeHydrationReminder;

  /// No description provided for @homeHydrationGoalReached.
  ///
  /// In en, this message translates to:
  /// **'Great job — goal reached!'**
  String get homeHydrationGoalReached;

  /// No description provided for @homeHydrationDrinkMore.
  ///
  /// In en, this message translates to:
  /// **'Drink {liters}L more today'**
  String homeHydrationDrinkMore(String liters);

  /// No description provided for @homeHydrationLoggedOf.
  ///
  /// In en, this message translates to:
  /// **'{current}L of {target}L logged'**
  String homeHydrationLoggedOf(String current, String target);

  /// No description provided for @homeMealCapture.
  ///
  /// In en, this message translates to:
  /// **'Meal capture'**
  String get homeMealCapture;

  /// No description provided for @homeReadyToLog.
  ///
  /// In en, this message translates to:
  /// **'Ready to log?'**
  String get homeReadyToLog;

  /// No description provided for @homeMealCaptureOptions.
  ///
  /// In en, this message translates to:
  /// **'Manual, preferences, or favorites'**
  String get homeMealCaptureOptions;

  /// No description provided for @homePrefsShort.
  ///
  /// In en, this message translates to:
  /// **'Prefs'**
  String get homePrefsShort;

  /// No description provided for @homePersonalNutritionProgram.
  ///
  /// In en, this message translates to:
  /// **'Personal Nutrition Program'**
  String get homePersonalNutritionProgram;

  /// No description provided for @homeSchoolSportProgram.
  ///
  /// In en, this message translates to:
  /// **'{school} {sport} Program'**
  String homeSchoolSportProgram(String school, String sport);

  /// No description provided for @homeSportNutritionProgram.
  ///
  /// In en, this message translates to:
  /// **'{sport} Nutrition Program'**
  String homeSportNutritionProgram(String sport);

  /// No description provided for @homeNoSleepLoggedWeek.
  ///
  /// In en, this message translates to:
  /// **'No sleep logged yet this week.'**
  String get homeNoSleepLoggedWeek;

  /// No description provided for @homeSleepWeekAvg.
  ///
  /// In en, this message translates to:
  /// **'{avg} avg • {logged} of 7 days logged'**
  String homeSleepWeekAvg(String avg, int logged);

  /// No description provided for @homeFailedLoadWeeklyFuel.
  ///
  /// In en, this message translates to:
  /// **'Failed to load weekly fuel:\n{error}'**
  String homeFailedLoadWeeklyFuel(String error);

  /// No description provided for @homeNoMealsLoggedWeek.
  ///
  /// In en, this message translates to:
  /// **'No meals logged yet this week.'**
  String get homeNoMealsLoggedWeek;

  /// No description provided for @homeDaysLoggedCount.
  ///
  /// In en, this message translates to:
  /// **'{logged} of 7 days logged'**
  String homeDaysLoggedCount(int logged);

  /// No description provided for @homeTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get homeTotal;

  /// No description provided for @homeWeeklyTarget.
  ///
  /// In en, this message translates to:
  /// **'Weekly target'**
  String get homeWeeklyTarget;

  /// No description provided for @homeDailyAverage.
  ///
  /// In en, this message translates to:
  /// **'Daily average'**
  String get homeDailyAverage;

  /// No description provided for @homeDailyCalories.
  ///
  /// In en, this message translates to:
  /// **'Daily calories'**
  String get homeDailyCalories;

  /// No description provided for @homeDailyBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Daily breakdown'**
  String get homeDailyBreakdown;

  /// No description provided for @homeTodayDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Today • {date}'**
  String homeTodayDateLabel(String date);

  /// No description provided for @homeNoMealsLogged.
  ///
  /// In en, this message translates to:
  /// **'No meals logged'**
  String get homeNoMealsLogged;

  /// No description provided for @homeCaloriesProgress.
  ///
  /// In en, this message translates to:
  /// **'{current} / {target} kcal'**
  String homeCaloriesProgress(String current, String target);

  /// No description provided for @homeMacroSummary.
  ///
  /// In en, this message translates to:
  /// **'P {protein}g • C {carbs}g • F {fats}g'**
  String homeMacroSummary(String protein, String carbs, String fats);

  /// No description provided for @homeMealKcalProtein.
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal · {protein}g P'**
  String homeMealKcalProtein(String kcal, String protein);

  /// No description provided for @homeNextSession.
  ///
  /// In en, this message translates to:
  /// **'NEXT SESSION'**
  String get homeNextSession;

  /// No description provided for @homeManualLog.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get homeManualLog;

  /// No description provided for @homeCaloriesOfTarget.
  ///
  /// In en, this message translates to:
  /// **'/ {target} kcal'**
  String homeCaloriesOfTarget(String target);

  /// No description provided for @scanMealSaved.
  ///
  /// In en, this message translates to:
  /// **'Meal saved to your log'**
  String get scanMealSaved;

  /// No description provided for @scanUnableAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Unable to analyze meal photo: {error}'**
  String scanUnableAnalyze(String error);

  /// No description provided for @scanUnablePickImage.
  ///
  /// In en, this message translates to:
  /// **'Unable to pick image: {error}'**
  String scanUnablePickImage(String error);

  /// No description provided for @scanTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get scanTakePhoto;

  /// No description provided for @scanTakePhotoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use your camera to scan a meal'**
  String get scanTakePhotoSubtitle;

  /// No description provided for @scanPhotoLibrary.
  ///
  /// In en, this message translates to:
  /// **'Photo library'**
  String get scanPhotoLibrary;

  /// No description provided for @scanPhotoLibrarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose an existing picture'**
  String get scanPhotoLibrarySubtitle;

  /// No description provided for @scanMeal.
  ///
  /// In en, this message translates to:
  /// **'Scan meal'**
  String get scanMeal;

  /// No description provided for @scanPointAtFood.
  ///
  /// In en, this message translates to:
  /// **'Point at your food'**
  String get scanPointAtFood;

  /// No description provided for @scanTapToCapture.
  ///
  /// In en, this message translates to:
  /// **'Tap the shutter to scan your meal'**
  String get scanTapToCapture;

  /// No description provided for @scanCameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Camera unavailable. Use Photo to pick from your library.'**
  String get scanCameraUnavailable;

  /// No description provided for @scanAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing meal...'**
  String get scanAnalyzing;

  /// No description provided for @scanPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get scanPhoto;

  /// No description provided for @scanManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get scanManual;

  /// No description provided for @scanPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get scanPrevious;

  /// No description provided for @scanMealAdded.
  ///
  /// In en, this message translates to:
  /// **'Meal added to your log'**
  String get scanMealAdded;

  /// No description provided for @scanMealAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Meal analysis'**
  String get scanMealAnalysis;

  /// No description provided for @scanMealAnalysisSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review the AI estimate before saving to your log.'**
  String get scanMealAnalysisSubtitle;

  /// No description provided for @scanPreviousMeals.
  ///
  /// In en, this message translates to:
  /// **'Previous meals'**
  String get scanPreviousMeals;

  /// No description provided for @scanPreviousMealsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap a meal to log it again. Showing up to {count} recent meals.'**
  String scanPreviousMealsSubtitle(int count);

  /// No description provided for @scanNoMealsLogged.
  ///
  /// In en, this message translates to:
  /// **'No meals logged yet.'**
  String get scanNoMealsLogged;

  /// No description provided for @scanMealListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal · {protein}g protein'**
  String scanMealListSubtitle(String kcal, String protein);

  /// No description provided for @onboardingSleepReasonWakeTired.
  ///
  /// In en, this message translates to:
  /// **'You often wake up tired.'**
  String get onboardingSleepReasonWakeTired;

  /// No description provided for @onboardingSleepReasonBedtimeChanges.
  ///
  /// In en, this message translates to:
  /// **'Your bedtime changes a lot.'**
  String get onboardingSleepReasonBedtimeChanges;

  /// No description provided for @onboardingSleepReasonReminder.
  ///
  /// In en, this message translates to:
  /// **'A reminder could help you wind down.'**
  String get onboardingSleepReasonReminder;

  /// No description provided for @onboardingSleepReasonSteadierRoutine.
  ///
  /// In en, this message translates to:
  /// **'Sleep Mode can help you build a steadier routine.'**
  String get onboardingSleepReasonSteadierRoutine;

  /// No description provided for @profileEditPhoto.
  ///
  /// In en, this message translates to:
  /// **'Edit photo'**
  String get profileEditPhoto;

  /// No description provided for @mealTypeBreakfast.
  ///
  /// In en, this message translates to:
  /// **'BREAKFAST'**
  String get mealTypeBreakfast;

  /// No description provided for @mealTypeLunch.
  ///
  /// In en, this message translates to:
  /// **'LUNCH'**
  String get mealTypeLunch;

  /// No description provided for @mealTypeDinner.
  ///
  /// In en, this message translates to:
  /// **'DINNER'**
  String get mealTypeDinner;

  /// No description provided for @mealTypeSnack.
  ///
  /// In en, this message translates to:
  /// **'SNACK'**
  String get mealTypeSnack;

  /// No description provided for @notificationRemindersSection.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get notificationRemindersSection;

  /// No description provided for @notificationMealReminders.
  ///
  /// In en, this message translates to:
  /// **'Meal times'**
  String get notificationMealReminders;

  /// No description provided for @notificationBedtimeReminder.
  ///
  /// In en, this message translates to:
  /// **'Bedtime'**
  String get notificationBedtimeReminder;

  /// No description provided for @notificationWakeReminder.
  ///
  /// In en, this message translates to:
  /// **'Wake-up time'**
  String get notificationWakeReminder;

  /// No description provided for @notificationSleepTargetSection.
  ///
  /// In en, this message translates to:
  /// **'Sleep target'**
  String get notificationSleepTargetSection;

  /// No description provided for @notificationSleepTargetDescription.
  ///
  /// In en, this message translates to:
  /// **'NutriLens analyzes your profile and recent sleep history to recommend a personalized nightly sleep target.'**
  String get notificationSleepTargetDescription;

  /// No description provided for @notificationSleepTargetValue.
  ///
  /// In en, this message translates to:
  /// **'{hours} per night'**
  String notificationSleepTargetValue(String hours);

  /// No description provided for @notificationSleepTargetCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current target: {hours}'**
  String notificationSleepTargetCurrent(String hours);

  /// No description provided for @notificationSleepTargetRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh sleep target'**
  String get notificationSleepTargetRefresh;

  /// No description provided for @notificationSleepTargetApply.
  ///
  /// In en, this message translates to:
  /// **'Apply sleep target'**
  String get notificationSleepTargetApply;

  /// No description provided for @notificationSleepTargetApplied.
  ///
  /// In en, this message translates to:
  /// **'Sleep target updated'**
  String get notificationSleepTargetApplied;

  /// No description provided for @notificationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications in system settings to receive reminders.'**
  String get notificationPermissionRequired;

  /// No description provided for @unableToUpdateNotifications.
  ///
  /// In en, this message translates to:
  /// **'Unable to update notifications: {error}'**
  String unableToUpdateNotifications(String error);
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
