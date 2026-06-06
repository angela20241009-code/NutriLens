import 'package:flutter/material.dart';
import 'package:nutrilens/app/user_scope.dart';
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
  static const _totalSteps = 5;

  final _pageController = PageController();
  final _nameFormKey = GlobalKey<FormState>();
  final _schoolFormKey = GlobalKey<FormState>();
  final _goalsFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _schoolController = TextEditingController();
  final _graduationController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatsController = TextEditingController();

  String? _selectedSportId;
  String? _selectedSportName;
  String? _lastDerivedSportId;
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
      setState(() => _timezone = profile.timezone);
    }
  }

  void _applySportDefaults(String sportId) {
    final targets = _sportTargets[sportId] ?? _sportTargets['other']!;
    _caloriesController.text = targets.caloriesKcal.toString();
    _proteinController.text = targets.proteinG.toString();
    _carbsController.text = targets.carbsG.toString();
    _fatsController.text = targets.fatsG.toString();
    _lastDerivedSportId = sportId;
  }

  Future<void> _goToPage(int page) async {
    await _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    if (!mounted) return;
    setState(() => _currentPage = page);

    if (page == 4 &&
        _selectedSportId != null &&
        _selectedSportId != _lastDerivedSportId) {
      _applySportDefaults(_selectedSportId!);
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

    final graduationText = _graduationController.text.trim();
    final graduationYear = graduationText.isEmpty
        ? null
        : int.parse(graduationText);

    final profile = UserProfile.emptyShell(
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
    );

    setState(() => _saving = true);

    try {
      await scope.repository.completeOnboarding(uid: uid, profile: profile);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AppShell()),
        (_) => false,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error')),
      );
    }
  }

  ButtonStyle get _primaryButtonStyle => FilledButton.styleFrom(
    backgroundColor: AppColors.lime,
    foregroundColor: AppColors.onLime,
  );

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
          Text(
            'Your name',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Daily nutrition targets',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'We pre-filled these from your sport. You can adjust.',
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
                  ? const CircularProgressIndicator(color: AppColors.onLime)
                  : const Text('Finish setup'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
