// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'NutriLens';

  @override
  String get languageLabel => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languageChinese => 'Chinese';

  @override
  String get languagePickerTitle => 'Language';

  @override
  String get cancel => 'Cancel';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get signOut => 'Sign out';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String comingSoon(String feature) {
    return '$feature coming soon';
  }

  @override
  String get profile => 'Profile';

  @override
  String get profileUnavailable => 'Profile unavailable';

  @override
  String unableToLoadProfile(Object error) {
    return 'Unable to load profile: $error';
  }

  @override
  String get noNameSet => 'No name set';

  @override
  String get phone => 'Phone';

  @override
  String get sport => 'Sport';

  @override
  String get height => 'Height';

  @override
  String get weight => 'Weight';

  @override
  String get trainingDays => 'Training days';

  @override
  String get sleepTarget => 'Sleep target';

  @override
  String get allergens => 'Allergens';

  @override
  String get restrictions => 'Restrictions';

  @override
  String get editProfileAndSettings => 'Edit profile & settings';

  @override
  String get guestCreateAccountTitle => 'Create an account';

  @override
  String get guestCreateAccountBody =>
      'Sign up to save your profile, nutrition goals, and training data.';

  @override
  String get guestAccountNotice =>
      'You are using a guest account without cloud sync. Profile editing is disabled until you create an account to save your data.';

  @override
  String get signOutTitle => 'Sign out?';

  @override
  String get signOutGuestBody =>
      'You haven\'t linked an email. Signing out may lose your data on this device.';

  @override
  String signOutAccountBody(String account) {
    return 'Sign out of $account?';
  }

  @override
  String get yourAccount => 'your account';

  @override
  String get deleteAccountTitle => 'Delete account?';

  @override
  String get deleteGuestAccountBody =>
      'This permanently deletes your guest account and all logged meals, sleep, and profile data on this device. This cannot be undone.';

  @override
  String deleteAccountBody(String account) {
    return 'This permanently deletes $account and all associated data. This cannot be undone.';
  }

  @override
  String get mealPreferencesDescription =>
      'Pick food styles and allergies so we can personalize your meal plan.';

  @override
  String unableToSavePreferences(String error) {
    return 'Unable to save preferences: $error';
  }

  @override
  String get unableToLoadProfileShort => 'Unable to load your profile.';

  @override
  String get saveAndRefreshMealPlan => 'Save & refresh meal plan';

  @override
  String get accountCreatedSuccessfully => 'Account created successfully';

  @override
  String get emailVerificationSent =>
      'Verification sent — check your inbox to confirm.';

  @override
  String get passwordUpdated => 'Password updated';

  @override
  String unableToUpdateAccessibilityMode(String error) {
    return 'Unable to update accessibility mode: $error';
  }

  @override
  String unableToUpdateSleepMode(String error) {
    return 'Unable to update Sleep Mode: $error';
  }

  @override
  String get modeSwitcher => 'Mode switcher';

  @override
  String get minimalTabs => 'Minimal tabs';

  @override
  String get minimalTabsDescription =>
      'Slim top tabs with an active underline.';

  @override
  String get classicPill => 'Classic pill';

  @override
  String get classicPillDescription => 'Original rounded segmented control.';

  @override
  String unableToUpdateModeSwitcher(String error) {
    return 'Unable to update mode switcher: $error';
  }

  @override
  String get select => 'Select';

  @override
  String get changeEmail => 'Change email';

  @override
  String get newEmail => 'New email';

  @override
  String get currentPassword => 'Current password';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get update => 'Update';

  @override
  String get newPassword => 'New password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get passwordMinCharacters => 'At least 6 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get sleepGreetingMorning => 'Good Morning';

  @override
  String get sleepGreetingAfternoon => 'Good Afternoon';

  @override
  String get sleepGreetingEvening => 'Good Evening';

  @override
  String get athlete => 'Athlete';

  @override
  String get logSleep => 'Log sleep';

  @override
  String get sleepSchedule => 'Sleep Schedule';

  @override
  String unableToSaveSleepSchedule(String error) {
    return 'Unable to save sleep schedule: $error';
  }

  @override
  String get sleepProfileUnavailableBody =>
      'We need your profile before planning sleep.';

  @override
  String get wakeTimePlanning => 'Wake-time planning';

  @override
  String get setSleepSchedule => 'Set your sleep schedule';

  @override
  String get wakeTimePlanningDescription =>
      'We use your usual bedtime and wake time to protect recovery before training and match days.';

  @override
  String get setSleepScheduleDescription =>
      'Add your usual bedtime and wake time so Sleep Mode can plan recovery and track sleep statistics.';

  @override
  String get bedtime => 'Bedtime';

  @override
  String get wakeTime => 'Wake time';

  @override
  String get add => 'Add';

  @override
  String get saveSleepSchedule => 'Save sleep schedule';

  @override
  String get targetSleep => 'Target sleep';

  @override
  String get tonightBedtime => 'Tonight bedtime';

  @override
  String earlierWakeSuggested(String event, String time) {
    return 'Earlier wake suggested for $event at $time.';
  }

  @override
  String get customBedtimeLimit => 'You can add up to 3 custom bedtime items.';

  @override
  String unableToSaveBedtimeItems(String error) {
    return 'Unable to save bedtime items: $error';
  }

  @override
  String get enterValidTime => 'Enter a valid time like 10:30 PM or 22:30.';

  @override
  String get addCustomBedtime => 'Add custom bedtime';

  @override
  String get editCustomBedtime => 'Edit custom bedtime';

  @override
  String get bedtimeHint => '10:30 PM or 22:30';

  @override
  String get pickTime => 'Pick time';

  @override
  String get save => 'Save';

  @override
  String sleepLoggedForDay(String duration, String day, String advice) {
    return 'Saved $duration for $day. $advice';
  }

  @override
  String sleepAppliedForDays(String duration, int count, String advice) {
    return 'Applied $duration to $count days. $advice';
  }

  @override
  String unableToLoadSleepSchedule(String error) {
    return 'Unable to load sleep schedule:\n$error';
  }

  @override
  String get sleepScheduleUnavailable => 'Sleep schedule unavailable';

  @override
  String get sleepScheduleDescription =>
      'Pick a day, enter hours and minutes, then save one day or apply the same sleep duration for the next week.';

  @override
  String get hours => 'Hours';

  @override
  String get minutes => 'Minutes';

  @override
  String selectedDuration(String duration) {
    return 'Selected duration: $duration';
  }

  @override
  String targetDuration(String duration) {
    return 'Target $duration';
  }

  @override
  String get presetBedtimes => 'Preset bedtimes';

  @override
  String customBedtimeItems(int count, int max) {
    return 'Custom bedtime items ($count/$max)';
  }

  @override
  String get noCustomBedtimeItems =>
      'No custom bedtime items yet. Add up to 3.';

  @override
  String get editTime => 'Edit time';

  @override
  String get delete => 'Delete';

  @override
  String bedtimeItemsDescription(String time) {
    return 'Bedtime items use wake time $time to calculate your sleep duration.';
  }

  @override
  String get saveDay => 'Save day';

  @override
  String get applyNextSevenDays => 'Apply next 7 days';

  @override
  String get automaticTrackingStatus => 'Automatic tracking status';

  @override
  String get automaticTrackingDescription =>
      'Clock-only background tracking is not reliable on iOS/Android due to background limits. Use this planner for manual scheduling and keep health sync as a future auto option.';

  @override
  String get today => 'Today';

  @override
  String get mondayShort => 'Mon';

  @override
  String get tuesdayShort => 'Tue';

  @override
  String get wednesdayShort => 'Wed';

  @override
  String get thursdayShort => 'Thu';

  @override
  String get fridayShort => 'Fri';

  @override
  String get saturdayShort => 'Sat';

  @override
  String get sundayShort => 'Sun';

  @override
  String get sleepDurationInvalid =>
      'Enter valid hours and minutes (0–59 for minutes).';

  @override
  String get sleepDurationRange =>
      'Sleep duration should be between 2 and 16 hours.';

  @override
  String sleepTotal(String duration) {
    return 'Total: $duration';
  }

  @override
  String sleepTargetHours(String hours) {
    return 'Target: ${hours}h';
  }

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get saveSleep => 'Save sleep';

  @override
  String get sleepCheckInDescription =>
      'How long did you sleep? Enter hours and minutes, or skip for now.';

  @override
  String sleepLogged(String duration, String advice) {
    return 'Logged $duration. $advice';
  }

  @override
  String unableToSaveSleepLog(String error) {
    return 'Unable to save sleep log: $error';
  }

  @override
  String get recoveryAhead => 'Recovery is ahead';

  @override
  String sleepAboveTarget(String slept, String target) {
    return 'You slept $slept, above your ${target}h target.';
  }

  @override
  String sleepConsistencyAdvice(String bedtime, String wakeTime) {
    return 'Keep bedtime near $bedtime and wake around $wakeTime to stay consistent.';
  }

  @override
  String get onTarget => 'On target';

  @override
  String sleepMatchesTarget(String slept, String target) {
    return 'You slept $slept, matching your ${target}h goal.';
  }

  @override
  String sleepRhythmAdvice(String bedtime, String wakeTime) {
    return 'Stay on rhythm with bedtime around $bedtime and wake around $wakeTime.';
  }

  @override
  String get sleepNeedsBoost => 'Sleep needs a boost';

  @override
  String sleepBelowTarget(String deficit, String target) {
    return 'You are about ${deficit}h under your ${target}h target.';
  }

  @override
  String sleepRecoveryAdvice(
    String bedtime,
    String wakeTime,
    String eventNote,
  ) {
    return 'Tonight, aim for bedtime near $bedtime so you can wake at $wakeTime with better recovery.$eventNote';
  }

  @override
  String earlierWakeRecommendation(String event, String time) {
    return 'An earlier wake is suggested before $event at $time.';
  }

  @override
  String get authCreateTitle => 'Create your account';

  @override
  String get authWelcomeBack => 'Welcome back';

  @override
  String get authCreate => 'Create';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authMealPreferences => 'Meal preferences';

  @override
  String get authMealPreferencesHint =>
      'Tell us what you like and what to avoid after you sign up.';

  @override
  String get authMealsPerDay => 'Meals per day';

  @override
  String get authMealsPerDayHint => 'How many meals do you usually eat?';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authContinueAsGuest => 'Continue as guest';

  @override
  String get authLegalAgreement =>
      'I agree to the Privacy Policy and Terms & Conditions';

  @override
  String get authPrivacyPolicy => 'Privacy Policy';

  @override
  String get authTermsAndConditions => 'Terms & Conditions';

  @override
  String get authValidationLegalRequired =>
      'Accept the Privacy Policy and Terms & Conditions to continue';

  @override
  String get authValidationEmailRequired => 'Enter an email';

  @override
  String get authValidationEmailInvalid => 'Enter a valid email';

  @override
  String get authValidationPasswordMin =>
      'Password must be at least 6 characters';

  @override
  String get authErrorWeakPassword => 'Use a stronger password.';

  @override
  String get authErrorEmailInUse => 'That email already has an account.';

  @override
  String get authErrorInvalidEmail => 'Enter a valid email address.';

  @override
  String get authErrorWrongCredentials => 'Email or password is incorrect.';

  @override
  String get authErrorNetwork => 'Check your connection and try again.';

  @override
  String get authErrorGeneric => 'Authentication failed. Try again.';

  @override
  String get mealStylesTitle => 'Food styles you like';

  @override
  String get mealStyleHighProtein => 'High protein';

  @override
  String get mealStyleMediterranean => 'Mediterranean';

  @override
  String get mealStyleVegetarian => 'Vegetarian';

  @override
  String get mealStyleVegan => 'Vegan';

  @override
  String get mealStyleGlutenFree => 'Gluten-free';

  @override
  String get mealStyleLowCarb => 'Low carb';

  @override
  String get mealStyleBalanced => 'Balanced';

  @override
  String get mealStyleAsianInspired => 'Asian-inspired';

  @override
  String get mealStyleOthers => 'Others';

  @override
  String get mealStyleOtherLabel => 'OTHER FOOD STYLE';

  @override
  String get mealStyleOtherHelper => 'Describe your preferred food style';

  @override
  String get allergensLabel => 'ALLERGENS';

  @override
  String get allergensHelper =>
      'Use commas or new lines. Example: peanuts, shellfish';

  @override
  String get restrictionsLabel => 'DIETARY RESTRICTIONS';

  @override
  String get restrictionsHelper =>
      'Use commas or new lines. Example: halal, dairy-free';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get sectionAccount => 'Account';

  @override
  String get sectionPersonal => 'Personal';

  @override
  String get sectionAthlete => 'Athlete';

  @override
  String get sectionNutritionGoals => 'Nutrition Goals';

  @override
  String get sectionDietary => 'Dietary';

  @override
  String get sectionDisplay => 'Display';

  @override
  String get sectionApp => 'App';

  @override
  String get displayName => 'Display name';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get email => 'Email';

  @override
  String get notLinked => 'Not linked';

  @override
  String get createAccount => 'Create account';

  @override
  String get changePassword => 'Change password';

  @override
  String get gender => 'Gender';

  @override
  String get selectGender => 'Select gender';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderMale => 'Male';

  @override
  String get genderNonBinary => 'Non-binary';

  @override
  String get genderPreferNotToSay => 'Prefer not to say';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get birthYear => 'Birth year';

  @override
  String get enterValidYear => 'Enter a valid year';

  @override
  String get heightCm => 'Height (cm)';

  @override
  String get weightKg => 'Weight (kg)';

  @override
  String get primarySport => 'Primary sport';

  @override
  String get noSportSelected => 'No sport selected';

  @override
  String get school => 'School';

  @override
  String get graduationYear => 'Graduation year';

  @override
  String get trainingDaysPerWeek => 'Training days per week';

  @override
  String get selectTrainingDays => 'Select training days';

  @override
  String trainingDaysCount(int count) {
    return '$count days';
  }

  @override
  String get activityLevel => 'Activity level';

  @override
  String get selectActivityLevel => 'Select activity level';

  @override
  String get activityLow => 'Low';

  @override
  String get activityModerate => 'Moderate';

  @override
  String get activityHigh => 'High';

  @override
  String get activityVeryHigh => 'Very high';

  @override
  String get caloriesKcal => 'Calories (kcal)';

  @override
  String get proteinG => 'Protein (g)';

  @override
  String get carbsG => 'Carbs (g)';

  @override
  String get fatsG => 'Fats (g)';

  @override
  String get hydrationL => 'Hydration (L)';

  @override
  String get sleepHrs => 'Sleep (hrs)';

  @override
  String get fieldRequired => 'Required';

  @override
  String get enterNumber => 'Enter a number';

  @override
  String get accessibilityMode => 'Accessibility mode';

  @override
  String get textSize => 'Text size';

  @override
  String get themeColors => 'Theme colors';

  @override
  String get textScaleSmall => 'Small';

  @override
  String get textScaleMedium => 'Medium';

  @override
  String get textScaleLarge => 'Large';

  @override
  String get textScaleExtraLarge => 'Extra large';

  @override
  String get textScaleSmallDesc => 'Compact labels and body text.';

  @override
  String get textScaleMediumDesc => 'Default app text size.';

  @override
  String get textScaleLargeDesc => 'Easier to read on most screens.';

  @override
  String get textScaleExtraLargeDesc => 'Maximum readability.';

  @override
  String get themeClassic => 'Classic lime';

  @override
  String get themeOcean => 'Ocean blue';

  @override
  String get themeSunset => 'Sunset coral';

  @override
  String get themeForest => 'Forest green';

  @override
  String get themePaletteDesc => 'Accent and highlight colors across the app.';

  @override
  String get sleepMode => 'Sleep Mode';

  @override
  String get notifications => 'Notifications';

  @override
  String get units => 'Units';

  @override
  String get changesSaved => 'Changes saved';

  @override
  String failedToSave(String error) {
    return 'Failed to save: $error';
  }

  @override
  String unableToLoadSettings(String error) {
    return 'Unable to load settings: $error';
  }

  @override
  String unableToUpdateTextSize(String error) {
    return 'Unable to update text size: $error';
  }

  @override
  String unableToUpdateTheme(String error) {
    return 'Unable to update theme: $error';
  }

  @override
  String unableToUpdateLanguage(String error) {
    return 'Unable to update language: $error';
  }

  @override
  String unableToSignOut(String error) {
    return 'Unable to sign out: $error';
  }

  @override
  String unableToDeleteAccount(String error) {
    return 'Unable to delete account: $error';
  }

  @override
  String get deleteAccountReauthTitle => 'Confirm your password';

  @override
  String get deleteAccountReauthBody =>
      'For your security, enter your password to permanently delete this account.';

  @override
  String get deleteAccountReauthPassword => 'Password';

  @override
  String get authErrorRequiresRecentLogin =>
      'For your security, confirm your password and try again.';

  @override
  String failedToInitializeApp(String error) {
    return 'Failed to initialize the app:\n$error';
  }

  @override
  String failedToLoadAccount(String error) {
    return 'Failed to load account:\n$error';
  }

  @override
  String get continueButton => 'Continue';

  @override
  String get tryAgain => 'Try again';

  @override
  String get finishSetup => 'Finish setup';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get maybe => 'Maybe';

  @override
  String get required => 'Required';

  @override
  String get enterPositiveNumber => 'Enter a positive number';

  @override
  String get navHome => 'Home';

  @override
  String get navMeals => 'Meals';

  @override
  String get navSchedule => 'Schedule';

  @override
  String get navProfile => 'Profile';

  @override
  String get navSleep => 'Sleep';

  @override
  String get navLog => 'Log';

  @override
  String get modeMealTracking => 'Meal Tracking';

  @override
  String get modeSleep => 'Sleep';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get sportTennis => 'Tennis';

  @override
  String get sportBasketball => 'Basketball';

  @override
  String get sportSoccer => 'Soccer';

  @override
  String get sportAmericanFootball => 'American Football';

  @override
  String get sportBaseball => 'Baseball';

  @override
  String get sportSoftball => 'Softball';

  @override
  String get sportVolleyball => 'Volleyball';

  @override
  String get sportSwimming => 'Swimming';

  @override
  String get sportTrackAndField => 'Track & Field';

  @override
  String get sportCrossCountry => 'Cross Country';

  @override
  String get sportWrestling => 'Wrestling';

  @override
  String get sportLacrosse => 'Lacrosse';

  @override
  String get sportHockey => 'Hockey';

  @override
  String get sportGolf => 'Golf';

  @override
  String get sportGymnastics => 'Gymnastics';

  @override
  String get sportCycling => 'Cycling';

  @override
  String get sportOther => 'Other';

  @override
  String get sportNone => 'None';

  @override
  String get onboardingWelcomeTitle => 'NutriLens';

  @override
  String get onboardingWelcomeSubtitle => 'Fuel smarter. Train harder.';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get onboardingYourName => 'Your name';

  @override
  String get onboardingFullNameLabel => 'FULL NAME';

  @override
  String get onboardingAboutSport => 'About your sport';

  @override
  String get onboardingPlaySportQuestion => 'Do you currently play a sport?';

  @override
  String get onboardingPlaySportYes => 'Yes, I play a sport';

  @override
  String get onboardingPlaySportNo => 'No, not currently';

  @override
  String get onboardingYourSportLabel => 'YOUR SPORT';

  @override
  String get onboardingEnterSport => 'Enter your sport';

  @override
  String get onboardingNoSportTargets =>
      'No problem — we\'ll estimate your nutrition targets from your body metrics.';

  @override
  String get onboardingChooseOption => 'Choose an option above to continue.';

  @override
  String get onboardingYourSchool => 'Your school';

  @override
  String get onboardingSchoolNameLabel => 'SCHOOL NAME (OPTIONAL)';

  @override
  String get onboardingGraduationYearLabel => 'GRADUATION YEAR (OPTIONAL)';

  @override
  String get onboardingEnterFourDigitYear => 'Enter a 4-digit year';

  @override
  String get onboardingSleepCheck => 'Sleep check';

  @override
  String get onboardingSleepCheckIntro =>
      'Three quick questions. Tap a choice to select it — tap again to clear.';

  @override
  String get sleepQuestionWakeTired => 'Do you wake up tired?';

  @override
  String get sleepQuestionWakeTiredHint => 'Think about a typical school week.';

  @override
  String get sleepQuestionBedtimeChanges => 'Does your bedtime change a lot?';

  @override
  String get sleepQuestionBedtimeChangesHint =>
      'Games, practice, or homework can push sleep later.';

  @override
  String get sleepQuestionReminder => 'Would a bedtime reminder help?';

  @override
  String get sleepQuestionReminderHint =>
      'A gentle nudge before your target sleep time.';

  @override
  String get sleepAnswerNotOften => 'Not often';

  @override
  String get sleepAnswerSometimes => 'Sometimes';

  @override
  String get sleepAnswerOften => 'Often';

  @override
  String get onboardingUseSleepMode => 'Use Sleep Mode';

  @override
  String get onboardingSleepRecommended => 'We recommend Sleep Mode';

  @override
  String get onboardingSleepOptional => 'Sleep Mode is optional';

  @override
  String get onboardingSleepRecommendation =>
      'Based on your answers, Sleep Mode could help you recover.';

  @override
  String get onboardingSleepOptionalBody =>
      'You can turn it on later in Settings if your schedule changes.';

  @override
  String get onboardingBodyMetrics => 'Your body metrics';

  @override
  String get onboardingBodyMetricsHint =>
      'We use height and weight to estimate your daily nutrition targets.';

  @override
  String get onboardingHeightLabel => 'HEIGHT (CM)';

  @override
  String get onboardingWeightLabel => 'WEIGHT (KG)';

  @override
  String onboardingMaximumHeight(int height) {
    return 'Maximum height is $height cm';
  }

  @override
  String onboardingMaximumWeight(int weight) {
    return 'Maximum weight is $weight kg';
  }

  @override
  String get onboardingNutritionTargets => 'Daily nutrition targets';

  @override
  String get onboardingTargetsFromSport =>
      'We estimated these from your sport, height, and weight. You can adjust.';

  @override
  String get onboardingTargetsFromMetrics =>
      'We estimated these from your height and weight. You can adjust.';

  @override
  String get homeTodayMealPlan => 'Today\'s Meal Plan';

  @override
  String get homeNoMealsPlanned => 'No meals planned for today yet.';

  @override
  String get homeMealPlanUnavailable => 'Meal plan is unavailable right now.';

  @override
  String get homeMealPlanRefreshed =>
      'Meal plan refreshed with your preferences';

  @override
  String homeUnableToSaveHydration(String error) {
    return 'Unable to save hydration: $error';
  }

  @override
  String homeFailedToLoadData(String error) {
    return 'Failed to load home data:\n$error';
  }

  @override
  String get homeThisWeeksFuel => 'This week\'s fuel';

  @override
  String get homeTodayFuel => 'Today\'s fuel';

  @override
  String get homeHydration => 'Hydration';

  @override
  String get homeProgramTitle => 'Your program';

  @override
  String get homeProgramSubtitle => 'Stay consistent and fuel your training.';

  @override
  String get homeWeeklySleep => 'Weekly sleep';

  @override
  String get homeLogged => 'Logged';

  @override
  String homeTargetHours(String hours) {
    return 'Target ${hours}h';
  }

  @override
  String get scheduleTitle => 'Schedule';

  @override
  String get scheduleTimeline => 'Timeline';

  @override
  String get scheduleMeals => 'Meals';

  @override
  String get scheduleEvents => 'Events';

  @override
  String get scheduleSleep => 'Sleep';

  @override
  String get scheduleLogSleep => 'Log sleep';

  @override
  String get scheduleLogSleepForDay => 'Log sleep for this day';

  @override
  String scheduleNewMealReady(String meal) {
    return 'New $meal meal ready';
  }

  @override
  String scheduleMealGenerationFailed(String error) {
    return 'Could not generate a new meal: $error';
  }

  @override
  String get scheduleDeleteEventTitle => 'Delete event?';

  @override
  String scheduleDeleteEventBody(String title) {
    return 'Delete \"$title\" from your schedule?';
  }

  @override
  String get scheduleDeleteEventFailed => 'Failed to delete event.';

  @override
  String get scheduleEventDeleted => 'Event deleted.';

  @override
  String get scheduleNoItems => 'Nothing scheduled for this day.';

  @override
  String get scheduleCreateEvent => 'Create event';

  @override
  String get scheduleEventCreated => 'Event created';

  @override
  String get scheduleEventType => 'Event type';

  @override
  String get scheduleEventTitle => 'Title';

  @override
  String get scheduleDate => 'Date';

  @override
  String get scheduleTime => 'Time';

  @override
  String get scheduleSubtitle => 'Subtitle';

  @override
  String get scheduleLocation => 'Location';

  @override
  String get scheduleBadge => 'Badge';

  @override
  String get scheduleFuelingHints => 'Fueling hints';

  @override
  String get scheduleTiming => 'Timing';

  @override
  String get scheduleHint => 'Hint';

  @override
  String get scheduleFilterAll => 'All';

  @override
  String get scheduleFilterMeals => 'Meals';

  @override
  String get scheduleFilterEvents => 'Events';

  @override
  String get scheduleFilterSleep => 'Sleep';

  @override
  String get scheduleEventPractice => 'Practice';

  @override
  String get scheduleEventGame => 'Game';

  @override
  String get scheduleEventWorkout => 'Workout';

  @override
  String get scheduleEventOther => 'Other';

  @override
  String get scheduleEventMeal => 'Meal';

  @override
  String get scheduleEventTraining => 'Training';

  @override
  String get scheduleEventMatch => 'Match';

  @override
  String get mealsTitle => 'Meals';

  @override
  String get mealsLogMeal => 'Log meal';

  @override
  String get mealsMealLogged => 'Meal logged successfully';

  @override
  String get mealsMealName => 'Meal name';

  @override
  String get mealsCalories => 'Calories kcal';

  @override
  String get mealsProtein => 'Protein';

  @override
  String get mealsCarbs => 'Carbs';

  @override
  String get mealsFats => 'Fats';

  @override
  String get mealsSaveMeal => 'Save meal';

  @override
  String get mealsFavorites => 'Favorites';

  @override
  String mealsFavoriteLogged(String title) {
    return '$title logged';
  }

  @override
  String get mealsRecipeDetails => 'Recipe details';

  @override
  String get mealsIngredients => 'Ingredients';

  @override
  String get mealsInstructions => 'Instructions';

  @override
  String mealsMinutes(int count) {
    return '$count min';
  }

  @override
  String mealsServings(int count) {
    return '$count servings';
  }

  @override
  String get sleepDashboardTitle => 'Sleep Schedule';

  @override
  String get sleepProfileUnavailable => 'Profile unavailable';

  @override
  String get sleepBedtime => 'Bedtime';

  @override
  String get sleepWakeTime => 'Wake time';

  @override
  String get sleepSaveSchedule => 'Save sleep schedule';

  @override
  String sleepUnableToSaveSchedule(String error) {
    return 'Unable to save sleep schedule: $error';
  }

  @override
  String get sleepTargetSleep => 'Target sleep';

  @override
  String get sleepTonightBedtime => 'Tonight bedtime';

  @override
  String get sleepRecoveryAhead => 'Recovery is ahead';

  @override
  String get sleepOnTarget => 'On target';

  @override
  String sleepUnableToSaveLog(String error) {
    return 'Unable to save sleep log: $error';
  }

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileSignOutTitle => 'Sign out?';

  @override
  String get profileSignOutBody => 'Are you sure you want to sign out?';

  @override
  String get profileDeleteAccountTitle => 'Delete account?';

  @override
  String get profileDeleteGuestBody =>
      'This permanently deletes your guest account and all logged meals, sleep, and profile data on this device. This cannot be undone.';

  @override
  String profileDeleteAccountBody(String email) {
    return 'This permanently deletes $email and all associated data. This cannot be undone.';
  }

  @override
  String get profileAccountCreated => 'Account created successfully';

  @override
  String get profileVerificationSent =>
      'Verification sent — check your inbox to confirm.';

  @override
  String get profilePasswordUpdated => 'Password updated';

  @override
  String get profileCreateAccount => 'Create account';

  @override
  String get profileLinkEmail => 'Link email';

  @override
  String get profileGuestNotice =>
      'Create an account to back up your data and use it across devices.';

  @override
  String get profileSaveRefreshMealPlan => 'Save & refresh meal plan';

  @override
  String profileUnableToUpdateAccessibility(String error) {
    return 'Unable to update accessibility mode: $error';
  }

  @override
  String profileUnableToUpdateSleepMode(String error) {
    return 'Unable to update Sleep Mode: $error';
  }

  @override
  String get profileModeSwitcher => 'Mode switcher';

  @override
  String get profileMinimalTabs => 'Minimal tabs';

  @override
  String get profileMinimalTabsDescription =>
      'Slim top tabs with an active underline.';

  @override
  String get profileClassicPill => 'Classic pill';

  @override
  String get profileClassicPillDescription =>
      'Original rounded segmented control.';

  @override
  String profileUnableToUpdateModeSwitcher(String error) {
    return 'Unable to update mode switcher: $error';
  }

  @override
  String get scheduleMealPlan => 'Meal plan';

  @override
  String get scheduleNoMealsPlanned => 'No meals planned for this day.';

  @override
  String get scheduleMealPlanUnavailable =>
      'Meal plan is unavailable right now.';

  @override
  String get scheduleGenerating => 'Generating...';

  @override
  String get scheduleNewMeal => 'New meal';

  @override
  String get scheduleSleepLogged => 'Sleep logged';

  @override
  String get scheduleThisWeek => 'This week';

  @override
  String get scheduleFullMonth => 'Full month';

  @override
  String get scheduleTodaysMatch => 'Today\'s match';

  @override
  String get scheduleAddTitle => 'Add title';

  @override
  String get scheduleAddSubtitle => 'Add subtitle';

  @override
  String get scheduleAddLocation => 'Add location';

  @override
  String get scheduleAddBadge => 'Add badge';

  @override
  String get scheduleAddHints => 'Add hints';

  @override
  String scheduleHintCount(int count) {
    return '$count hints';
  }

  @override
  String get scheduleTimingHint => '2h before';

  @override
  String get scheduleHydrate => 'Hydrate';

  @override
  String get scheduleRemoveHint => 'Remove hint';

  @override
  String get scheduleLoadFailed => 'Failed to load schedule.';

  @override
  String get scheduleLogSleepEmpty => 'No sleep logged for this day.';

  @override
  String get scheduleNoEvents => 'No events scheduled for this day.';

  @override
  String get scheduleNoMeals => 'No logged meals for this day.';

  @override
  String get scheduleNoEntries =>
      'No events, meals, or sleep logged for this day.';

  @override
  String get mealSearchTitle => 'Find dishes';

  @override
  String get mealSearchDescription =>
      'Search recipes and view ingredients and steps in the app.';

  @override
  String get mealSearchHint => 'Search chicken, pasta, salad...';

  @override
  String mealSearchResultsFor(String query) {
    return 'Results for \"$query\"';
  }

  @override
  String get mealPopularDishes => 'Popular dishes';

  @override
  String get mealUnableToLoadDishes => 'Unable to load dishes';

  @override
  String get mealNoDishesFound => 'No dishes found. Try another search.';

  @override
  String get mealEnterDishName =>
      'Enter a dish name and tap Search on your keyboard.';

  @override
  String mealUnableToLog(String error) {
    return 'Unable to log meal: $error';
  }

  @override
  String get mealEnterValidNumber => 'Enter a valid number';

  @override
  String get mealLogFavorite => 'Log favorite';

  @override
  String mealUnableToLogFavorite(String error) {
    return 'Unable to log favorite: $error';
  }

  @override
  String get mealEditBeforeLogging => 'Edit before logging';

  @override
  String get mealSavedToProfile => 'Saved to profile';

  @override
  String mealServingCount(int count) {
    return '$count serving';
  }

  @override
  String get mealProtein => 'Protein';

  @override
  String get mealCarbs => 'Carbs';

  @override
  String get mealFats => 'Fats';

  @override
  String get mealUnableToLoadRecipeDetails => 'Unable to load recipe details';

  @override
  String get mealFavoriteBerryYogurtBowl => 'Berry yogurt bowl';

  @override
  String get mealFavoriteSalmonBowl => 'Salmon bowl';

  @override
  String get mealFavoriteChickenBowl => 'Chicken bowl';

  @override
  String get homeHydrationReminder => 'Hydration reminder';

  @override
  String get homeHydrationGoalReached => 'Great job — goal reached!';

  @override
  String homeHydrationDrinkMore(String liters) {
    return 'Drink ${liters}L more today';
  }

  @override
  String homeHydrationLoggedOf(String current, String target) {
    return '${current}L of ${target}L logged';
  }

  @override
  String get homeMealCapture => 'Meal capture';

  @override
  String get homeReadyToLog => 'Ready to log?';

  @override
  String get homeMealCaptureOptions => 'Manual, preferences, or favorites';

  @override
  String get homePrefsShort => 'Prefs';

  @override
  String get homePersonalNutritionProgram => 'Personal Nutrition Program';

  @override
  String homeSchoolSportProgram(String school, String sport) {
    return '$school $sport Program';
  }

  @override
  String homeSportNutritionProgram(String sport) {
    return '$sport Nutrition Program';
  }

  @override
  String get homeNoSleepLoggedWeek => 'No sleep logged yet this week.';

  @override
  String homeSleepWeekAvg(String avg, int logged) {
    return '$avg avg • $logged of 7 days logged';
  }

  @override
  String homeFailedLoadWeeklyFuel(String error) {
    return 'Failed to load weekly fuel:\n$error';
  }

  @override
  String get homeNoMealsLoggedWeek => 'No meals logged yet this week.';

  @override
  String homeDaysLoggedCount(int logged) {
    return '$logged of 7 days logged';
  }

  @override
  String get homeTotal => 'Total';

  @override
  String get homeWeeklyTarget => 'Weekly target';

  @override
  String get homeDailyAverage => 'Daily average';

  @override
  String get homeDailyCalories => 'Daily calories';

  @override
  String get homeDailyBreakdown => 'Daily breakdown';

  @override
  String homeTodayDateLabel(String date) {
    return 'Today • $date';
  }

  @override
  String get homeNoMealsLogged => 'No meals logged';

  @override
  String homeCaloriesProgress(String current, String target) {
    return '$current / $target kcal';
  }

  @override
  String homeMacroSummary(String protein, String carbs, String fats) {
    return 'P ${protein}g • C ${carbs}g • F ${fats}g';
  }

  @override
  String homeMealKcalProtein(String kcal, String protein) {
    return '$kcal kcal · ${protein}g P';
  }

  @override
  String get homeNextSession => 'NEXT SESSION';

  @override
  String get homeManualLog => 'Manual';

  @override
  String homeCaloriesOfTarget(String target) {
    return '/ $target kcal';
  }

  @override
  String get scanMealSaved => 'Meal saved to your log';

  @override
  String scanUnableAnalyze(String error) {
    return 'Unable to analyze meal photo: $error';
  }

  @override
  String scanUnablePickImage(String error) {
    return 'Unable to pick image: $error';
  }

  @override
  String get scanTakePhoto => 'Take photo';

  @override
  String get scanTakePhotoSubtitle => 'Use your camera to scan a meal';

  @override
  String get scanPhotoLibrary => 'Photo library';

  @override
  String get scanPhotoLibrarySubtitle => 'Choose an existing picture';

  @override
  String get scanMeal => 'Scan meal';

  @override
  String get scanPointAtFood => 'Point at your food';

  @override
  String get scanTapToCapture => 'Tap the shutter to scan your meal';

  @override
  String get scanCameraUnavailable =>
      'Camera unavailable. Use Photo to pick from your library.';

  @override
  String get scanAnalyzing => 'Analyzing meal...';

  @override
  String get scanPhoto => 'Photo';

  @override
  String get scanManual => 'Manual';

  @override
  String get scanPrevious => 'Previous';

  @override
  String get scanMealAdded => 'Meal added to your log';

  @override
  String get scanMealAnalysis => 'Meal analysis';

  @override
  String get scanMealAnalysisSubtitle =>
      'Review the AI estimate before saving to your log.';

  @override
  String get scanPreviousMeals => 'Previous meals';

  @override
  String scanPreviousMealsSubtitle(int count) {
    return 'Tap a meal to log it again. Showing up to $count recent meals.';
  }

  @override
  String get scanNoMealsLogged => 'No meals logged yet.';

  @override
  String scanMealListSubtitle(String kcal, String protein) {
    return '$kcal kcal · ${protein}g protein';
  }

  @override
  String get onboardingSleepReasonWakeTired => 'You often wake up tired.';

  @override
  String get onboardingSleepReasonBedtimeChanges =>
      'Your bedtime changes a lot.';

  @override
  String get onboardingSleepReasonReminder =>
      'A reminder could help you wind down.';

  @override
  String get onboardingSleepReasonSteadierRoutine =>
      'Sleep Mode can help you build a steadier routine.';

  @override
  String get profileEditPhoto => 'Edit photo';

  @override
  String get mealTypeBreakfast => 'BREAKFAST';

  @override
  String get mealTypeLunch => 'LUNCH';

  @override
  String get mealTypeDinner => 'DINNER';

  @override
  String get mealTypeSnack => 'SNACK';

  @override
  String get notificationRemindersSection => 'Reminders';

  @override
  String get notificationMealReminders => 'Meal times';

  @override
  String get notificationBedtimeReminder => 'Bedtime';

  @override
  String get notificationWakeReminder => 'Wake-up time';

  @override
  String get notificationSleepTargetSection => 'Sleep target';

  @override
  String get notificationSleepTargetDescription =>
      'NutriLens analyzes your profile and recent sleep history to recommend a personalized nightly sleep target.';

  @override
  String notificationSleepTargetValue(String hours) {
    return '$hours per night';
  }

  @override
  String notificationSleepTargetCurrent(String hours) {
    return 'Current target: $hours';
  }

  @override
  String get notificationSleepTargetRefresh => 'Refresh sleep target';

  @override
  String get notificationSleepTargetApply => 'Apply sleep target';

  @override
  String get notificationSleepTargetApplied => 'Sleep target updated';

  @override
  String get notificationPermissionRequired =>
      'Enable notifications in system settings to receive reminders.';

  @override
  String unableToUpdateNotifications(String error) {
    return 'Unable to update notifications: $error';
  }
}
