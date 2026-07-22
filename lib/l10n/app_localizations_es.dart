// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'NutriLens';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageChinese => 'Chino';

  @override
  String get languagePickerTitle => 'Idioma';

  @override
  String get cancel => 'Cancelar';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String comingSoon(String feature) {
    return '$feature próximamente';
  }

  @override
  String get authCreateTitle => 'Crea tu cuenta';

  @override
  String get authWelcomeBack => 'Bienvenido de nuevo';

  @override
  String get authCreate => 'Crear';

  @override
  String get authSignIn => 'Iniciar sesión';

  @override
  String get authMealPreferences => 'Preferencias de comidas';

  @override
  String get authMealPreferencesHint =>
      'Cuéntanos qué te gusta y qué evitar antes de iniciar sesión.';

  @override
  String get authEmail => 'Correo electrónico';

  @override
  String get authPassword => 'Contraseña';

  @override
  String get authCreateAccount => 'Crear cuenta';

  @override
  String get authContinueAsGuest => 'Continuar como invitado';

  @override
  String get authValidationEmailRequired => 'Ingresa un correo electrónico';

  @override
  String get authValidationEmailInvalid =>
      'Ingresa un correo electrónico válido';

  @override
  String get authValidationPasswordMin =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get authErrorWeakPassword => 'Usa una contraseña más segura.';

  @override
  String get authErrorEmailInUse => 'Ese correo ya tiene una cuenta.';

  @override
  String get authErrorInvalidEmail => 'Ingresa un correo electrónico válido.';

  @override
  String get authErrorWrongCredentials =>
      'El correo o la contraseña son incorrectos.';

  @override
  String get authErrorNetwork => 'Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get authErrorGeneric => 'Error de autenticación. Inténtalo de nuevo.';

  @override
  String get mealStylesTitle => 'Estilos de comida que te gustan';

  @override
  String get mealStyleHighProtein => 'Alto en proteína';

  @override
  String get mealStyleMediterranean => 'Mediterránea';

  @override
  String get mealStyleVegetarian => 'Vegetariana';

  @override
  String get mealStyleVegan => 'Vegana';

  @override
  String get mealStyleGlutenFree => 'Sin gluten';

  @override
  String get mealStyleLowCarb => 'Baja en carbohidratos';

  @override
  String get mealStyleBalanced => 'Equilibrada';

  @override
  String get mealStyleAsianInspired => 'Inspirada en Asia';

  @override
  String get mealStyleOthers => 'Otros';

  @override
  String get mealStyleOtherLabel => 'OTRO ESTILO DE COMIDA';

  @override
  String get mealStyleOtherHelper => 'Describe tu estilo de comida preferido';

  @override
  String get allergensLabel => 'ALÉRGENOS';

  @override
  String get allergensHelper =>
      'Usa comas o saltos de línea. Ejemplo: cacahuetes, mariscos';

  @override
  String get restrictionsLabel => 'RESTRICCIONES DIETÉTICAS';

  @override
  String get restrictionsHelper =>
      'Usa comas o saltos de línea. Ejemplo: halal, sin lácteos';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get sectionAccount => 'Cuenta';

  @override
  String get sectionPersonal => 'Personal';

  @override
  String get sectionAthlete => 'Atleta';

  @override
  String get sectionNutritionGoals => 'Objetivos nutricionales';

  @override
  String get sectionDietary => 'Dieta';

  @override
  String get sectionDisplay => 'Pantalla';

  @override
  String get sectionApp => 'App';

  @override
  String get displayName => 'Nombre para mostrar';

  @override
  String get nameRequired => 'El nombre es obligatorio';

  @override
  String get email => 'Correo electrónico';

  @override
  String get notLinked => 'No vinculado';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get changePassword => 'Cambiar contraseña';

  @override
  String get gender => 'Género';

  @override
  String get selectGender => 'Seleccionar género';

  @override
  String get genderFemale => 'Femenino';

  @override
  String get genderMale => 'Masculino';

  @override
  String get genderNonBinary => 'No binario';

  @override
  String get genderPreferNotToSay => 'Prefiero no decirlo';

  @override
  String get phoneNumber => 'Número de teléfono';

  @override
  String get birthYear => 'Año de nacimiento';

  @override
  String get enterValidYear => 'Ingresa un año válido';

  @override
  String get heightCm => 'Altura (cm)';

  @override
  String get weightKg => 'Peso (kg)';

  @override
  String get primarySport => 'Deporte principal';

  @override
  String get noSportSelected => 'Ningún deporte seleccionado';

  @override
  String get school => 'Escuela';

  @override
  String get graduationYear => 'Año de graduación';

  @override
  String get trainingDaysPerWeek => 'Días de entrenamiento por semana';

  @override
  String get selectTrainingDays => 'Seleccionar días de entrenamiento';

  @override
  String trainingDaysCount(int count) {
    return '$count días';
  }

  @override
  String get activityLevel => 'Nivel de actividad';

  @override
  String get selectActivityLevel => 'Seleccionar nivel de actividad';

  @override
  String get activityLow => 'Bajo';

  @override
  String get activityModerate => 'Moderado';

  @override
  String get activityHigh => 'Alto';

  @override
  String get activityVeryHigh => 'Muy alto';

  @override
  String get caloriesKcal => 'Calorías (kcal)';

  @override
  String get proteinG => 'Proteína (g)';

  @override
  String get carbsG => 'Carbohidratos (g)';

  @override
  String get fatsG => 'Grasas (g)';

  @override
  String get hydrationL => 'Hidratación (L)';

  @override
  String get sleepHrs => 'Sueño (hrs)';

  @override
  String get fieldRequired => 'Obligatorio';

  @override
  String get enterNumber => 'Ingresa un número';

  @override
  String get accessibilityMode => 'Modo de accesibilidad';

  @override
  String get textSize => 'Tamaño de texto';

  @override
  String get themeColors => 'Colores del tema';

  @override
  String get textScaleSmall => 'Pequeño';

  @override
  String get textScaleMedium => 'Mediano';

  @override
  String get textScaleLarge => 'Grande';

  @override
  String get textScaleExtraLarge => 'Extra grande';

  @override
  String get textScaleSmallDesc => 'Etiquetas y texto compactos.';

  @override
  String get textScaleMediumDesc => 'Tamaño de texto predeterminado.';

  @override
  String get textScaleLargeDesc =>
      'Más fácil de leer en la mayoría de pantallas.';

  @override
  String get textScaleExtraLargeDesc => 'Máxima legibilidad.';

  @override
  String get themeClassic => 'Verde lima clásico';

  @override
  String get themeOcean => 'Azul océano';

  @override
  String get themeSunset => 'Coral atardecer';

  @override
  String get themeForest => 'Verde bosque';

  @override
  String get themePaletteDesc =>
      'Colores de acento y resaltado en toda la app.';

  @override
  String get sleepMode => 'Modo sueño';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get units => 'Unidades';

  @override
  String get changesSaved => 'Cambios guardados';

  @override
  String failedToSave(String error) {
    return 'Error al guardar: $error';
  }

  @override
  String unableToLoadSettings(String error) {
    return 'No se pudo cargar la configuración: $error';
  }

  @override
  String unableToUpdateTextSize(String error) {
    return 'No se pudo actualizar el tamaño de texto: $error';
  }

  @override
  String unableToUpdateTheme(String error) {
    return 'No se pudo actualizar el tema: $error';
  }

  @override
  String unableToUpdateLanguage(String error) {
    return 'No se pudo actualizar el idioma: $error';
  }

  @override
  String unableToSignOut(String error) {
    return 'No se pudo cerrar sesión: $error';
  }

  @override
  String unableToDeleteAccount(String error) {
    return 'No se pudo eliminar la cuenta: $error';
  }

  @override
  String failedToInitializeApp(String error) {
    return 'No se pudo inicializar la app:\n$error';
  }

  @override
  String failedToLoadAccount(String error) {
    return 'No se pudo cargar la cuenta:\n$error';
  }
}
