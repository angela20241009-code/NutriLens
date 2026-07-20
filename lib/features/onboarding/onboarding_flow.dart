import 'package:flutter/material.dart';
import 'package:nutrilens/app/app_settings_scope.dart';
import 'package:nutrilens/app/user_scope.dart';
import 'package:nutrilens/features/profile/meal_preferences_form.dart';
import 'package:nutrilens/features/profile/widgets/profile_text_field.dart';
import 'package:nutrilens/features/shell/app_shell.dart';
import 'package:nutrilens/models/daily_targets.dart';
import 'package:nutrilens/models/user_profile.dart';
import 'package:nutrilens/theme/app_colors.dart';

const _sports = <({String id, String name})>[
  (id: 'tennis', name: 'Tennis'),
  (id: 'basketball', name: 'Basketball'),
  (id: 'soccer', name: 'Soccer'),
  (id: 'swimming', name: 'Swimming'),
  (id: 'track_and_field', name: 'Track & Field'),
  (id: 'other', name: 'Other'),
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
  'other': _SportTargets(
    caloriesKcal: 2800,
    proteinG: 150,
    carbsG: 350,
    fatsG: 75,
    hydrationLiters: 3.0,
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
  final _mealPrefsFormKey = GlobalKey<FormState>();
  final _bodyFormKey = GlobalKey<FormState>();
  final _goalsFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
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
  String? _lastDerivedSportId;
  double? _lastDerivedHeightCm;
  double? _lastDerivedWeightKg;
  final _selectedStyles = <String>{};
  bool _othersSelected = false;
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
        _selectedSportId != null &&
        (_selectedSportId != _lastDerivedSportId ||
            _lastDerivedHeightCm !=
                double.tryParse(_heightController.text.trim()) ||
            _lastDerivedWeightKg !=
                double.tryParse(_weightController.text.trim()))) {
      _applyBodyAdjustedTargets(
        sportId: _selectedSportId!,
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
    if (_selectedSportId == null || _selectedSportName == null) return;

    final scope = UserScope.of(context);
    final uid = scope.uid;
    final now = DateTime.now().toUtc();
    final sportId = _selectedSportId!;
    final targets = _sportTargets[sportId] ?? _sportTargets['other']!;
    final sleepRecommendation = _sleepRecommendation;

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
          primarySportId: sportId,
          primarySportName: _selectedSportName!,
          heightCm: heightCm,
          weightKg: weightKg,
          dietaryProfile: dietaryProfileFromForm(
            selectedStyles: _selectedStyles,
            allergensText: _allergensController.text,
            restrictionsText: _restrictionsController.text,
            otherStyleText: _otherStyleController.text,
            othersSelected: _othersSelected,
          ),
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

  _SleepRecommendation get _sleepRecommendation {
    final reasons = <String>[];
    var moderateSignals = 0;

    if (_wakeTiredAnswer == 'Most days') {
      reasons.add('You often wake up tired.');
    } else if (_wakeTiredAnswer == 'Sometimes') {
      moderateSignals++;
    }

    if (_bedtimeConsistencyAnswer == 'Often') {
      reasons.add('Your bedtime is often inconsistent.');
    } else if (_bedtimeConsistencyAnswer == 'Sometimes') {
      moderateSignals++;
    }

    if (_sleepReminderAnswer == 'Yes') {
      reasons.add('Sleep reminders could support recovery.');
    } else if (_sleepReminderAnswer == 'Maybe') {
      moderateSignals++;
    }

    final recommended = reasons.isNotEmpty || moderateSignals >= 2;
    if (recommended && reasons.isEmpty) {
      reasons.add('A few small sleep habits could improve recovery.');
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
    if (!_bodyFormKey.currentState!.validate() || _selectedSportId == null) {
      return;
    }

    _applyBodyAdjustedTargets(
      sportId: _selectedSportId!,
      heightCm: double.parse(_heightController.text.trim()),
      weightKg: double.parse(_weightController.text.trim()),
    );
    _goToPage(7);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                selectedSportId: _selectedSportId,
                onSportSelected: (id, name) {
                  setState(() {
                    _selectedSportId = id;
                    _selectedSportName = name;
                  });
                },
                onContinue: () {
                  if (_selectedSportId != null) {
                    _applySportDefaults(_selectedSportId!);
                    _goToPage(3);
                  }
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
                recommendation: _sleepRecommendation,
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'NutriLens',
            style: textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Fuel smarter. Train harder.',
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: onGetStarted,
              style: primaryButtonStyle,
              child: const Text('Get started'),
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
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Your name', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          ProfileTextField(
            label: 'FULL NAME',
            controller: nameController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Name is required';
              }
              return null;
            },
          ),
          const Spacer(),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: onContinue,
              style: primaryButtonStyle,
              child: const Text('Continue'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SportStep extends StatelessWidget {
  const _SportStep({
    required this.selectedSportId,
    required this.onSportSelected,
    required this.onContinue,
    required this.primaryButtonStyle,
  });

  final String? selectedSportId;
  final void Function(String id, String name) onSportSelected;
  final VoidCallback onContinue;
  final ButtonStyle primaryButtonStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "What's your primary sport?",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.separated(
            itemCount: _sports.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final sport = _sports[index];
              final isSelected = selectedSportId == sport.id;

              return Material(
                color: isSelected
                    ? AppColors.lime.withValues(alpha: 0.12)
                    : AppColors.cardDark,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () => onSportSelected(sport.id, sport.name),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.lime : AppColors.cardDark,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            sport.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle, color: AppColors.lime),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 52,
          child: FilledButton(
            onPressed: selectedSportId == null ? null : onContinue,
            style: primaryButtonStyle,
            child: const Text('Continue'),
          ),
        ),
        const SizedBox(height: 24),
      ],
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
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Your school',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          ProfileTextField(
            label: 'SCHOOL NAME (OPTIONAL)',
            controller: schoolController,
          ),
          const SizedBox(height: 20),
          ProfileTextField(
            label: 'GRADUATION YEAR (OPTIONAL)',
            controller: graduationController,
            keyboardType: TextInputType.number,
            validator: (value) {
              final trimmed = value?.trim() ?? '';
              if (trimmed.isEmpty) return null;
              if (!RegExp(r'^\d{4}$').hasMatch(trimmed)) {
                return 'Enter a 4-digit year';
              }
              return null;
            },
          ),
          const Spacer(),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: onContinue,
              style: primaryButtonStyle,
              child: const Text('Continue'),
            ),
          ),
          const SizedBox(height: 24),
        ],
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
  final ValueChanged<String> onWakeTiredChanged;
  final ValueChanged<String> onBedtimeConsistencyChanged;
  final ValueChanged<String> onSleepReminderChanged;
  final VoidCallback onUseSleepMode;
  final VoidCallback onSkipSleepMode;
  final ButtonStyle primaryButtonStyle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final recommended = recommendation.recommended;

    final useSleepButton = SizedBox(
      height: 52,
      child: FilledButton(
        onPressed: questionsComplete ? onUseSleepMode : null,
        style: primaryButtonStyle,
        child: const Text('Use Sleep Mode'),
      ),
    );
    final skipButton = SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: questionsComplete ? onSkipSleepMode : null,
        child: const Text('Skip for now'),
      ),
    );

    return ListView(
      children: [
        Text('Sleep recovery', style: textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          'Answer a few quick questions so we can decide if Sleep Mode belongs in your daily setup.',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        _SleepQuestionCard(
          question: 'How often do you wake up tired?',
          options: const ['Rarely', 'Sometimes', 'Most days'],
          selected: wakeTiredAnswer,
          onSelected: onWakeTiredChanged,
        ),
        const SizedBox(height: 16),
        _SleepQuestionCard(
          question: 'Do late practices or homework make bedtime inconsistent?',
          options: const ['Rarely', 'Sometimes', 'Often'],
          selected: bedtimeConsistencyAnswer,
          onSelected: onBedtimeConsistencyChanged,
        ),
        const SizedBox(height: 16),
        _SleepQuestionCard(
          question: 'Would sleep reminders help you recover better?',
          options: const ['Yes', 'Maybe', 'No'],
          selected: sleepReminderAnswer,
          onSelected: onSleepReminderChanged,
        ),
        const SizedBox(height: 20),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: questionsComplete
              ? _SleepRecommendationCard(recommendation: recommendation)
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 20),
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
              child: const Text('Skip for now'),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: questionsComplete ? onUseSleepMode : null,
            child: const Text('Use Sleep Mode'),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SleepQuestionCard extends StatelessWidget {
  const _SleepQuestionCard({
    required this.question,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String question;
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
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
          Text(question, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in options)
                ChoiceChip(
                  label: Text(option),
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
                  onSelected: (_) => onSelected(option),
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
    final recommended = recommendation.recommended;
    final title = recommended
        ? 'Sleep Mode recommended'
        : 'Sleep Mode is optional';
    final message = recommended
        ? recommendation.reasons.join(' ')
        : 'Your answers look steady, so you can add Sleep Mode later if your schedule changes.';

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
    return Form(
      key: formKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Meal preferences',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pick food styles you like and anything you need to avoid.',
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
                    const Spacer(),
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: onContinue,
                        style: primaryButtonStyle,
                        child: const Text('Continue'),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
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

  String? _positiveNumberValidator(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Required';
    final parsed = double.tryParse(trimmed);
    if (parsed == null || parsed <= 0) return 'Enter a positive number';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Your body metrics',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We use height and weight to estimate your daily nutrition targets.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    ProfileTextField(
                      key: const Key('onboarding_height_cm'),
                      label: 'HEIGHT (CM)',
                      controller: heightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: _positiveNumberValidator,
                    ),
                    const SizedBox(height: 16),
                    ProfileTextField(
                      key: const Key('onboarding_weight_kg'),
                      label: 'WEIGHT (KG)',
                      controller: weightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: _positiveNumberValidator,
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: onContinue,
                        style: primaryButtonStyle,
                        child: const Text('Continue'),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GoalsStep extends StatelessWidget {
  const _GoalsStep({
    required this.formKey,
    required this.caloriesController,
    required this.proteinController,
    required this.carbsController,
    required this.fatsController,
    required this.saving,
    required this.onFinish,
    required this.primaryButtonStyle,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController caloriesController;
  final TextEditingController proteinController;
  final TextEditingController carbsController;
  final TextEditingController fatsController;
  final bool saving;
  final VoidCallback onFinish;
  final ButtonStyle primaryButtonStyle;

  String? _positiveIntValidator(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Required';
    final parsed = int.tryParse(trimmed);
    if (parsed == null || parsed <= 0) return 'Enter a positive number';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Daily nutrition targets',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We estimated these from your sport, height, and weight. You can adjust.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    ProfileTextField(
                      label: 'CALORIES (KCAL)',
                      controller: caloriesController,
                      keyboardType: TextInputType.number,
                      validator: _positiveIntValidator,
                    ),
                    const SizedBox(height: 16),
                    ProfileTextField(
                      label: 'PROTEIN (G)',
                      controller: proteinController,
                      keyboardType: TextInputType.number,
                      validator: _positiveIntValidator,
                    ),
                    const SizedBox(height: 16),
                    ProfileTextField(
                      label: 'CARBS (G)',
                      controller: carbsController,
                      keyboardType: TextInputType.number,
                      validator: _positiveIntValidator,
                    ),
                    const SizedBox(height: 16),
                    ProfileTextField(
                      label: 'FATS (G)',
                      controller: fatsController,
                      keyboardType: TextInputType.number,
                      validator: _positiveIntValidator,
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: saving ? null : onFinish,
                        style: primaryButtonStyle,
                        child: saving
                            ? const CircularProgressIndicator(
                                color: AppColors.onLime,
                              )
                            : const Text('Finish setup'),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
