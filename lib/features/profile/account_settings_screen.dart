import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutrilens/app/app_settings_scope.dart';
import 'package:nutrilens/app/session_scope.dart';
import 'package:nutrilens/app/user_scope.dart';
import 'package:nutrilens/features/auth/auth_screen.dart';
import 'package:nutrilens/features/profile/link_email_dialog.dart';
import 'package:nutrilens/features/profile/sign_out_dialog.dart';
import 'package:nutrilens/features/profile/widgets/profile_text_field.dart';
import 'package:nutrilens/features/profile/widgets/settings_section.dart';
import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/services/user_repository.dart';
import 'package:nutrilens/theme/app_colors.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Profile controllers
  final _displayNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _schoolController = TextEditingController();
  final _graduationYearController = TextEditingController();
  final _birthYearController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  // Nutrition controllers
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatsController = TextEditingController();
  final _hydrationController = TextEditingController();
  final _sleepHoursController = TextEditingController();

  // Diet controllers
  final _allergensController = TextEditingController();
  final _restrictionsController = TextEditingController();

  // Dropdown state
  String? _genderValue;
  String? _activityLevelValue;
  int? _trainingDaysValue;

  late UserRepository _repository;
  late String _uid;
  late Future<void> Function() _signOutUser;
  bool _hasScopes = false;

  UserProfile? _profile;
  UserAccount? _account;
  bool _loading = true;
  bool _saving = false;
  bool _busy = false;

  static const _genderOptions = {
    'female': 'Female',
    'male': 'Male',
    'non_binary': 'Non-binary',
    'prefer_not_to_say': 'Prefer not to say',
  };

  static const _activityOptions = {
    'low': 'Low',
    'moderate': 'Moderate',
    'high': 'High',
    'very_high': 'Very high',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userScope = UserScope.of(context);
    final sessionScope = SessionScope.of(context);
    final scopeChanged = !_hasScopes ||
        _repository != userScope.repository ||
        _uid != userScope.uid ||
        _signOutUser != sessionScope.signOut;

    _repository = userScope.repository;
    _uid = userScope.uid;
    _signOutUser = sessionScope.signOut;
    _hasScopes = true;

    if (scopeChanged && !_loading) {
      _loadData();
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneController.dispose();
    _schoolController.dispose();
    _graduationYearController.dispose();
    _birthYearController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    _hydrationController.dispose();
    _sleepHoursController.dispose();
    _allergensController.dispose();
    _restrictionsController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final profile = await _repository.getProfile(_uid);
      final account = await _repository.getAccount(_uid);
      if (!mounted) return;

      final p = profile ??
          UserProfile.emptyShell(
            userId: _uid,
            now: DateTime.now().toUtc(),
            timezone: 'America/Los_Angeles',
          );

      _profile = p;
      _account = account;

      _displayNameController.text = p.displayName;
      _phoneController.text = p.phoneNumber ?? '';
      _schoolController.text = p.schoolName ?? '';
      _graduationYearController.text = p.graduationYear?.toString() ?? '';
      _birthYearController.text = p.birthYear?.toString() ?? '';
      _heightController.text = p.heightCm?.toString() ?? '';
      _weightController.text = p.weightKg?.toString() ?? '';

      _caloriesController.text = p.dailyTargets.caloriesKcal.toString();
      _proteinController.text = p.dailyTargets.proteinG.toString();
      _carbsController.text = p.dailyTargets.carbsG.toString();
      _fatsController.text = p.dailyTargets.fatsG.toString();
      _hydrationController.text = p.dailyTargets.hydrationLiters.toString();
      _sleepHoursController.text = p.dailyTargets.sleepHours.toString();

      _allergensController.text = p.dietaryProfile.allergens.join('\n');
      _restrictionsController.text = p.dietaryProfile.restrictions.join('\n');

      _genderValue = p.sex;
      _activityLevelValue = p.activityLevel;
      _trainingDaysValue = p.trainingDaysPerWeek;

      setState(() => _loading = false);
    } catch (error) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to load settings: $error')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _profile == null) return;
    setState(() => _saving = true);

    try {
      final updated = _profile!.copyWith(
        displayName: _displayNameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        sex: _genderValue,
        schoolName: _schoolController.text.trim().isEmpty
            ? null
            : _schoolController.text.trim(),
        graduationYear: int.tryParse(_graduationYearController.text.trim()),
        birthYear: int.tryParse(_birthYearController.text.trim()),
        heightCm: double.tryParse(_heightController.text.trim()),
        weightKg: double.tryParse(_weightController.text.trim()),
        trainingDaysPerWeek: _trainingDaysValue,
        activityLevel: _activityLevelValue,
        dailyTargets: _profile!.dailyTargets.copyWith(
          caloriesKcal: int.tryParse(_caloriesController.text.trim()) ??
              _profile!.dailyTargets.caloriesKcal,
          proteinG: int.tryParse(_proteinController.text.trim()) ??
              _profile!.dailyTargets.proteinG,
          carbsG: int.tryParse(_carbsController.text.trim()) ??
              _profile!.dailyTargets.carbsG,
          fatsG: int.tryParse(_fatsController.text.trim()) ??
              _profile!.dailyTargets.fatsG,
          hydrationLiters:
              double.tryParse(_hydrationController.text.trim()) ??
                  _profile!.dailyTargets.hydrationLiters,
          sleepHours: double.tryParse(_sleepHoursController.text.trim()) ??
              _profile!.dailyTargets.sleepHours,
          source: DailyTargetsSource.manual,
        ),
        dietaryProfile: _profile!.dietaryProfile.copyWith(
          allergens: _splitList(_allergensController.text),
          restrictions: _splitList(_restrictionsController.text),
        ),
      );

      await _repository.saveProfile(updated);

      if (mounted) {
        setState(() {
          _profile = updated;
          _saving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Changes saved')),
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $error')),
        );
      }
    }
  }

  List<String> _splitList(String input) {
    return input
        .split(RegExp(r'[\n,]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Future<void> _linkEmail() async {
    if (_busy || _account == null) return;
    setState(() => _busy = true);

    final updated = await showLinkEmailDialog(
      context: context,
      repository: _repository,
      uid: _uid,
    );

    if (mounted) {
      setState(() {
        _busy = false;
        if (updated != null) _account = updated;
      });
      if (updated != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully')),
        );
      }
    }
  }

  Future<void> _changeEmail() async {
    if (_busy) return;
    final newEmail = await showDialog<String>(
      context: context,
      builder: (_) => _ChangeEmailDialog(currentEmail: _account?.email),
    );
    if (newEmail != null && mounted) {
      setState(() {
        _account = _account?.copyWith(email: newEmail);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification sent — check your inbox to confirm.'),
        ),
      );
    }
  }

  Future<void> _changePassword() async {
    if (_busy) return;
    final success = await showDialog<bool>(
      context: context,
      builder: (_) => _ChangePasswordDialog(email: _account?.email),
    );
    if (success == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated')),
      );
    }
  }

  Future<void> _signOut() async {
    if (_busy || _account == null) return;

    final confirmed = await showSignOutConfirmationDialog(
      context: context,
      isAnonymous: _account!.isAnonymous,
      email: _account!.email,
    );

    if (!confirmed || !mounted) return;

    setState(() => _busy = true);
    try {
      await _signOutUser();
    } catch (error) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to sign out: $error')),
        );
      }
    }
  }

  // ─── App Settings helpers ─────────────────────────────────────────────────

  Future<void> _toggleAccessibilityMode(bool enabled) async {
    final settings = AppSettingsScope.of(context);
    try {
      await settings.updateAccessibilityModeEnabled(enabled);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to update accessibility mode: $error')),
        );
      }
    }
  }

  Future<void> _toggleSleepMode(bool enabled) async {
    final settings = AppSettingsScope.of(context);
    try {
      await settings.updateSleepModeEnabled(enabled);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to update Sleep Mode: $error')),
        );
      }
    }
  }

  Future<void> _showModeSwitcherPicker() async {
    final settings = AppSettingsScope.of(context);
    final selected = await showModalBottomSheet<SegmentControlStyle>(
      context: context,
      backgroundColor: AppColors.cardDark,
      showDragHandle: true,
      builder: (context) {
        final current = settings.segmentControlStyle;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Mode switcher',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              _PickerOption(
                title: 'Minimal tabs',
                subtitle: 'Slim top tabs with an active underline.',
                selected: current == SegmentControlStyle.minimalTabs,
                onTap: () =>
                    Navigator.of(context).pop(SegmentControlStyle.minimalTabs),
              ),
              _PickerOption(
                title: 'Classic pill',
                subtitle: 'Original rounded segmented control.',
                selected: current == SegmentControlStyle.classicPill,
                onTap: () =>
                    Navigator.of(context).pop(SegmentControlStyle.classicPill),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
    if (selected == null || selected == settings.segmentControlStyle) return;
    try {
      await settings.updateSegmentControlStyle(selected);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to update mode switcher: $error')),
        );
      }
    }
  }

  Future<void> _showTextScalePicker() async {
    final settings = AppSettingsScope.of(context);
    final selected = await showModalBottomSheet<AppTextScale>(
      context: context,
      backgroundColor: AppColors.cardDark,
      showDragHandle: true,
      builder: (context) {
        final current = settings.textScale;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Text size',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              for (final scale in AppTextScale.values)
                _PickerOption(
                  title: scale.label,
                  subtitle: switch (scale) {
                    AppTextScale.small => 'Compact labels and body text.',
                    AppTextScale.medium => 'Default app text size.',
                    AppTextScale.large => 'Easier to read on most screens.',
                    AppTextScale.extraLarge => 'Maximum readability.',
                  },
                  selected: current == scale,
                  onTap: () => Navigator.of(context).pop(scale),
                ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
    if (selected == null || selected == settings.textScale) return;
    try {
      await settings.updateTextScale(selected);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to update text size: $error')),
        );
      }
    }
  }

  Future<void> _showThemePalettePicker() async {
    final settings = AppSettingsScope.of(context);
    final selected = await showModalBottomSheet<AppThemePalette>(
      context: context,
      backgroundColor: AppColors.cardDark,
      showDragHandle: true,
      builder: (context) {
        final current = settings.themePalette;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Theme colors',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              for (final palette in AppThemePalette.values)
                _PickerOption(
                  title: palette.label,
                  subtitle: 'Accent and highlight colors across the app.',
                  selected: current == palette,
                  leading: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: palette.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24),
                    ),
                  ),
                  onTap: () => Navigator.of(context).pop(palette),
                ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
    if (selected == null || selected == settings.themePalette) return;
    try {
      await settings.updateThemePalette(selected);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to update theme: $error')),
        );
      }
    }
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon')),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final appSettings = AppSettingsScope.of(context);
    final isAnonymous = _account?.isAnonymous ?? true;
    final isBusy = _saving || _busy;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Settings'),
        leading: BackButton(
          color: AppColors.lime,
          onPressed: isBusy ? null : () => Navigator.of(context).pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                    children: [
                      // ── Account ──────────────────────────────────────────
                      _sectionLabel('Account'),
                      _FormCard(
                        children: [
                          ProfileTextField(
                            label: 'Display name',
                            controller: _displayNameController,
                            enabled: !isBusy,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Name is required';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SettingsSection(
                        title: '',
                        children: [
                          SettingsRow(
                            label: 'Email',
                            value: _account?.email?.isNotEmpty == true
                                ? _account!.email!
                                : 'Not linked',
                            showChevron: !isAnonymous,
                            onTap: (!isAnonymous && !isBusy)
                                ? _changeEmail
                                : null,
                          ),
                          if (isAnonymous)
                            SettingsRow(
                              label: 'Create account',
                              onTap: isBusy ? null : _linkEmail,
                              showDivider: false,
                            )
                          else
                            SettingsRow(
                              label: 'Change password',
                              showDivider: false,
                              onTap: isBusy ? null : _changePassword,
                            ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // ── Personal ─────────────────────────────────────────
                      _sectionLabel('Personal'),
                      _FormCard(
                        children: [
                          _dropdownField<String>(
                            label: 'Gender',
                            value: _genderValue,
                            items: _genderOptions,
                            enabled: !isBusy,
                            onChanged: (v) =>
                                setState(() => _genderValue = v),
                          ),
                          const SizedBox(height: 16),
                          ProfileTextField(
                            label: 'Phone number',
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            enabled: !isBusy,
                          ),
                          const SizedBox(height: 16),
                          ProfileTextField(
                            label: 'Birth year',
                            controller: _birthYearController,
                            keyboardType: TextInputType.number,
                            enabled: !isBusy,
                            validator: (v) {
                              if (v != null &&
                                  v.trim().isNotEmpty &&
                                  int.tryParse(v.trim()) == null) {
                                return 'Enter a valid year';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ProfileTextField(
                                  label: 'Height (cm)',
                                  controller: _heightController,
                                  keyboardType: TextInputType.number,
                                  allowDecimal: true,
                                  enabled: !isBusy,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ProfileTextField(
                                  label: 'Weight (kg)',
                                  controller: _weightController,
                                  keyboardType: TextInputType.number,
                                  allowDecimal: true,
                                  enabled: !isBusy,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // ── Athlete ───────────────────────────────────────────
                      _sectionLabel('Athlete'),
                      _FormCard(
                        children: [
                          Text(
                            'Primary sport',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.cardDarker,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.cardDark),
                            ),
                            child: Text(
                              _profile?.primarySportName.isNotEmpty == true
                                  ? _profile!.primarySportName
                                  : 'No sport selected',
                              style: TextStyle(
                                color: AppColors.textMuted.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ProfileTextField(
                            label: 'School',
                            controller: _schoolController,
                            enabled: !isBusy,
                          ),
                          const SizedBox(height: 16),
                          ProfileTextField(
                            label: 'Graduation year',
                            controller: _graduationYearController,
                            keyboardType: TextInputType.number,
                            enabled: !isBusy,
                            validator: (v) {
                              if (v != null &&
                                  v.trim().isNotEmpty &&
                                  int.tryParse(v.trim()) == null) {
                                return 'Enter a valid year';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _dropdownField<int>(
                            label: 'Training days per week',
                            value: _trainingDaysValue,
                            items: {
                              for (int i = 0; i <= 7; i++) i: '$i days',
                            },
                            enabled: !isBusy,
                            onChanged: (v) =>
                                setState(() => _trainingDaysValue = v),
                          ),
                          const SizedBox(height: 16),
                          _dropdownField<String>(
                            label: 'Activity level',
                            value: _activityLevelValue,
                            items: _activityOptions,
                            enabled: !isBusy,
                            onChanged: (v) =>
                                setState(() => _activityLevelValue = v),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // ── Nutrition Goals ───────────────────────────────────
                      _sectionLabel('Nutrition Goals'),
                      _FormCard(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ProfileTextField(
                                  label: 'Calories (kcal)',
                                  controller: _caloriesController,
                                  keyboardType: TextInputType.number,
                                  enabled: !isBusy,
                                  validator: _requirePositiveInt,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ProfileTextField(
                                  label: 'Protein (g)',
                                  controller: _proteinController,
                                  keyboardType: TextInputType.number,
                                  enabled: !isBusy,
                                  validator: _requirePositiveInt,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ProfileTextField(
                                  label: 'Carbs (g)',
                                  controller: _carbsController,
                                  keyboardType: TextInputType.number,
                                  enabled: !isBusy,
                                  validator: _requirePositiveInt,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ProfileTextField(
                                  label: 'Fats (g)',
                                  controller: _fatsController,
                                  keyboardType: TextInputType.number,
                                  enabled: !isBusy,
                                  validator: _requirePositiveInt,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ProfileTextField(
                                  label: 'Hydration (L)',
                                  controller: _hydrationController,
                                  keyboardType: TextInputType.number,
                                  allowDecimal: true,
                                  enabled: !isBusy,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ProfileTextField(
                                  label: 'Sleep (hrs)',
                                  controller: _sleepHoursController,
                                  keyboardType: TextInputType.number,
                                  allowDecimal: true,
                                  enabled: !isBusy,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // ── Dietary ───────────────────────────────────────────
                      _sectionLabel('Dietary'),
                      _FormCard(
                        children: [
                          ProfileTextField(
                            label: 'Allergens',
                            controller: _allergensController,
                            maxLines: 3,
                            enabled: !isBusy,
                            helperText:
                                'Use commas or new lines to separate values.',
                          ),
                          const SizedBox(height: 16),
                          ProfileTextField(
                            label: 'Dietary restrictions',
                            controller: _restrictionsController,
                            maxLines: 3,
                            enabled: !isBusy,
                            helperText:
                                'Use commas or new lines to separate values.',
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // ── Display ───────────────────────────────────────────
                      SettingsSection(
                        title: 'Display',
                        children: [
                          SettingsRow(
                            label: 'Accessibility mode',
                            trailing: Switch(
                              value: appSettings.accessibilityModeEnabled,
                              activeThumbColor: AppColors.lime,
                              onChanged: isBusy || appSettings.saving
                                  ? null
                                  : _toggleAccessibilityMode,
                            ),
                            showChevron: false,
                            onTap: isBusy || appSettings.saving
                                ? null
                                : () => _toggleAccessibilityMode(
                                      !appSettings.accessibilityModeEnabled,
                                    ),
                          ),
                          SettingsRow(
                            label: 'Text size',
                            value: appSettings.textScale.label,
                            onTap: isBusy || appSettings.saving
                                ? null
                                : _showTextScalePicker,
                          ),
                          SettingsRow(
                            label: 'Theme colors',
                            value: appSettings.themePalette.label,
                            showDivider: false,
                            onTap: isBusy || appSettings.saving
                                ? null
                                : _showThemePalettePicker,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ── App ───────────────────────────────────────────────
                      SettingsSection(
                        title: 'App',
                        children: [
                          SettingsRow(
                            label: 'Sleep Mode',
                            trailing: Switch(
                              value: appSettings.sleepModeEnabled,
                              activeThumbColor: AppColors.sleepAccent,
                              onChanged: isBusy || appSettings.saving
                                  ? null
                                  : _toggleSleepMode,
                            ),
                            showChevron: false,
                            onTap: isBusy || appSettings.saving
                                ? null
                                : () => _toggleSleepMode(
                                      !appSettings.sleepModeEnabled,
                                    ),
                          ),
                          if (appSettings.sleepModeEnabled)
                            SettingsRow(
                              label: 'Mode switcher',
                              value: _modeSwitcherLabel(
                                appSettings.segmentControlStyle,
                              ),
                              onTap: isBusy || appSettings.saving
                                  ? null
                                  : _showModeSwitcherPicker,
                            ),
                          SettingsRow(
                            label: 'Notifications',
                            onTap: isBusy
                                ? null
                                : () => _showComingSoon('Notifications'),
                          ),
                          SettingsRow(
                            label: 'Units',
                            showDivider: false,
                            onTap: isBusy
                                ? null
                                : () => _showComingSoon('Units'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // ── Save ──────────────────────────────────────────────
                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed: isBusy ? null : _saveProfile,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.lime,
                            foregroundColor: AppColors.onLime,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _saving
                              ? const SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(
                                    color: AppColors.onLime,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Save changes',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ── Sign out ──────────────────────────────────────────
                      TextButton(
                        onPressed: isBusy ? null : _signOut,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.orange,
                        ),
                        child: const Text('Sign out'),
                      ),
                    ],
                  ),
                ),
                if (isBusy)
                  const ColoredBox(
                    color: Color(0x33000000),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Widget _sectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }

  Widget _dropdownField<T>({
    required String label,
    required T? value,
    required Map<T, String> items,
    required bool enabled,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items.entries
              .map(
                (e) => DropdownMenuItem<T>(
                  value: e.key,
                  child: Text(e.value),
                ),
              )
              .toList(),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.cardDarker,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.cardDark),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.cardDark),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.lime),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
          ),
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }

  String? _requirePositiveInt(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    if (int.tryParse(v.trim()) == null) return 'Enter a number';
    return null;
  }

  String _modeSwitcherLabel(SegmentControlStyle style) => switch (style) {
        SegmentControlStyle.minimalTabs => 'Minimal tabs',
        SegmentControlStyle.classicPill => 'Classic pill',
      };
}

// ─── Form card wrapper ────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  const _FormCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

// ─── Bottom-sheet picker option ───────────────────────────────────────────────

class _PickerOption extends StatelessWidget {
  const _PickerOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.leading,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: leading,
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: selected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.lime)
          : null,
    );
  }
}

// ─── Change email dialog ──────────────────────────────────────────────────────

class _ChangeEmailDialog extends StatefulWidget {
  const _ChangeEmailDialog({required this.currentEmail});
  final String? currentEmail;

  @override
  State<_ChangeEmailDialog> createState() => _ChangeEmailDialogState();
}

class _ChangeEmailDialogState extends State<_ChangeEmailDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final credential = EmailAuthProvider.credential(
        email: widget.currentEmail ?? user.email!,
        password: _passwordController.text.trim(),
      );
      await user.reauthenticateWithCredential(credential);
      await user.verifyBeforeUpdateEmail(_emailController.text.trim());

      if (mounted) {
        Navigator.of(context).pop(_emailController.text.trim());
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = friendlyAuthError(e);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardDark,
      title: const Text('Change email'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'New email'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter an email';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current password'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter your password';
                return null;
              },
              onFieldSubmitted: (_) => _loading ? null : _submit(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _loading ? null : _submit,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.lime,
            foregroundColor: AppColors.onLime,
          ),
          child: _loading
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(
                    color: AppColors.onLime,
                    strokeWidth: 2,
                  ),
                )
              : const Text('Update'),
        ),
      ],
    );
  }
}

// ─── Change password dialog ───────────────────────────────────────────────────

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog({required this.email});
  final String? email;

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final credential = EmailAuthProvider.credential(
        email: widget.email ?? user.email!,
        password: _currentPasswordController.text.trim(),
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(_newPasswordController.text.trim());

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = friendlyAuthError(e);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardDark,
      title: const Text('Change password'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current password'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New password'),
              validator: (v) {
                if (v == null || v.trim().length < 6) {
                  return 'At least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm password'),
              validator: (v) {
                if (v != _newPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
              onFieldSubmitted: (_) => _loading ? null : _submit(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _loading ? null : _submit,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.lime,
            foregroundColor: AppColors.onLime,
          ),
          child: _loading
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(
                    color: AppColors.onLime,
                    strokeWidth: 2,
                  ),
                )
              : const Text('Update'),
        ),
      ],
    );
  }
}
