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
      'Tell us what you like and what to avoid before you sign in.';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authContinueAsGuest => 'Continue as guest';

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
  String failedToInitializeApp(String error) {
    return 'Failed to initialize the app:\n$error';
  }

  @override
  String failedToLoadAccount(String error) {
    return 'Failed to load account:\n$error';
  }
}
