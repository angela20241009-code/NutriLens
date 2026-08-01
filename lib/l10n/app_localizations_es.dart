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
  String get profile => 'Perfil';

  @override
  String get profileUnavailable => 'Perfil no disponible';

  @override
  String unableToLoadProfile(Object error) {
    return 'No se pudo cargar el perfil: $error';
  }

  @override
  String get noNameSet => 'Sin nombre';

  @override
  String get phone => 'Teléfono';

  @override
  String get sport => 'Deporte';

  @override
  String get height => 'Altura';

  @override
  String get weight => 'Peso';

  @override
  String get trainingDays => 'Días de entrenamiento';

  @override
  String get sleepTarget => 'Objetivo de sueño';

  @override
  String get allergens => 'Alérgenos';

  @override
  String get restrictions => 'Restricciones';

  @override
  String get editProfileAndSettings => 'Editar perfil y configuración';

  @override
  String get guestCreateAccountTitle => 'Crear una cuenta';

  @override
  String get guestCreateAccountBody =>
      'Regístrate para guardar tu perfil, objetivos nutricionales y datos de entrenamiento.';

  @override
  String get guestAccountNotice =>
      'Estás usando una cuenta de invitado sin sincronización en la nube. La edición del perfil está desactivada hasta que crees una cuenta para guardar tus datos.';

  @override
  String get signOutTitle => '¿Cerrar sesión?';

  @override
  String get signOutGuestBody =>
      'No has vinculado un correo electrónico. Cerrar sesión puede hacer que pierdas tus datos en este dispositivo.';

  @override
  String signOutAccountBody(String account) {
    return '¿Cerrar sesión de $account?';
  }

  @override
  String get yourAccount => 'tu cuenta';

  @override
  String get deleteAccountTitle => '¿Eliminar cuenta?';

  @override
  String get deleteGuestAccountBody =>
      'Esto elimina permanentemente tu cuenta de invitado y todas las comidas, el sueño y los datos de perfil registrados en este dispositivo. No se puede deshacer.';

  @override
  String deleteAccountBody(String account) {
    return 'Esto elimina permanentemente $account y todos los datos asociados. No se puede deshacer.';
  }

  @override
  String get mealPreferencesDescription =>
      'Elige estilos de comida y alergias para personalizar tu plan de comidas.';

  @override
  String unableToSavePreferences(String error) {
    return 'No se pudieron guardar las preferencias: $error';
  }

  @override
  String get unableToLoadProfileShort => 'No se pudo cargar tu perfil.';

  @override
  String get saveAndRefreshMealPlan => 'Guardar y actualizar plan de comidas';

  @override
  String get accountCreatedSuccessfully => 'Cuenta creada correctamente';

  @override
  String get emailVerificationSent =>
      'Verificación enviada; revisa tu bandeja de entrada para confirmar.';

  @override
  String get passwordUpdated => 'Contraseña actualizada';

  @override
  String unableToUpdateAccessibilityMode(String error) {
    return 'No se pudo actualizar el modo de accesibilidad: $error';
  }

  @override
  String unableToUpdateSleepMode(String error) {
    return 'No se pudo actualizar el modo sueño: $error';
  }

  @override
  String get modeSwitcher => 'Selector de modo';

  @override
  String get minimalTabs => 'Pestañas mínimas';

  @override
  String get minimalTabsDescription =>
      'Pestañas superiores delgadas con subrayado activo.';

  @override
  String get classicPill => 'Píldora clásica';

  @override
  String get classicPillDescription =>
      'Control segmentado redondeado original.';

  @override
  String unableToUpdateModeSwitcher(String error) {
    return 'No se pudo actualizar el selector de modo: $error';
  }

  @override
  String get select => 'Seleccionar';

  @override
  String get changeEmail => 'Cambiar correo electrónico';

  @override
  String get newEmail => 'Nuevo correo electrónico';

  @override
  String get currentPassword => 'Contraseña actual';

  @override
  String get enterPassword => 'Ingresa tu contraseña';

  @override
  String get update => 'Actualizar';

  @override
  String get newPassword => 'Nueva contraseña';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get passwordMinCharacters => 'Al menos 6 caracteres';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get sleepGreetingMorning => 'Buenos días';

  @override
  String get sleepGreetingAfternoon => 'Buenas tardes';

  @override
  String get sleepGreetingEvening => 'Buenas noches';

  @override
  String get athlete => 'Atleta';

  @override
  String get logSleep => 'Registrar sueño';

  @override
  String get sleepSchedule => 'Horario de sueño';

  @override
  String unableToSaveSleepSchedule(String error) {
    return 'No se pudo guardar el horario de sueño: $error';
  }

  @override
  String get sleepProfileUnavailableBody =>
      'Necesitamos tu perfil antes de planificar el sueño.';

  @override
  String get wakeTimePlanning => 'Planificación de hora de despertar';

  @override
  String get setSleepSchedule => 'Configura tu horario de sueño';

  @override
  String get wakeTimePlanningDescription =>
      'Usamos tu hora habitual de dormir y despertar para proteger la recuperación antes de entrenamientos y partidos.';

  @override
  String get setSleepScheduleDescription =>
      'Agrega tu hora habitual de dormir y despertar para que el modo sueño planifique la recuperación y registre estadísticas.';

  @override
  String get bedtime => 'Hora de dormir';

  @override
  String get wakeTime => 'Hora de despertar';

  @override
  String get add => 'Agregar';

  @override
  String get saveSleepSchedule => 'Guardar horario de sueño';

  @override
  String get targetSleep => 'Sueño objetivo';

  @override
  String get tonightBedtime => 'Hora de dormir esta noche';

  @override
  String earlierWakeSuggested(String event, String time) {
    return 'Despertar más temprano sugerido para $event a las $time.';
  }

  @override
  String get customBedtimeLimit =>
      'Puedes agregar hasta 3 elementos de hora de dormir personalizados.';

  @override
  String unableToSaveBedtimeItems(String error) {
    return 'No se pudieron guardar los elementos de hora de dormir: $error';
  }

  @override
  String get enterValidTime => 'Ingresa una hora válida como 10:30 PM o 22:30.';

  @override
  String get addCustomBedtime => 'Agregar hora de dormir personalizada';

  @override
  String get editCustomBedtime => 'Editar hora de dormir personalizada';

  @override
  String get bedtimeHint => '10:30 PM o 22:30';

  @override
  String get pickTime => 'Elegir hora';

  @override
  String get save => 'Guardar';

  @override
  String sleepLoggedForDay(String duration, String day, String advice) {
    return 'Guardado $duration para $day. $advice';
  }

  @override
  String sleepAppliedForDays(String duration, int count, String advice) {
    return 'Se aplicó $duration a $count días. $advice';
  }

  @override
  String unableToLoadSleepSchedule(String error) {
    return 'No se pudo cargar el horario de sueño:\n$error';
  }

  @override
  String get sleepScheduleUnavailable => 'Horario de sueño no disponible';

  @override
  String get sleepScheduleDescription =>
      'Elige un día, ingresa horas y minutos, luego guarda un día o aplica la misma duración de sueño para la próxima semana.';

  @override
  String get hours => 'Horas';

  @override
  String get minutes => 'Minutos';

  @override
  String selectedDuration(String duration) {
    return 'Duración seleccionada: $duration';
  }

  @override
  String targetDuration(String duration) {
    return 'Objetivo $duration';
  }

  @override
  String get presetBedtimes => 'Horas de dormir predefinidas';

  @override
  String customBedtimeItems(int count, int max) {
    return 'Elementos de hora de dormir personalizados ($count/$max)';
  }

  @override
  String get noCustomBedtimeItems =>
      'Aún no hay elementos de hora de dormir personalizados. Agrega hasta 3.';

  @override
  String get editTime => 'Editar hora';

  @override
  String get delete => 'Eliminar';

  @override
  String bedtimeItemsDescription(String time) {
    return 'Los elementos de hora de dormir usan la hora de despertar $time para calcular la duración del sueño.';
  }

  @override
  String get saveDay => 'Guardar día';

  @override
  String get applyNextSevenDays => 'Aplicar a los próximos 7 días';

  @override
  String get automaticTrackingStatus => 'Estado del seguimiento automático';

  @override
  String get automaticTrackingDescription =>
      'El seguimiento automático solo con reloj no es fiable en iOS/Android por los límites en segundo plano. Usa este planificador para programar manualmente y deja la sincronización de salud como opción automática futura.';

  @override
  String get today => 'Hoy';

  @override
  String get mondayShort => 'Lun';

  @override
  String get tuesdayShort => 'Mar';

  @override
  String get wednesdayShort => 'Mié';

  @override
  String get thursdayShort => 'Jue';

  @override
  String get fridayShort => 'Vie';

  @override
  String get saturdayShort => 'Sáb';

  @override
  String get sundayShort => 'Dom';

  @override
  String get sleepDurationInvalid =>
      'Ingresa horas y minutos válidos (0–59 para minutos).';

  @override
  String get sleepDurationRange =>
      'La duración del sueño debe estar entre 2 y 16 horas.';

  @override
  String sleepTotal(String duration) {
    return 'Total: $duration';
  }

  @override
  String sleepTargetHours(String hours) {
    return 'Objetivo: $hours h';
  }

  @override
  String get skipForNow => 'Omitir por ahora';

  @override
  String get saveSleep => 'Guardar sueño';

  @override
  String get sleepCheckInDescription =>
      '¿Cuánto dormiste? Ingresa horas y minutos, u omite por ahora.';

  @override
  String sleepLogged(String duration, String advice) {
    return 'Registrado $duration. $advice';
  }

  @override
  String unableToSaveSleepLog(String error) {
    return 'No se pudo guardar el registro de sueño: $error';
  }

  @override
  String get recoveryAhead => 'La recuperación está por delante';

  @override
  String sleepAboveTarget(String slept, String target) {
    return 'Dormiste $slept, por encima de tu objetivo de $target h.';
  }

  @override
  String sleepConsistencyAdvice(String bedtime, String wakeTime) {
    return 'Mantén la hora de dormir cerca de $bedtime y despierta alrededor de $wakeTime para ser constante.';
  }

  @override
  String get onTarget => 'En objetivo';

  @override
  String sleepMatchesTarget(String slept, String target) {
    return 'Dormiste $slept, cumpliendo tu objetivo de $target h.';
  }

  @override
  String sleepRhythmAdvice(String bedtime, String wakeTime) {
    return 'Mantén el ritmo con hora de dormir alrededor de $bedtime y despertar alrededor de $wakeTime.';
  }

  @override
  String get sleepNeedsBoost => 'El sueño necesita un impulso';

  @override
  String sleepBelowTarget(String deficit, String target) {
    return 'Estás unas $deficit h por debajo de tu objetivo de $target h.';
  }

  @override
  String sleepRecoveryAdvice(
    String bedtime,
    String wakeTime,
    String eventNote,
  ) {
    return 'Esta noche, intenta dormir cerca de $bedtime para despertar a las $wakeTime con mejor recuperación.$eventNote';
  }

  @override
  String earlierWakeRecommendation(String event, String time) {
    return 'Se sugiere despertar antes para $event a las $time.';
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
      'Cuéntanos qué te gusta y qué evitar después de registrarte.';

  @override
  String get authMealsPerDay => 'Comidas por día';

  @override
  String get authMealsPerDayHint => '¿Cuántas comidas sueles hacer al día?';

  @override
  String get authEmail => 'Correo electrónico';

  @override
  String get authPassword => 'Contraseña';

  @override
  String get authCreateAccount => 'Crear cuenta';

  @override
  String get authContinueAsGuest => 'Continuar como invitado';

  @override
  String get authLegalAgreement =>
      'Acepto la Política de privacidad y los Términos y condiciones';

  @override
  String get authPrivacyPolicy => 'Política de privacidad';

  @override
  String get authTermsAndConditions => 'Términos y condiciones';

  @override
  String get authValidationLegalRequired =>
      'Acepta la Política de privacidad y los Términos y condiciones para continuar';

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
  String get deleteAccountReauthTitle => 'Confirma tu contraseña';

  @override
  String get deleteAccountReauthBody =>
      'Por seguridad, ingresa tu contraseña para eliminar permanentemente esta cuenta.';

  @override
  String get deleteAccountReauthPassword => 'Contraseña';

  @override
  String get authErrorRequiresRecentLogin =>
      'Por seguridad, confirma tu contraseña e inténtalo de nuevo.';

  @override
  String failedToInitializeApp(String error) {
    return 'No se pudo inicializar la app:\n$error';
  }

  @override
  String failedToLoadAccount(String error) {
    return 'No se pudo cargar la cuenta:\n$error';
  }

  @override
  String get continueButton => 'Continuar';

  @override
  String get tryAgain => 'Intentar de nuevo';

  @override
  String get finishSetup => 'Finalizar configuración';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get maybe => 'Quizás';

  @override
  String get required => 'Obligatorio';

  @override
  String get enterPositiveNumber => 'Ingresa un número positivo';

  @override
  String get navHome => 'Inicio';

  @override
  String get navMeals => 'Comidas';

  @override
  String get navSchedule => 'Horario';

  @override
  String get navProfile => 'Perfil';

  @override
  String get navSleep => 'Sueño';

  @override
  String get navLog => 'Registro';

  @override
  String get modeMealTracking => 'Seguimiento de comidas';

  @override
  String get modeSleep => 'Sueño';

  @override
  String get goodMorning => 'Buenos días';

  @override
  String get goodAfternoon => 'Buenas tardes';

  @override
  String get goodEvening => 'Buenas noches';

  @override
  String get sportTennis => 'Tenis';

  @override
  String get sportBasketball => 'Baloncesto';

  @override
  String get sportSoccer => 'Fútbol';

  @override
  String get sportAmericanFootball => 'Fútbol americano';

  @override
  String get sportBaseball => 'Béisbol';

  @override
  String get sportSoftball => 'Sóftbol';

  @override
  String get sportVolleyball => 'Voleibol';

  @override
  String get sportSwimming => 'Natación';

  @override
  String get sportTrackAndField => 'Atletismo';

  @override
  String get sportCrossCountry => 'Campo a través';

  @override
  String get sportWrestling => 'Lucha';

  @override
  String get sportLacrosse => 'Lacrosse';

  @override
  String get sportHockey => 'Hockey';

  @override
  String get sportGolf => 'Golf';

  @override
  String get sportGymnastics => 'Gimnasia';

  @override
  String get sportCycling => 'Ciclismo';

  @override
  String get sportOther => 'Otro';

  @override
  String get sportNone => 'Ninguno';

  @override
  String get onboardingWelcomeTitle => 'NutriLens';

  @override
  String get onboardingWelcomeSubtitle =>
      'Aliméntate mejor. Entrena más fuerte.';

  @override
  String get onboardingGetStarted => 'Comenzar';

  @override
  String get onboardingYourName => 'Tu nombre';

  @override
  String get onboardingFullNameLabel => 'NOMBRE COMPLETO';

  @override
  String get onboardingAboutSport => 'Sobre tu deporte';

  @override
  String get onboardingPlaySportQuestion =>
      '¿Practicas algún deporte actualmente?';

  @override
  String get onboardingPlaySportYes => 'Sí, practico un deporte';

  @override
  String get onboardingPlaySportNo => 'No, actualmente no';

  @override
  String get onboardingYourSportLabel => 'TU DEPORTE';

  @override
  String get onboardingEnterSport => 'Ingresa tu deporte';

  @override
  String get onboardingNoSportTargets =>
      'No hay problema: estimaremos tus objetivos nutricionales según tus medidas corporales.';

  @override
  String get onboardingChooseOption =>
      'Elige una opción arriba para continuar.';

  @override
  String get onboardingYourSchool => 'Tu escuela';

  @override
  String get onboardingSchoolNameLabel => 'NOMBRE DE LA ESCUELA (OPCIONAL)';

  @override
  String get onboardingGraduationYearLabel => 'AÑO DE GRADUACIÓN (OPCIONAL)';

  @override
  String get onboardingEnterFourDigitYear => 'Ingresa un año de 4 dígitos';

  @override
  String get onboardingSleepCheck => 'Revisión del sueño';

  @override
  String get onboardingSleepCheckIntro =>
      'Tres preguntas rápidas. Toca una opción para seleccionarla; tócala de nuevo para quitarla.';

  @override
  String get sleepQuestionWakeTired => '¿Te despiertas cansado?';

  @override
  String get sleepQuestionWakeTiredHint =>
      'Piensa en una semana escolar típica.';

  @override
  String get sleepQuestionBedtimeChanges => '¿Tu hora de dormir cambia mucho?';

  @override
  String get sleepQuestionBedtimeChangesHint =>
      'Los partidos, entrenamientos o tareas pueden retrasar el sueño.';

  @override
  String get sleepQuestionReminder =>
      '¿Te ayudaría un recordatorio para dormir?';

  @override
  String get sleepQuestionReminderHint =>
      'Un suave aviso antes de tu hora objetivo de dormir.';

  @override
  String get sleepAnswerNotOften => 'No muy a menudo';

  @override
  String get sleepAnswerSometimes => 'A veces';

  @override
  String get sleepAnswerOften => 'A menudo';

  @override
  String get onboardingUseSleepMode => 'Usar modo sueño';

  @override
  String get onboardingSleepRecommended => 'Recomendamos el modo sueño';

  @override
  String get onboardingSleepOptional => 'El modo sueño es opcional';

  @override
  String get onboardingSleepRecommendation =>
      'Según tus respuestas, el modo sueño podría ayudarte a recuperarte.';

  @override
  String get onboardingSleepOptionalBody =>
      'Puedes activarlo más tarde en Configuración si cambia tu horario.';

  @override
  String get onboardingBodyMetrics => 'Tus medidas corporales';

  @override
  String get onboardingBodyMetricsHint =>
      'Usamos la altura y el peso para estimar tus objetivos nutricionales diarios.';

  @override
  String get onboardingHeightLabel => 'ALTURA (CM)';

  @override
  String get onboardingWeightLabel => 'PESO (KG)';

  @override
  String onboardingMaximumHeight(int height) {
    return 'La altura máxima es $height cm';
  }

  @override
  String onboardingMaximumWeight(int weight) {
    return 'El peso máximo es $weight kg';
  }

  @override
  String get onboardingNutritionTargets => 'Objetivos nutricionales diarios';

  @override
  String get onboardingTargetsFromSport =>
      'Los estimamos según tu deporte, altura y peso. Puedes ajustarlos.';

  @override
  String get onboardingTargetsFromMetrics =>
      'Los estimamos según tu altura y peso. Puedes ajustarlos.';

  @override
  String get homeTodayMealPlan => 'Plan de comidas de hoy';

  @override
  String get homeNoMealsPlanned => 'Aún no hay comidas planificadas para hoy.';

  @override
  String get homeMealPlanUnavailable =>
      'El plan de comidas no está disponible ahora mismo.';

  @override
  String get homeMealPlanRefreshed =>
      'Plan de comidas actualizado con tus preferencias';

  @override
  String homeUnableToSaveHydration(String error) {
    return 'No se pudo guardar la hidratación: $error';
  }

  @override
  String homeFailedToLoadData(String error) {
    return 'No se pudieron cargar los datos de inicio:\n$error';
  }

  @override
  String get homeThisWeeksFuel => 'Combustible de esta semana';

  @override
  String get homeTodayFuel => 'Combustible de hoy';

  @override
  String get homeHydration => 'Hidratación';

  @override
  String get homeProgramTitle => 'Tu programa';

  @override
  String get homeProgramSubtitle =>
      'Mantén la constancia y alimenta tu entrenamiento.';

  @override
  String get homeWeeklySleep => 'Sueño semanal';

  @override
  String get homeLogged => 'Registrado';

  @override
  String homeTargetHours(String hours) {
    return 'Objetivo $hours h';
  }

  @override
  String get scheduleTitle => 'Horario';

  @override
  String get scheduleTimeline => 'Cronología';

  @override
  String get scheduleMeals => 'Comidas';

  @override
  String get scheduleEvents => 'Eventos';

  @override
  String get scheduleSleep => 'Sueño';

  @override
  String get scheduleLogSleep => 'Registrar sueño';

  @override
  String get scheduleLogSleepForDay => 'Registrar sueño de este día';

  @override
  String scheduleNewMealReady(String meal) {
    return 'Nueva comida de $meal lista';
  }

  @override
  String scheduleMealGenerationFailed(String error) {
    return 'No se pudo generar una nueva comida: $error';
  }

  @override
  String get scheduleDeleteEventTitle => '¿Eliminar evento?';

  @override
  String scheduleDeleteEventBody(String title) {
    return '¿Eliminar \"$title\" de tu horario?';
  }

  @override
  String get scheduleDeleteEventFailed => 'No se pudo eliminar el evento.';

  @override
  String get scheduleEventDeleted => 'Evento eliminado.';

  @override
  String get scheduleNoItems => 'No hay nada programado para este día.';

  @override
  String get scheduleCreateEvent => 'Crear evento';

  @override
  String get scheduleEventCreated => 'Evento creado';

  @override
  String get scheduleEventType => 'Tipo de evento';

  @override
  String get scheduleEventTitle => 'Título';

  @override
  String get scheduleDate => 'Fecha';

  @override
  String get scheduleTime => 'Hora';

  @override
  String get scheduleSubtitle => 'Subtítulo';

  @override
  String get scheduleLocation => 'Ubicación';

  @override
  String get scheduleBadge => 'Insignia';

  @override
  String get scheduleFuelingHints => 'Consejos de alimentación';

  @override
  String get scheduleTiming => 'Horario';

  @override
  String get scheduleHint => 'Consejo';

  @override
  String get scheduleFilterAll => 'Todo';

  @override
  String get scheduleFilterMeals => 'Comidas';

  @override
  String get scheduleFilterEvents => 'Eventos';

  @override
  String get scheduleFilterSleep => 'Sueño';

  @override
  String get scheduleEventPractice => 'Entrenamiento';

  @override
  String get scheduleEventGame => 'Partido';

  @override
  String get scheduleEventWorkout => 'Ejercicio';

  @override
  String get scheduleEventOther => 'Otro';

  @override
  String get scheduleEventMeal => 'Comida';

  @override
  String get scheduleEventTraining => 'Entrenamiento';

  @override
  String get scheduleEventMatch => 'Partido';

  @override
  String get mealsTitle => 'Comidas';

  @override
  String get mealsLogMeal => 'Registrar comida';

  @override
  String get mealsMealLogged => 'Comida registrada correctamente';

  @override
  String get mealsMealName => 'Nombre de la comida';

  @override
  String get mealsCalories => 'Calorías kcal';

  @override
  String get mealsProtein => 'Proteína';

  @override
  String get mealsCarbs => 'Carbohidratos';

  @override
  String get mealsFats => 'Grasas';

  @override
  String get mealsSaveMeal => 'Guardar comida';

  @override
  String get mealsFavorites => 'Favoritos';

  @override
  String mealsFavoriteLogged(String title) {
    return '$title registrada';
  }

  @override
  String get mealsRecipeDetails => 'Detalles de la receta';

  @override
  String get mealsIngredients => 'Ingredientes';

  @override
  String get mealsInstructions => 'Instrucciones';

  @override
  String mealsMinutes(int count) {
    return '$count min';
  }

  @override
  String mealsServings(int count) {
    return '$count porciones';
  }

  @override
  String get sleepDashboardTitle => 'Horario de sueño';

  @override
  String get sleepProfileUnavailable => 'Perfil no disponible';

  @override
  String get sleepBedtime => 'Hora de dormir';

  @override
  String get sleepWakeTime => 'Hora de despertar';

  @override
  String get sleepSaveSchedule => 'Guardar horario de sueño';

  @override
  String sleepUnableToSaveSchedule(String error) {
    return 'No se pudo guardar el horario de sueño: $error';
  }

  @override
  String get sleepTargetSleep => 'Sueño objetivo';

  @override
  String get sleepTonightBedtime => 'Hora de dormir esta noche';

  @override
  String get sleepRecoveryAhead => 'La recuperación está por delante';

  @override
  String get sleepOnTarget => 'En objetivo';

  @override
  String sleepUnableToSaveLog(String error) {
    return 'No se pudo guardar el registro de sueño: $error';
  }

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileSignOutTitle => '¿Cerrar sesión?';

  @override
  String get profileSignOutBody => '¿Seguro que deseas cerrar sesión?';

  @override
  String get profileDeleteAccountTitle => '¿Eliminar cuenta?';

  @override
  String get profileDeleteGuestBody =>
      'Esto elimina permanentemente tu cuenta de invitado y todas las comidas, el sueño y los datos de perfil registrados en este dispositivo. No se puede deshacer.';

  @override
  String profileDeleteAccountBody(String email) {
    return 'Esto elimina permanentemente $email y todos los datos asociados. No se puede deshacer.';
  }

  @override
  String get profileAccountCreated => 'Cuenta creada correctamente';

  @override
  String get profileVerificationSent =>
      'Verificación enviada; revisa tu bandeja de entrada para confirmar.';

  @override
  String get profilePasswordUpdated => 'Contraseña actualizada';

  @override
  String get profileCreateAccount => 'Crear cuenta';

  @override
  String get profileLinkEmail => 'Vincular correo electrónico';

  @override
  String get profileGuestNotice =>
      'Crea una cuenta para respaldar tus datos y usarlos en todos tus dispositivos.';

  @override
  String get profileSaveRefreshMealPlan =>
      'Guardar y actualizar plan de comidas';

  @override
  String profileUnableToUpdateAccessibility(String error) {
    return 'No se pudo actualizar el modo de accesibilidad: $error';
  }

  @override
  String profileUnableToUpdateSleepMode(String error) {
    return 'No se pudo actualizar el modo sueño: $error';
  }

  @override
  String get profileModeSwitcher => 'Selector de modo';

  @override
  String get profileMinimalTabs => 'Pestañas mínimas';

  @override
  String get profileMinimalTabsDescription =>
      'Pestañas superiores delgadas con subrayado activo.';

  @override
  String get profileClassicPill => 'Píldora clásica';

  @override
  String get profileClassicPillDescription =>
      'Control segmentado redondeado original.';

  @override
  String profileUnableToUpdateModeSwitcher(String error) {
    return 'No se pudo actualizar el selector de modo: $error';
  }

  @override
  String get scheduleMealPlan => 'Plan de comidas';

  @override
  String get scheduleNoMealsPlanned =>
      'No hay comidas planificadas para este día.';

  @override
  String get scheduleMealPlanUnavailable =>
      'El plan de comidas no está disponible ahora mismo.';

  @override
  String get scheduleGenerating => 'Generando...';

  @override
  String get scheduleNewMeal => 'Nueva comida';

  @override
  String get scheduleSleepLogged => 'Sueño registrado';

  @override
  String get scheduleThisWeek => 'Esta semana';

  @override
  String get scheduleFullMonth => 'Mes completo';

  @override
  String get scheduleTodaysMatch => 'Partido de hoy';

  @override
  String get scheduleAddTitle => 'Agregar título';

  @override
  String get scheduleAddSubtitle => 'Agregar subtítulo';

  @override
  String get scheduleAddLocation => 'Agregar ubicación';

  @override
  String get scheduleAddBadge => 'Agregar insignia';

  @override
  String get scheduleAddHints => 'Agregar consejos';

  @override
  String scheduleHintCount(int count) {
    return '$count consejos';
  }

  @override
  String get scheduleTimingHint => '2 h antes';

  @override
  String get scheduleHydrate => 'Hidratar';

  @override
  String get scheduleRemoveHint => 'Quitar consejo';

  @override
  String get scheduleLoadFailed => 'No se pudo cargar el horario.';

  @override
  String get scheduleLogSleepEmpty => 'No hay sueño registrado para este día.';

  @override
  String get scheduleNoEvents => 'No hay eventos programados para este día.';

  @override
  String get scheduleNoMeals => 'No hay comidas registradas para este día.';

  @override
  String get scheduleNoEntries =>
      'No hay eventos, comidas ni sueño registrados para este día.';

  @override
  String get mealSearchTitle => 'Buscar platos';

  @override
  String get mealSearchDescription =>
      'Busca recetas y consulta ingredientes e instrucciones en la app.';

  @override
  String get mealSearchHint => 'Buscar pollo, pasta, ensalada...';

  @override
  String mealSearchResultsFor(String query) {
    return 'Resultados para \"$query\"';
  }

  @override
  String get mealPopularDishes => 'Platos populares';

  @override
  String get mealUnableToLoadDishes => 'No se pudieron cargar los platos';

  @override
  String get mealNoDishesFound =>
      'No se encontraron platos. Prueba otra búsqueda.';

  @override
  String get mealEnterDishName =>
      'Ingresa el nombre de un plato y pulsa Buscar en tu teclado.';

  @override
  String mealUnableToLog(String error) {
    return 'No se pudo registrar la comida: $error';
  }

  @override
  String get mealEnterValidNumber => 'Ingresa un número válido';

  @override
  String get mealLogFavorite => 'Registrar favorito';

  @override
  String mealUnableToLogFavorite(String error) {
    return 'No se pudo registrar el favorito: $error';
  }

  @override
  String get mealEditBeforeLogging => 'Editar antes de registrar';

  @override
  String get mealSavedToProfile => 'Guardado en el perfil';

  @override
  String mealServingCount(int count) {
    return '$count porción';
  }

  @override
  String get mealProtein => 'Proteína';

  @override
  String get mealCarbs => 'Carbohidratos';

  @override
  String get mealFats => 'Grasas';

  @override
  String get mealUnableToLoadRecipeDetails =>
      'No se pudieron cargar los detalles de la receta';

  @override
  String get mealFavoriteBerryYogurtBowl => 'Tazón de yogur con bayas';

  @override
  String get mealFavoriteSalmonBowl => 'Tazón de salmón';

  @override
  String get mealFavoriteChickenBowl => 'Tazón de pollo';

  @override
  String get homeHydrationReminder => 'Recordatorio de hidratación';

  @override
  String get homeHydrationGoalReached => '¡Buen trabajo — objetivo alcanzado!';

  @override
  String homeHydrationDrinkMore(String liters) {
    return 'Bebe $liters L más hoy';
  }

  @override
  String homeHydrationLoggedOf(String current, String target) {
    return '$current L de $target L registrados';
  }

  @override
  String get homeMealCapture => 'Registro de comidas';

  @override
  String get homeReadyToLog => '¿Listo para registrar?';

  @override
  String get homeMealCaptureOptions => 'Manual, preferencias o favoritos';

  @override
  String get homePrefsShort => 'Prefs';

  @override
  String get homePersonalNutritionProgram => 'Programa de nutrición personal';

  @override
  String homeSchoolSportProgram(String school, String sport) {
    return 'Programa de $school $sport';
  }

  @override
  String homeSportNutritionProgram(String sport) {
    return 'Programa de nutrición de $sport';
  }

  @override
  String get homeNoSleepLoggedWeek =>
      'Aún no hay sueño registrado esta semana.';

  @override
  String homeSleepWeekAvg(String avg, int logged) {
    return '$avg prom. • $logged de 7 días registrados';
  }

  @override
  String homeFailedLoadWeeklyFuel(String error) {
    return 'No se pudo cargar el combustible semanal:\n$error';
  }

  @override
  String get homeNoMealsLoggedWeek =>
      'Aún no hay comidas registradas esta semana.';

  @override
  String homeDaysLoggedCount(int logged) {
    return '$logged de 7 días registrados';
  }

  @override
  String get homeTotal => 'Total';

  @override
  String get homeWeeklyTarget => 'Objetivo semanal';

  @override
  String get homeDailyAverage => 'Promedio diario';

  @override
  String get homeDailyCalories => 'Calorías diarias';

  @override
  String get homeDailyBreakdown => 'Desglose diario';

  @override
  String homeTodayDateLabel(String date) {
    return 'Hoy • $date';
  }

  @override
  String get homeNoMealsLogged => 'Sin comidas registradas';

  @override
  String homeCaloriesProgress(String current, String target) {
    return '$current / $target kcal';
  }

  @override
  String homeMacroSummary(String protein, String carbs, String fats) {
    return 'P $protein g • C $carbs g • F $fats g';
  }

  @override
  String homeMealKcalProtein(String kcal, String protein) {
    return '$kcal kcal · $protein g P';
  }

  @override
  String get homeNextSession => 'PRÓXIMA SESIÓN';

  @override
  String get homeManualLog => 'Manual';

  @override
  String homeCaloriesOfTarget(String target) {
    return '/ $target kcal';
  }

  @override
  String get scanMealSaved => 'Comida guardada en tu registro';

  @override
  String scanUnableAnalyze(String error) {
    return 'No se pudo analizar la foto de la comida: $error';
  }

  @override
  String scanUnablePickImage(String error) {
    return 'No se pudo elegir la imagen: $error';
  }

  @override
  String get scanTakePhoto => 'Tomar foto';

  @override
  String get scanTakePhotoSubtitle => 'Usa tu cámara para escanear una comida';

  @override
  String get scanPhotoLibrary => 'Biblioteca de fotos';

  @override
  String get scanPhotoLibrarySubtitle => 'Elige una imagen existente';

  @override
  String get scanMeal => 'Escanear comida';

  @override
  String get scanPointAtFood => 'Apunta a tu comida';

  @override
  String get scanTapToCapture =>
      'Toca para tomar una foto o elegir de la biblioteca';

  @override
  String get scanAnalyzing => 'Analizando comida...';

  @override
  String get scanPhoto => 'Foto';

  @override
  String get scanManual => 'Manual';

  @override
  String get scanPrevious => 'Anteriores';

  @override
  String get scanMealAdded => 'Comida agregada a tu registro';

  @override
  String get scanMealAnalysis => 'Análisis de comida';

  @override
  String get scanMealAnalysisSubtitle =>
      'Revisa la estimación de IA antes de guardar en tu registro.';

  @override
  String get scanPreviousMeals => 'Comidas anteriores';

  @override
  String scanPreviousMealsSubtitle(int count) {
    return 'Toca una comida para registrarla de nuevo. Mostrando hasta $count comidas recientes.';
  }

  @override
  String get scanNoMealsLogged => 'Aún no hay comidas registradas.';

  @override
  String scanMealListSubtitle(String kcal, String protein) {
    return '$kcal kcal · $protein g proteína';
  }

  @override
  String get onboardingSleepReasonWakeTired =>
      'A menudo te despiertas cansado.';

  @override
  String get onboardingSleepReasonBedtimeChanges =>
      'Tu hora de dormir cambia mucho.';

  @override
  String get onboardingSleepReasonReminder =>
      'Un recordatorio podría ayudarte a relajarte.';

  @override
  String get onboardingSleepReasonSteadierRoutine =>
      'El modo sueño puede ayudarte a crear una rutina más estable.';

  @override
  String get profileEditPhoto => 'Editar foto';

  @override
  String get mealTypeBreakfast => 'DESAYUNO';

  @override
  String get mealTypeLunch => 'ALMUERZO';

  @override
  String get mealTypeDinner => 'CENA';

  @override
  String get mealTypeSnack => 'MERIENDA';
}
