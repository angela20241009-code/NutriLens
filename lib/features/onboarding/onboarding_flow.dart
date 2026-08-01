import 'package:flutter/material.dart';
import 'package:nutrilens/app/app_settings_scope.dart';
import 'package:nutrilens/app/user_scope.dart';
import 'package:nutrilens/features/profile/meal_preferences_form.dart';
import 'package:nutrilens/features/profile/widgets/profile_text_field.dart';
import 'package:nutrilens/features/shell/app_shell.dart';
import 'package:nutrilens/l10n/app_localizations.dart';
import 'package:nutrilens/l10n/l10n_extensions.dart';
import 'package:nutrilens/models/daily_targets.dart';
import 'package:nutrilens/models/nutrition_settings.dart';
import 'package:nutrilens/models/notification_settings.dart';
import 'package:nutrilens/models/user_profile.dart';
import 'package:nutrilens/theme/app_colors.dart';

const _sports = <({String id})>[
  (id: 'tennis'),
  (id: 'basketball'),
  (id: 'soccer'),
  (id: 'american_football'),
  (id: 'baseball'),
  (id: 'softball'),
  (id: 'volleyball'),
  (id: 'swimming'),
  (id: 'track_and_field'),
  (id: 'cross_country'),
  (id: 'wrestling'),
  (id: 'lacrosse'),
  (id: 'hockey'),
  (id: 'golf'),
  (id: 'gymnastics'),
  (id: 'cycling'),
  (id: 'other'),
];

class _SportTargets {
  const _SportTargets({
    required this.caloriesKcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatsG,
    required this.hydrationLiters,
  });

  final int caloriesKcal;
  final int proteinG;
  final int carbsG;
  final int fatsG;
  final double hydrationLiters;
}

const _sportTargets = <String, _SportTargets>{
  'tennis': _SportTargets(
    caloriesKcal: 3200,
    proteinG: 180,
    carbsG: 440,
    fatsG: 90,
    hydrationLiters: 3.5,
  ),
  'basketball': _SportTargets(
    caloriesKcal: 3500,
    proteinG: 190,
    carbsG: 480,
    fatsG: 95,
    hydrationLiters: 3.8,
  ),
  'soccer': _SportTargets(
    caloriesKcal: 3400,
    proteinG: 170,
    carbsG: 460,
    fatsG: 85,
    hydrationLiters: 3.6,
  ),
  'american_football': _SportTargets(
    caloriesKcal: 3800,
    proteinG: 200,
    carbsG: 500,
    fatsG: 100,
    hydrationLiters: 4.0,
  ),
  'baseball': _SportTargets(
    caloriesKcal: 2800,
    proteinG: 160,
    carbsG: 350,
    fatsG: 80,
    hydrationLiters: 3.0,
  ),
  'softball': _SportTargets(
    caloriesKcal: 2900,
    proteinG: 165,
    carbsG: 360,
    fatsG: 82,
    hydrationLiters: 3.2,
  ),
  'volleyball': _SportTargets(
    caloriesKcal: 3300,
    proteinG: 175,
    carbsG: 450,
    fatsG: 85,
    hydrationLiters: 3.5,
  ),
  'swimming': _SportTargets(
    caloriesKcal: 3600,
    proteinG: 175,
    carbsG: 470,
    fatsG: 90,
    hydrationLiters: 4.0,
  ),
  'track_and_field': _SportTargets(
    caloriesKcal: 3000,
    proteinG: 160,
    carbsG: 400,
    fatsG: 80,
    hydrationLiters: 3.2,
  ),
  'cross_country': _SportTargets(
    caloriesKcal: 3400,
    proteinG: 165,
    carbsG: 480,
    fatsG: 80,
    hydrationLiters: 3.8,
  ),
  'wrestling': _SportTargets(
    caloriesKcal: 3000,
    proteinG: 200,
    carbsG: 380,
    fatsG: 75,
    hydrationLiters: 3.5,
  ),
  'lacrosse': _SportTargets(
    caloriesKcal: 3500,
    proteinG: 180,
    carbsG: 470,
    fatsG: 90,
    hydrationLiters: 3.7,
  ),
  'hockey': _SportTargets(
    caloriesKcal: 3700,
    proteinG: 185,
    carbsG: 480,
    fatsG: 95,
    hydrationLiters: 4.0,
  ),
  'golf': _SportTargets(
    caloriesKcal: 2600,
    proteinG: 140,
    carbsG: 320,
    fatsG: 70,
    hydrationLiters: 2.8,
  ),
  'gymnastics': _SportTargets(
    caloriesKcal: 2800,
    proteinG: 170,
    carbsG: 380,
    fatsG: 75,
    hydrationLiters: 3.2,
  ),
  'cycling': _SportTargets(
    caloriesKcal: 3600,
    proteinG: 170,
    carbsG: 500,
    fatsG: 85,
    hydrationLiters: 4.0,
  ),
  'other': _SportTargets(
    caloriesKcal: 2800,
    proteinG: 150,
    carbsG: 350,
    fatsG: 75,
    hydrationLiters: 3.0,
  ),
  'none': _SportTargets(
    caloriesKcal: 2400,
    proteinG: 130,
    carbsG: 280,
    fatsG: 70,
    hydrationLiters: 2.8,
  ),
};

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  static const _totalSteps = 8;

  final _pageController = PageController();
  final _nameFormKey = GlobalKey<FormState>();
  final _schoolFormKey = GlobalKey<FormState>();
  final _sportFormKey = GlobalKey<FormState>();
  final _mealPrefsFormKey = GlobalKey<FormState>();
  final _bodyFormKey = GlobalKey<FormState>();
  final _goalsFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _otherSportController = TextEditingController();
  final _schoolController = TextEditingController();
  final _graduationController = TextEditingController();
  final _allergensController = TextEditingController();
  final _restrictionsController = TextEditingController();
  final _otherStyleController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatsController = TextEditingController();

  String? _selectedSportId;
  String? _selectedSportName;
  bool? _playsSport;
  String? _lastDerivedSportId;
  double? _lastDerivedHeightCm;
  double? _lastDerivedWeightKg;
  final _selectedStyles = <String>{};
  bool _othersSelected = false;
  int _mealsPerDay = 3;
  String? _wakeTiredAnswer;
  String? _bedtimeConsistencyAnswer;
  String? _sleepReminderAnswer;
  bool _sleepModeEnabled = false;
  String _timezone = 'America/Los_Angeles';
  bool _saving = false;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTimezone();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _otherSportController.dispose();
    _schoolController.dispose();
    _graduationController.dispose();
    _allergensController.dispose();
    _restrictionsController.dispose();
    _otherStyleController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    super.dispose();
  }

  Future<void> _loadTimezone() async {
    final scope = UserScope.of(context);
    final profile = await scope.repository.getProfile(scope.uid);
    if (!mounted) return;
    if (profile?.timezone != null && profile!.timezone.isNotEmpty) {
      setState(() {
        _timezone = profile.timezone;
        _allergensController.text = profile.dietaryProfile.allergens.join(', ');
        _restrictionsController.text = profile.dietaryProfile.restrictions.join(
          ', ',
        );
        populateMealStyleFormState(
          preferences: profile.dietaryProfile.preferences,
          selectedStyles: _selectedStyles,
          otherStyleController: _otherStyleController,
          setOthersSelected: (selected) => _othersSelected = selected,
        );
      });
    }
  }

  void _applySportDefaults(String sportId) {
    _applyBodyAdjustedTargets(
      sportId: sportId,
      heightCm: double.tryParse(_heightController.text.trim()) ?? 170,
      weightKg: double.tryParse(_weightController.text.trim()) ?? 70,
    );
  }

  String get _nutritionSportId {
    if (_playsSport != true) {
      return 'none';
    }
    return _selectedSportId ?? 'other';
  }

  bool get _hasSelectedSportProfile {
    if (_playsSport != true) {
      return true;
    }
    if (_selectedSportId == null) {
      return false;
    }
    if (_selectedSportId == 'other') {
      final name = _selectedSportName ?? _otherSportController.text.trim();
      return name.isNotEmpty;
    }
    return _selectedSportName?.trim().isNotEmpty == true;
  }

  void _applyBodyAdjustedTargets({
    required String sportId,
    required double heightCm,
    required double weightKg,
  }) {
    final sport = _sportTargets[sportId] ?? _sportTargets['other']!;
    final weightFactor = (weightKg / 70).clamp(0.85, 1.30);

    final calories = (sport.caloriesKcal * weightFactor).round();
    final protein = (weightKg * 1.8).round().clamp(80, 250);
    final fats = (weightKg * 0.9).round().clamp(45, 120);
    var remainingCalories = calories - (protein * 4) - (fats * 9);
    if (remainingCalories < 400) {
      remainingCalories = 400;
    }
    final carbs = (remainingCalories / 4).round().clamp(150, 700);

    _caloriesController.text = calories.toString();
    _proteinController.text = protein.toString();
    _carbsController.text = carbs.toString();
    _fatsController.text = fats.toString();
    _lastDerivedSportId = sportId;
    _lastDerivedHeightCm = heightCm;
    _lastDerivedWeightKg = weightKg;
  }

  Future<void> _goToPage(int page) async {
    await _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    if (!mounted) return;
    setState(() => _currentPage = page);

    if (page == 7 &&
        (_lastDerivedSportId != _nutritionSportId ||
            _lastDerivedHeightCm !=
                double.tryParse(_heightController.text.trim()) ||
            _lastDerivedWeightKg !=
                double.tryParse(_weightController.text.trim()))) {
      _applyBodyAdjustedTargets(
        sportId: _nutritionSportId,
        heightCm: double.parse(_heightController.text.trim()),
        weightKg: double.parse(_weightController.text.trim()),
      );
    }
  }

  void _goBack() {
    if (_currentPage > 0) {
      _goToPage(_currentPage - 1);
    }
  }

  Future<void> _finishOnboarding() async {
    if (!_goalsFormKey.currentState!.validate()) return;
    if (_playsSport == null || !_hasSelectedSportProfile) return;

    final scope = UserScope.of(context);
    final l10n = AppLocalizations.of(context)!;
    final uid = scope.uid;
    final now = DateTime.now().toUtc();
    final profileSportId = _playsSport! ? (_selectedSportId ?? '') : '';
    final profileSportName = _playsSport! ? (_selectedSportName ?? '') : '';
    final targets = _sportTargets[_nutritionSportId] ?? _sportTargets['other']!;
    final sleepRecommendation = _sleepRecommendation(l10n);

    final graduationText = _graduationController.text.trim();
    final graduationYear = graduationText.isEmpty
        ? null
        : int.parse(graduationText);
    final heightCm = double.parse(_heightController.text.trim());
    final weightKg = double.parse(_weightController.text.trim());

    final profile =
        UserProfile.emptyShell(
          userId: uid,
          now: now,
          timezone: _timezone,
        ).copyWith(
          displayName: _nameController.text.trim(),
          schoolName: _schoolController.text.trim().isEmpty
              ? null
              : _schoolController.text.trim(),
          graduationYear: graduationYear,
          primarySportId: profileSportId,
          primarySportName: profileSportName,
          heightCm: heightCm,
          weightKg: weightKg,
          dietaryProfile: dietaryProfileFromForm(
            selectedStyles: _selectedStyles,
            allergensText: _allergensController.text,
            restrictionsText: _restrictionsController.text,
            otherStyleText: _otherStyleController.text,
            othersSelected: _othersSelected,
          ),
          nutritionSettings: NutritionSettings(mealsPerDay: _mealsPerDay),
          dailyTargets: DailyTargets(
            caloriesKcal: int.parse(_caloriesController.text.trim()),
            proteinG: int.parse(_proteinController.text.trim()),
            carbsG: int.parse(_carbsController.text.trim()),
            fatsG: int.parse(_fatsController.text.trim()),
            hydrationLiters: targets.hydrationLiters,
            sleepHours: 8,
            source: DailyTargetsSource.onboarding,
            effectiveFrom: now,
          ),
          sleepModeEnabled: _sleepModeEnabled,
          sleepModeRecommended: sleepRecommendation.recommended,
          sleepModeRecommendationReasons: sleepRecommendation.reasons,
          notificationSettings: NotificationSettings(
            mealRemindersEnabled: true,
            bedtimeReminderEnabled: _sleepReminderAnswer == l10n.yes,
          ),
        );

    setState(() => _saving = true);

    try {
      final settings = AppSettingsScope.maybeOf(context);
      await scope.repository.completeOnboarding(uid: uid, profile: profile);
      await settings?.reload(repository: scope.repository, uid: uid);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AppShell()),
        (_) => false,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$error')));
    }
  }

  ButtonStyle get _primaryButtonStyle => FilledButton.styleFrom(
    backgroundColor: AppColors.lime,
    foregroundColor: AppColors.onLime,
  );

  _SleepRecommendation _sleepRecommendation(AppLocalizations l10n) {
    final reasons = <String>[];
    var moderateSignals = 0;

    if (_wakeTiredAnswer == 'Often') {
      reasons.add(l10n.onboardingSleepReasonWakeTired);
    } else if (_wakeTiredAnswer == 'Sometimes') {
      moderateSignals++;
    }

    if (_bedtimeConsistencyAnswer == 'Often') {
      reasons.add(l10n.onboardingSleepReasonBedtimeChanges);
    } else if (_bedtimeConsistencyAnswer == 'Sometimes') {
      moderateSignals++;
    }

    if (_sleepReminderAnswer == 'Yes') {
      reasons.add(l10n.onboardingSleepReasonReminder);
    } else if (_sleepReminderAnswer == 'Maybe') {
      moderateSignals++;
    }

    final recommended = reasons.isNotEmpty || moderateSignals >= 2;
    if (recommended && reasons.isEmpty) {
      reasons.add(l10n.onboardingSleepReasonSteadierRoutine);
    }

    return _SleepRecommendation(recommended: recommended, reasons: reasons);
  }

  bool get _sleepQuestionsComplete =>
      _wakeTiredAnswer != null &&
      _bedtimeConsistencyAnswer != null &&
      _sleepReminderAnswer != null;

  void _continueFromSleepStep({required bool enableSleepMode}) {
    if (!_sleepQuestionsComplete) {
      return;
    }
    setState(() => _sleepModeEnabled = enableSleepMode);
    _goToPage(6);
  }

  void _continueFromMealPrefsStep() {
    _goToPage(5);
  }

  void _continueFromBodyStep() {
    if (!_bodyFormKey.currentState!.validate()) {
      return;
    }

    _applyBodyAdjustedTargets(
      sportId: _nutritionSportId,
      heightCm: double.parse(_heightController.text.trim()),
      weightKg: double.parse(_weightController.text.trim()),
    );
    _goToPage(7);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: _dismissKeyboard,
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (page) => setState(() => _currentPage = page),
            children: [
              _WelcomeStep(
                onGetStarted: () => _goToPage(1),
                primaryButtonStyle: _primaryButtonStyle,
              ),
              _OnboardingStepShell(
                currentStep: 2,
                totalSteps: _totalSteps,
                showProgress: true,
                showBack: true,
                onBack: _goBack,
                child: _NameStep(
                  formKey: _nameFormKey,
                  nameController: _nameController,
                  onContinue: () {
                    if (_nameFormKey.currentState!.validate()) {
                      _goToPage(2);
                    }
                  },
                  primaryButtonStyle: _primaryButtonStyle,
                ),
              ),
              _OnboardingStepShell(
                currentStep: 3,
                totalSteps: _totalSteps,
                showProgress: true,
                showBack: true,
                onBack: _goBack,
                child: _SportStep(
                  formKey: _sportFormKey,
                  playsSport: _playsSport,
                  selectedSportId: _selectedSportId,
                  otherSportController: _otherSportController,
                  onPlaysSportChanged: (playsSport) {
                    setState(() {
                      _playsSport = playsSport;
                      if (!playsSport) {
                        _selectedSportId = null;
                        _selectedSportName = null;
                        _otherSportController.clear();
                      }
                    });
                  },
                  onSportSelected: (id, name) {
                    setState(() {
                      _selectedSportId = id;
                      if (id == 'other') {
                        _selectedSportName = null;
                      } else {
                        _selectedSportName = name;
                        _otherSportController.clear();
                      }
                    });
                  },
                  onContinue: () {
                    if (_playsSport == null) {
                      return;
                    }
                    if (!_playsSport!) {
                      _applySportDefaults('none');
                      _goToPage(3);
                      return;
                    }
                    if (_selectedSportId == null) {
                      return;
                    }
                    if (_selectedSportId == 'other') {
                      if (!_sportFormKey.currentState!.validate()) {
                        return;
                      }
                      _selectedSportName = _otherSportController.text.trim();
                    }
                    _applySportDefaults(_selectedSportId!);
                    _goToPage(3);
                  },
                  primaryButtonStyle: _primaryButtonStyle,
                ),
              ),
              _OnboardingStepShell(
                currentStep: 4,
                totalSteps: _totalSteps,
                showProgress: true,
                showBack: true,
                onBack: _goBack,
                child: _SchoolStep(
                  formKey: _schoolFormKey,
                  schoolController: _schoolController,
                  graduationController: _graduationController,
                  onContinue: () {
                    if (_schoolFormKey.currentState!.validate()) {
                      _goToPage(4);
                    }
                  },
                  primaryButtonStyle: _primaryButtonStyle,
                ),
              ),
              _OnboardingStepShell(
                currentStep: 5,
                totalSteps: _totalSteps,
                showProgress: true,
                showBack: true,
                onBack: _goBack,
                child: _MealPreferencesStep(
                  formKey: _mealPrefsFormKey,
                  selectedStyles: _selectedStyles,
                  mealsPerDay: _mealsPerDay,
                  onMealsPerDayChanged: (value) {
                    setState(() => _mealsPerDay = value);
                  },
                  onStyleToggled: (style) {
                    setState(() {
                      if (_selectedStyles.contains(style)) {
                        _selectedStyles.remove(style);
                      } else {
                        _selectedStyles.add(style);
                      }
                    });
                  },
                  allergensController: _allergensController,
                  restrictionsController: _restrictionsController,
                  otherStyleController: _otherStyleController,
                  othersSelected: _othersSelected,
                  onOthersSelectedChanged: (selected) {
                    setState(() => _othersSelected = selected);
                  },
                  onContinue: _continueFromMealPrefsStep,
                  primaryButtonStyle: _primaryButtonStyle,
                ),
              ),
              _OnboardingStepShell(
                currentStep: 6,
                totalSteps: _totalSteps,
                showProgress: true,
                showBack: true,
                onBack: _goBack,
                child: _SleepModeStep(
                  wakeTiredAnswer: _wakeTiredAnswer,
                  bedtimeConsistencyAnswer: _bedtimeConsistencyAnswer,
                  sleepReminderAnswer: _sleepReminderAnswer,
                  recommendation: _sleepRecommendation(l10n),
                  questionsComplete: _sleepQuestionsComplete,
                  onWakeTiredChanged: (value) {
                    setState(() => _wakeTiredAnswer = value);
                  },
                  onBedtimeConsistencyChanged: (value) {
                    setState(() => _bedtimeConsistencyAnswer = value);
                  },
                  onSleepReminderChanged: (value) {
                    setState(() => _sleepReminderAnswer = value);
                  },
                  onUseSleepMode: () =>
                      _continueFromSleepStep(enableSleepMode: true),
                  onSkipSleepMode: () =>
                      _continueFromSleepStep(enableSleepMode: false),
                  primaryButtonStyle: _primaryButtonStyle,
                ),
              ),
              _OnboardingStepShell(
                currentStep: 7,
                totalSteps: _totalSteps,
                showProgress: true,
                showBack: true,
                onBack: _goBack,
                child: _BodyMetricsStep(
                  formKey: _bodyFormKey,
                  heightController: _heightController,
                  weightController: _weightController,
                  onContinue: _continueFromBodyStep,
                  primaryButtonStyle: _primaryButtonStyle,
                ),
              ),
              _OnboardingStepShell(
                currentStep: 8,
                totalSteps: _totalSteps,
                showProgress: true,
                showBack: true,
                onBack: _goBack,
                child: _GoalsStep(
                  formKey: _goalsFormKey,
                  hasSport: _playsSport == true,
                  caloriesController: _caloriesController,
                  proteinController: _proteinController,
                  carbsController: _carbsController,
                  fatsController: _fatsController,
                  saving: _saving,
                  onFinish: _finishOnboarding,
                  primaryButtonStyle: _primaryButtonStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _dismissKeyboard() {
  FocusManager.instance.primaryFocus?.unfocus();
}

class _OnboardingScrollStep extends StatelessWidget {
  const _OnboardingScrollStep({
    required this.formKey,
    required this.content,
    required this.bottom,
  });

  final GlobalKey<FormState> formKey;
  final Widget content;
  final Widget bottom;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: content,
            ),
          ),
          const SizedBox(height: 16),
          bottom,
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _OnboardingStepShell extends StatelessWidget {
  const _OnboardingStepShell({
    required this.currentStep,
    required this.totalSteps,
    required this.showProgress,
    required this.showBack,
    required this.onBack,
    required this.child,
  });

  final int currentStep;
  final int totalSteps;
  final bool showProgress;
  final bool showBack;
  final VoidCallback onBack;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showProgress)
          LinearProgressIndicator(
            value: currentStep / totalSteps,
            color: AppColors.lime,
            backgroundColor: AppColors.cardDark,
            minHeight: 3,
          ),
        if (showBack)
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back),
              color: AppColors.textPrimary,
            ),
          )
        else
          const SizedBox(height: 48),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: child,
          ),
        ),
      ],
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({
    required this.onGetStarted,
    required this.primaryButtonStyle,
  });

  final VoidCallback onGetStarted;
  final ButtonStyle primaryButtonStyle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.onboardingWelcomeTitle,
            style: textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.onboardingWelcomeSubtitle,
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: onGetStarted,
              style: primaryButtonStyle,
              child: Text(l10n.onboardingGetStarted),
            ),
          ),
        ],
      ),
    );
  }
}

class _NameStep extends StatelessWidget {
  const _NameStep({
    required this.formKey,
    required this.nameController,
    required this.onContinue,
    required this.primaryButtonStyle,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final VoidCallback onContinue;
  final ButtonStyle primaryButtonStyle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _OnboardingScrollStep(
      formKey: formKey,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.onboardingYourName,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          ProfileTextField(
            label: l10n.onboardingFullNameLabel,
            controller: nameController,
            limeBorder: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.nameRequired;
              }
              return null;
            },
          ),
        ],
      ),
      bottom: SizedBox(
        height: 52,
        child: FilledButton(
          onPressed: onContinue,
          style: primaryButtonStyle,
          child: Text(l10n.continueButton),
        ),
      ),
    );
  }
}

class _SportStep extends StatelessWidget {
  const _SportStep({
    required this.formKey,
    required this.playsSport,
    required this.selectedSportId,
    required this.otherSportController,
    required this.onPlaysSportChanged,
    required this.onSportSelected,
    required this.onContinue,
    required this.primaryButtonStyle,
  });

  final GlobalKey<FormState> formKey;
  final bool? playsSport;
  final String? selectedSportId;
  final TextEditingController otherSportController;
  final ValueChanged<bool> onPlaysSportChanged;
  final void Function(String id, String name) onSportSelected;
  final VoidCallback onContinue;
  final ButtonStyle primaryButtonStyle;

  bool get _canContinue {
    if (playsSport == null) {
      return false;
    }
    if (playsSport == false) {
      return true;
    }
    return selectedSportId != null;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final otherSelected = selectedSportId == 'other';
    final showSportList = playsSport == true;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.onboardingAboutSport, style: textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(l10n.onboardingPlaySportQuestion, style: textTheme.bodyMedium),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: Text(l10n.onboardingPlaySportYes),
                showCheckmark: false,
                selected: playsSport == true,
                selectedColor: AppColors.lime,
                labelStyle: TextStyle(
                  color: playsSport == true
                      ? AppColors.onLime
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                backgroundColor: AppColors.fitnessBlack,
                side: BorderSide(
                  color: playsSport == true
                      ? AppColors.lime
                      : AppColors.textMuted.withValues(alpha: 0.24),
                ),
                onSelected: (_) => onPlaysSportChanged(true),
              ),
              ChoiceChip(
                label: Text(l10n.onboardingPlaySportNo),
                showCheckmark: false,
                selected: playsSport == false,
                selectedColor: AppColors.lime,
                labelStyle: TextStyle(
                  color: playsSport == false
                      ? AppColors.onLime
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                backgroundColor: AppColors.fitnessBlack,
                side: BorderSide(
                  color: playsSport == false
                      ? AppColors.lime
                      : AppColors.textMuted.withValues(alpha: 0.24),
                ),
                onSelected: (_) => onPlaysSportChanged(false),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: showSportList
                ? ListView.separated(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: _sports.length + (otherSelected ? 1 : 0),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (otherSelected && index == _sports.length) {
                        return ProfileTextField(
                          key: const Key('onboarding_other_sport'),
                          label: l10n.onboardingYourSportLabel,
                          controller: otherSportController,
                          limeBorder: true,
                          validator: (value) {
                            if (!otherSelected) return null;
                            if (value == null || value.trim().isEmpty) {
                              return l10n.onboardingEnterSport;
                            }
                            return null;
                          },
                        );
                      }

                      final sport = _sports[index];
                      final isSelected = selectedSportId == sport.id;

                      return Material(
                        color: isSelected
                            ? AppColors.lime.withValues(alpha: 0.12)
                            : AppColors.cardDark,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: () => onSportSelected(
                            sport.id,
                            localizedSportName(l10n, sport.id),
                          ),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.lime
                                    : AppColors.cardDark,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    localizedSportName(l10n, sport.id),
                                    style: textTheme.titleMedium,
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: AppColors.lime,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      playsSport == false
                          ? l10n.onboardingNoSportTargets
                          : l10n.onboardingChooseOption,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                        height: 1.35,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: _canContinue ? onContinue : null,
              style: primaryButtonStyle,
              child: Text(l10n.continueButton),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SchoolStep extends StatelessWidget {
  const _SchoolStep({
    required this.formKey,
    required this.schoolController,
    required this.graduationController,
    required this.onContinue,
    required this.primaryButtonStyle,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController schoolController;
  final TextEditingController graduationController;
  final VoidCallback onContinue;
  final ButtonStyle primaryButtonStyle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _OnboardingScrollStep(
      formKey: formKey,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.onboardingYourSchool,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          ProfileTextField(
            label: l10n.onboardingSchoolNameLabel,
            controller: schoolController,
            limeBorder: true,
          ),
          const SizedBox(height: 20),
          ProfileTextField(
            label: l10n.onboardingGraduationYearLabel,
            controller: graduationController,
            keyboardType: TextInputType.number,
            limeBorder: true,
            validator: (value) {
              final trimmed = value?.trim() ?? '';
              if (trimmed.isEmpty) return null;
              if (!RegExp(r'^\d{4}$').hasMatch(trimmed)) {
                return l10n.onboardingEnterFourDigitYear;
              }
              return null;
            },
          ),
        ],
      ),
      bottom: SizedBox(
        height: 52,
        child: FilledButton(
          onPressed: onContinue,
          style: primaryButtonStyle,
          child: Text(l10n.continueButton),
        ),
      ),
    );
  }
}

class _SleepRecommendation {
  const _SleepRecommendation({
    required this.recommended,
    required this.reasons,
  });

  final bool recommended;
  final List<String> reasons;
}

class _SleepModeStep extends StatelessWidget {
  const _SleepModeStep({
    required this.wakeTiredAnswer,
    required this.bedtimeConsistencyAnswer,
    required this.sleepReminderAnswer,
    required this.recommendation,
    required this.questionsComplete,
    required this.onWakeTiredChanged,
    required this.onBedtimeConsistencyChanged,
    required this.onSleepReminderChanged,
    required this.onUseSleepMode,
    required this.onSkipSleepMode,
    required this.primaryButtonStyle,
  });

  final String? wakeTiredAnswer;
  final String? bedtimeConsistencyAnswer;
  final String? sleepReminderAnswer;
  final _SleepRecommendation recommendation;
  final bool questionsComplete;
  final ValueChanged<String?> onWakeTiredChanged;
  final ValueChanged<String?> onBedtimeConsistencyChanged;
  final ValueChanged<String?> onSleepReminderChanged;
  final VoidCallback onUseSleepMode;
  final VoidCallback onSkipSleepMode;
  final ButtonStyle primaryButtonStyle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final recommended = recommendation.recommended;

    final useSleepButton = SizedBox(
      height: 52,
      child: FilledButton(
        onPressed: questionsComplete ? onUseSleepMode : null,
        style: primaryButtonStyle,
        child: Text(l10n.onboardingUseSleepMode),
      ),
    );
    final skipButton = SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: questionsComplete ? onSkipSleepMode : null,
        child: Text(l10n.skipForNow),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.only(bottom: 8),
            children: [
              Text(l10n.onboardingSleepCheck, style: textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(l10n.onboardingSleepCheckIntro, style: textTheme.bodyMedium),
              const SizedBox(height: 24),
              _SleepQuestionCard(
                step: 1,
                question: l10n.sleepQuestionWakeTired,
                hint: l10n.sleepQuestionWakeTiredHint,
                options: [
                  l10n.sleepAnswerNotOften,
                  l10n.sleepAnswerSometimes,
                  l10n.sleepAnswerOften,
                ],
                selected: wakeTiredAnswer,
                onSelected: onWakeTiredChanged,
              ),
              const SizedBox(height: 16),
              _SleepQuestionCard(
                step: 2,
                question: l10n.sleepQuestionBedtimeChanges,
                hint: l10n.sleepQuestionBedtimeChangesHint,
                options: [
                  l10n.sleepAnswerNotOften,
                  l10n.sleepAnswerSometimes,
                  l10n.sleepAnswerOften,
                ],
                selected: bedtimeConsistencyAnswer,
                onSelected: onBedtimeConsistencyChanged,
              ),
              const SizedBox(height: 16),
              _SleepQuestionCard(
                step: 3,
                question: l10n.sleepQuestionReminder,
                hint: l10n.sleepQuestionReminderHint,
                options: [l10n.no, l10n.maybe, l10n.yes],
                selected: sleepReminderAnswer,
                onSelected: onSleepReminderChanged,
              ),
            ],
          ),
        ),
        if (questionsComplete) ...[
          _SleepRecommendationCard(recommendation: recommendation),
          const SizedBox(height: 16),
        ],
        if (recommended) ...[
          useSleepButton,
          const SizedBox(height: 12),
          skipButton,
        ] else ...[
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: questionsComplete ? onSkipSleepMode : null,
              style: primaryButtonStyle,
              child: Text(l10n.skipForNow),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: questionsComplete ? onUseSleepMode : null,
            child: Text(l10n.onboardingUseSleepMode),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SleepQuestionCard extends StatelessWidget {
  const _SleepQuestionCard({
    required this.step,
    required this.question,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.hint,
  });

  final int step;
  final String question;
  final String? hint;
  final List<String> options;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardDarker),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('$step. $question', style: textTheme.titleMedium),
          if (hint != null) ...[
            const SizedBox(height: 6),
            Text(
              hint!,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in options)
                ChoiceChip(
                  label: Text(option),
                  showCheckmark: false,
                  selected: selected == option,
                  selectedColor: AppColors.lime,
                  labelStyle: TextStyle(
                    color: selected == option
                        ? AppColors.onLime
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  backgroundColor: AppColors.fitnessBlack,
                  side: BorderSide(
                    color: selected == option
                        ? AppColors.lime
                        : AppColors.textMuted.withValues(alpha: 0.24),
                  ),
                  onSelected: (isSelected) {
                    onSelected(isSelected ? option : null);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SleepRecommendationCard extends StatelessWidget {
  const _SleepRecommendationCard({required this.recommendation});

  final _SleepRecommendation recommendation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final recommended = recommendation.recommended;
    final title = recommended
        ? l10n.onboardingSleepRecommended
        : l10n.onboardingSleepOptional;
    final message = recommended
        ? (recommendation.reasons.length == 1
              ? recommendation.reasons.first
              : l10n.onboardingSleepRecommendation)
        : l10n.onboardingSleepOptionalBody;

    return Container(
      key: ValueKey(recommended),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: recommended
            ? AppColors.sleepAccent.withValues(alpha: 0.18)
            : AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: recommended
              ? AppColors.sleepAccent
              : AppColors.textMuted.withValues(alpha: 0.24),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            recommended ? Icons.nightlight_round : Icons.check_circle_outline,
            color: recommended ? AppColors.sleepAccent : AppColors.lime,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MealPreferencesStep extends StatelessWidget {
  const _MealPreferencesStep({
    required this.formKey,
    required this.selectedStyles,
    required this.mealsPerDay,
    required this.onMealsPerDayChanged,
    required this.onStyleToggled,
    required this.allergensController,
    required this.restrictionsController,
    required this.otherStyleController,
    required this.othersSelected,
    required this.onOthersSelectedChanged,
    required this.onContinue,
    required this.primaryButtonStyle,
  });

  final GlobalKey<FormState> formKey;
  final Set<String> selectedStyles;
  final int mealsPerDay;
  final ValueChanged<int> onMealsPerDayChanged;
  final ValueChanged<String> onStyleToggled;
  final TextEditingController allergensController;
  final TextEditingController restrictionsController;
  final TextEditingController otherStyleController;
  final bool othersSelected;
  final ValueChanged<bool> onOthersSelectedChanged;
  final VoidCallback onContinue;
  final ButtonStyle primaryButtonStyle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _OnboardingScrollStep(
      formKey: formKey,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.authMealPreferences,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.authMealPreferencesHint,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          MealPreferencesForm(
            selectedStyles: selectedStyles,
            onStyleToggled: onStyleToggled,
            allergensController: allergensController,
            restrictionsController: restrictionsController,
            otherStyleController: otherStyleController,
            othersSelected: othersSelected,
            onOthersSelectedChanged: onOthersSelectedChanged,
            useLimeBorders: true,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.authMealsPerDay,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.authMealsPerDayHint,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          SegmentedButton<int>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: 2, label: Text('2')),
              ButtonSegment(value: 3, label: Text('3')),
              ButtonSegment(value: 4, label: Text('4')),
              ButtonSegment(value: 5, label: Text('5')),
            ],
            selected: {mealsPerDay},
            onSelectionChanged: (selection) {
              onMealsPerDayChanged(selection.first);
            },
          ),
        ],
      ),
      bottom: SizedBox(
        height: 52,
        child: FilledButton(
          onPressed: onContinue,
          style: primaryButtonStyle,
          child: Text(l10n.continueButton),
        ),
      ),
    );
  }
}

class _BodyMetricsStep extends StatelessWidget {
  const _BodyMetricsStep({
    required this.formKey,
    required this.heightController,
    required this.weightController,
    required this.onContinue,
    required this.primaryButtonStyle,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController heightController;
  final TextEditingController weightController;
  final VoidCallback onContinue;
  final ButtonStyle primaryButtonStyle;

  static const _maxHeightCm = 300;
  static const _maxWeightKg = 700;

  String? _heightValidator(AppLocalizations l10n, String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return l10n.required;
    final parsed = double.tryParse(trimmed);
    if (parsed == null || parsed <= 0) return l10n.enterPositiveNumber;
    if (parsed > _maxHeightCm)
      return l10n.onboardingMaximumHeight(_maxHeightCm);
    return null;
  }

  String? _weightValidator(AppLocalizations l10n, String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return l10n.required;
    final parsed = double.tryParse(trimmed);
    if (parsed == null || parsed <= 0) return l10n.enterPositiveNumber;
    if (parsed > _maxWeightKg)
      return l10n.onboardingMaximumWeight(_maxWeightKg);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _OnboardingScrollStep(
      formKey: formKey,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.onboardingBodyMetrics,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingBodyMetricsHint,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ProfileTextField(
            key: const Key('onboarding_height_cm'),
            label: l10n.onboardingHeightLabel,
            controller: heightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            allowDecimal: true,
            limeBorder: true,
            validator: (value) => _heightValidator(l10n, value),
          ),
          const SizedBox(height: 16),
          ProfileTextField(
            key: const Key('onboarding_weight_kg'),
            label: l10n.onboardingWeightLabel,
            controller: weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            allowDecimal: true,
            limeBorder: true,
            validator: (value) => _weightValidator(l10n, value),
          ),
        ],
      ),
      bottom: SizedBox(
        height: 52,
        child: FilledButton(
          onPressed: onContinue,
          style: primaryButtonStyle,
          child: Text(l10n.continueButton),
        ),
      ),
    );
  }
}

class _GoalsStep extends StatelessWidget {
  const _GoalsStep({
    required this.formKey,
    required this.hasSport,
    required this.caloriesController,
    required this.proteinController,
    required this.carbsController,
    required this.fatsController,
    required this.saving,
    required this.onFinish,
    required this.primaryButtonStyle,
  });

  final GlobalKey<FormState> formKey;
  final bool hasSport;
  final TextEditingController caloriesController;
  final TextEditingController proteinController;
  final TextEditingController carbsController;
  final TextEditingController fatsController;
  final bool saving;
  final VoidCallback onFinish;
  final ButtonStyle primaryButtonStyle;

  String? _positiveIntValidator(AppLocalizations l10n, String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return l10n.required;
    final parsed = int.tryParse(trimmed);
    if (parsed == null || parsed <= 0) return l10n.enterPositiveNumber;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _OnboardingScrollStep(
      formKey: formKey,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.onboardingNutritionTargets,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            hasSport
                ? l10n.onboardingTargetsFromSport
                : l10n.onboardingTargetsFromMetrics,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ProfileTextField(
            label: l10n.caloriesKcal,
            controller: caloriesController,
            keyboardType: TextInputType.number,
            limeBorder: true,
            validator: (value) => _positiveIntValidator(l10n, value),
          ),
          const SizedBox(height: 16),
          ProfileTextField(
            label: l10n.proteinG,
            controller: proteinController,
            keyboardType: TextInputType.number,
            limeBorder: true,
            validator: (value) => _positiveIntValidator(l10n, value),
          ),
          const SizedBox(height: 16),
          ProfileTextField(
            label: l10n.carbsG,
            controller: carbsController,
            keyboardType: TextInputType.number,
            limeBorder: true,
            validator: (value) => _positiveIntValidator(l10n, value),
          ),
          const SizedBox(height: 16),
          ProfileTextField(
            label: l10n.fatsG,
            controller: fatsController,
            keyboardType: TextInputType.number,
            limeBorder: true,
            validator: (value) => _positiveIntValidator(l10n, value),
          ),
        ],
      ),
      bottom: SizedBox(
        height: 52,
        child: FilledButton(
          onPressed: saving ? null : onFinish,
          style: primaryButtonStyle,
          child: saving
              ? const CircularProgressIndicator(color: AppColors.onLime)
              : Text(l10n.finishSetup),
        ),
      ),
    );
  }
}
