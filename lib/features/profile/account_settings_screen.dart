import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutrilens/app/app_locale_scope.dart';
import 'package:nutrilens/app/app_settings_scope.dart';
import 'package:nutrilens/app/meal_plan_refresh_scope.dart';
import 'package:nutrilens/app/session_scope.dart';
import 'package:nutrilens/app/user_scope.dart';
import 'package:nutrilens/features/profile/delete_account_dialog.dart';
import 'package:nutrilens/features/profile/link_email_dialog.dart';
import 'package:nutrilens/features/profile/notification_settings_page.dart';
import 'package:nutrilens/features/profile/sign_out_dialog.dart';
import 'package:nutrilens/features/profile/meal_preferences_form.dart';
import 'package:nutrilens/features/profile/widgets/profile_text_field.dart';
import 'package:nutrilens/features/profile/widgets/settings_section.dart';
import 'package:nutrilens/features/settings/language_picker.dart';
import 'package:nutrilens/l10n/app_localizations.dart';
import 'package:nutrilens/l10n/l10n_extensions.dart';
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
  final _otherStyleController = TextEditingController();
  final _selectedStyles = <String>{};
  bool _othersSelected = false;

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
  final _sectionNavigatorKey = GlobalKey<NavigatorState>();

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
    final scopeChanged =
        !_hasScopes ||
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
    _otherStyleController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final profile = await _repository.getProfile(_uid);
      final account = await _repository.getAccount(_uid);
      if (!mounted) return;

      final p =
          profile ??
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
      populateMealStyleFormState(
        preferences: p.dietaryProfile.preferences,
        selectedStyles: _selectedStyles,
        otherStyleController: _otherStyleController,
        setOthersSelected: (selected) => _othersSelected = selected,
      );

      _genderValue = p.sex;
      _activityLevelValue = p.activityLevel;
      _trainingDaysValue = p.trainingDaysPerWeek;

      setState(() => _loading = false);
    } catch (error) {
      if (mounted) {
        setState(() => _loading = false);
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.unableToLoadSettings('$error'))),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _profile == null) return;
    setState(() => _saving = true);

    try {
      final previousDietary = _profile!.dietaryProfile;
      final nextDietary = dietaryProfileFromForm(
        selectedStyles: _selectedStyles,
        allergensText: _allergensController.text,
        restrictionsText: _restrictionsController.text,
        otherStyleText: _otherStyleController.text,
        othersSelected: _othersSelected,
      );
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
          caloriesKcal:
              int.tryParse(_caloriesController.text.trim()) ??
              _profile!.dailyTargets.caloriesKcal,
          proteinG:
              int.tryParse(_proteinController.text.trim()) ??
              _profile!.dailyTargets.proteinG,
          carbsG:
              int.tryParse(_carbsController.text.trim()) ??
              _profile!.dailyTargets.carbsG,
          fatsG:
              int.tryParse(_fatsController.text.trim()) ??
              _profile!.dailyTargets.fatsG,
          hydrationLiters:
              double.tryParse(_hydrationController.text.trim()) ??
              _profile!.dailyTargets.hydrationLiters,
          sleepHours:
              double.tryParse(_sleepHoursController.text.trim()) ??
              _profile!.dailyTargets.sleepHours,
          source: DailyTargetsSource.manual,
        ),
        dietaryProfile: nextDietary,
      );

      await _repository.saveProfile(updated);

      if (mounted &&
          (previousDietary.allergens.join() != nextDietary.allergens.join() ||
              previousDietary.restrictions.join() !=
                  nextDietary.restrictions.join() ||
              previousDietary.preferences.join() !=
                  nextDietary.preferences.join())) {
        MealPlanRefreshScope.maybeOf(context)?.requestRefresh();
      }

      if (mounted) {
        setState(() {
          _profile = updated;
          _saving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.changesSaved)),
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.failedToSave('$error')),
          ),
        );
      }
    }
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
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.accountCreatedSuccessfully,
            ),
          ),
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
        SnackBar(
          content: Text(AppLocalizations.of(context)!.emailVerificationSent),
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
        SnackBar(content: Text(AppLocalizations.of(context)!.passwordUpdated)),
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
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.unableToSignOut('$error'),
            ),
          ),
        );
      }
    }
  }

  Future<void> _deleteAccount() async {
    if (_busy || _account == null) return;

    final confirmed = await showDeleteAccountConfirmationDialog(
      context: context,
      isAnonymous: _account!.isAnonymous,
      email: _account!.email,
    );

    if (!confirmed || !mounted) return;

    String? password;
    if (!_account!.isAnonymous) {
      password = await showDeleteAccountReauthDialog(
        context: context,
        email: _account!.email,
      );
      if (!mounted || password == null) {
        return;
      }
    }

    setState(() => _busy = true);
    try {
      await _repository.deleteAccount(_uid, password: password);
      if (!mounted) {
        return;
      }
      await _signOutUser();
    } catch (error) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.unableToDeleteAccount(
                friendlyAuthErrorMessage(AppLocalizations.of(context)!, error),
              ),
            ),
          ),
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
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              )!.unableToUpdateAccessibilityMode('$error'),
            ),
          ),
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
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.unableToUpdateSleepMode('$error'),
            ),
          ),
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
                    AppLocalizations.of(context)!.modeSwitcher,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              _PickerOption(
                title: AppLocalizations.of(context)!.minimalTabs,
                subtitle: AppLocalizations.of(context)!.minimalTabsDescription,
                selected: current == SegmentControlStyle.minimalTabs,
                onTap: () =>
                    Navigator.of(context).pop(SegmentControlStyle.minimalTabs),
              ),
              _PickerOption(
                title: AppLocalizations.of(context)!.classicPill,
                subtitle: AppLocalizations.of(context)!.classicPillDescription,
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
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              )!.unableToUpdateModeSwitcher('$error'),
            ),
          ),
        );
      }
    }
  }

  Future<void> _showLanguagePicker() async {
    if (_busy) {
      return;
    }

    try {
      await pickAndApplyLanguage(
        context: context,
        repository: _repository,
        uid: _uid,
      );
    } catch (error) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.unableToUpdateLanguage('$error'))),
        );
      }
    }
  }

  Future<void> _showTextScalePicker() async {
    final settings = AppSettingsScope.of(context);
    final l10n = AppLocalizations.of(context)!;
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
                    l10n.textSize,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              for (final scale in AppTextScale.values)
                _PickerOption(
                  title: localizedTextScaleLabel(l10n, scale),
                  subtitle: localizedTextScaleDescription(l10n, scale),
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
          SnackBar(content: Text(l10n.unableToUpdateTextSize('$error'))),
        );
      }
    }
  }

  Future<void> _showThemePalettePicker() async {
    final settings = AppSettingsScope.of(context);
    final l10n = AppLocalizations.of(context)!;
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
                    l10n.themeColors,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              for (final palette in AppThemePalette.values)
                _PickerOption(
                  title: localizedThemePaletteLabel(l10n, palette),
                  subtitle: l10n.themePaletteDesc,
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
          SnackBar(content: Text(l10n.unableToUpdateTheme('$error'))),
        );
      }
    }
  }

  void _showComingSoon(String feature) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.comingSoon(feature))));
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  void _openSettingsSection(String routeName) {
    _sectionNavigatorKey.currentState?.pushNamed(routeName);
  }

  void _popSettingsSection() {
    final navigator = _sectionNavigatorKey.currentState;
    if (navigator != null && navigator.canPop()) {
      navigator.pop();
      return;
    }
    Navigator.of(context).pop();
  }

  void updateGender(String? value) => setState(() => _genderValue = value);

  void updateTrainingDays(int? value) =>
      setState(() => _trainingDaysValue = value);

  void updateActivityLevel(String? value) =>
      setState(() => _activityLevelValue = value);

  void toggleMealStyle(String style) {
    setState(() {
      if (_selectedStyles.contains(style)) {
        _selectedStyles.remove(style);
      } else {
        _selectedStyles.add(style);
      }
    });
  }

  void updateOthersSelected(bool selected) =>
      setState(() => _othersSelected = selected);

  Route<void> _onGenerateSectionRoute(RouteSettings settings) {
    final l10n = AppLocalizations.of(context)!;
    final isBusy = _saving || _busy;

    late final String title;
    late final Widget body;
    var showSave = false;

    switch (settings.name) {
      case '/account':
        title = l10n.sectionAccount;
        body = _AccountSettingsPage(host: this);
        showSave = true;
      case '/personal':
        title = l10n.sectionPersonal;
        body = _PersonalSettingsPage(host: this);
        showSave = true;
      case '/athlete':
        title = l10n.sectionAthlete;
        body = _AthleteSettingsPage(host: this);
        showSave = true;
      case '/nutrition':
        title = l10n.sectionNutritionGoals;
        body = _NutritionSettingsPage(host: this);
        showSave = true;
      case '/dietary':
        title = l10n.sectionDietary;
        body = _DietarySettingsPage(host: this);
        showSave = true;
      case '/display':
        title = l10n.sectionDisplay;
        body = _DisplaySettingsPage(host: this);
      case '/app':
        title = l10n.sectionApp;
        body = _AppSettingsPage(host: this);
      case '/app/notifications':
        title = l10n.notifications;
        body = const NotificationSettingsPage();
      case '/':
      default:
        title = l10n.settingsTitle;
        body = _SettingsHubPage(host: this, onSectionTap: _openSettingsSection);
    }

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (context) => _SettingsPageScaffold(
        title: title,
        showSave: showSave,
        saving: _saving,
        busy: isBusy,
        onSave: showSave ? _saveProfile : null,
        onBack: isBusy ? null : _popSettingsSection,
        child: body,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(AppLocalizations.of(context)!.settingsTitle),
          leading: BackButton(color: AppColors.lime),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Form(
      key: _formKey,
      child: Navigator(
        key: _sectionNavigatorKey,
        initialRoute: '/',
        onGenerateRoute: _onGenerateSectionRoute,
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Widget _dropdownField<T>({
    required String label,
    required T? value,
    required Map<T, String> items,
    required bool enabled,
    required ValueChanged<T?> onChanged,
    String? hint,
  }) {
    final T? selectedValue = value != null && items.containsKey(value)
        ? value
        : null;
    OutlineInputBorder limeOutline(double width) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.lime, width: width),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          key: ValueKey('$label-$selectedValue'),
          value: selectedValue,
          hint: Text(
            hint ?? AppLocalizations.of(context)!.select,
            style: TextStyle(
              color: AppColors.textMuted.withValues(alpha: 0.72),
            ),
          ),
          style: const TextStyle(color: AppColors.textPrimary),
          dropdownColor: AppColors.cardDarker,
          iconEnabledColor: AppColors.lime,
          items: items.entries
              .map(
                (e) => DropdownMenuItem<T>(value: e.key, child: Text(e.value)),
              )
              .toList(),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.cardDarker,
            border: limeOutline(1.5),
            enabledBorder: limeOutline(1.5),
            focusedBorder: limeOutline(3),
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

  String? _requirePositiveInt(String? v, AppLocalizations l10n) {
    if (v == null || v.trim().isEmpty) return l10n.fieldRequired;
    if (int.tryParse(v.trim()) == null) return l10n.enterNumber;
    return null;
  }
}

// ─── Settings navigation shell ────────────────────────────────────────────────

class _SettingsPageScaffold extends StatelessWidget {
  const _SettingsPageScaffold({
    required this.title,
    required this.child,
    required this.onBack,
    this.showSave = false,
    this.saving = false,
    this.busy = false,
    this.onSave,
  });

  final String title;
  final Widget child;
  final VoidCallback? onBack;
  final bool showSave;
  final bool saving;
  final bool busy;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(title),
        leading: BackButton(color: AppColors.lime, onPressed: onBack),
      ),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, showSave ? 24 : 40),
            children: [
              child,
              if (showSave) ...[
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: busy || onSave == null ? null : onSave,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.lime,
                      foregroundColor: AppColors.onLime,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: saving
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.onLime,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            l10n.saveChanges,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ],
            ],
          ),
          if (busy)
            const ColoredBox(
              color: Color(0x33000000),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class _SettingsHubPage extends StatelessWidget {
  const _SettingsHubPage({required this.host, required this.onSectionTap});

  final _AccountSettingsScreenState host;
  final ValueChanged<String> onSectionTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isBusy = host._saving || host._busy;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsSection(
          title: '',
          children: [
            SettingsRow(
              label: l10n.sectionAccount,
              onTap: isBusy ? null : () => onSectionTap('/account'),
            ),
            SettingsRow(
              label: l10n.sectionPersonal,
              onTap: isBusy ? null : () => onSectionTap('/personal'),
            ),
            SettingsRow(
              label: l10n.sectionAthlete,
              onTap: isBusy ? null : () => onSectionTap('/athlete'),
            ),
            SettingsRow(
              label: l10n.sectionNutritionGoals,
              onTap: isBusy ? null : () => onSectionTap('/nutrition'),
            ),
            SettingsRow(
              label: l10n.sectionDietary,
              onTap: isBusy ? null : () => onSectionTap('/dietary'),
            ),
            SettingsRow(
              label: l10n.sectionDisplay,
              onTap: isBusy ? null : () => onSectionTap('/display'),
            ),
            SettingsRow(
              label: l10n.sectionApp,
              showDivider: false,
              onTap: isBusy ? null : () => onSectionTap('/app'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: isBusy ? null : host._signOut,
          style: TextButton.styleFrom(foregroundColor: AppColors.orange),
          child: Text(l10n.signOut),
        ),
        TextButton(
          onPressed: isBusy ? null : host._deleteAccount,
          style: TextButton.styleFrom(foregroundColor: AppColors.orange),
          child: Text(l10n.deleteAccount),
        ),
      ],
    );
  }
}

class _AccountSettingsPage extends StatelessWidget {
  const _AccountSettingsPage({required this.host});

  final _AccountSettingsScreenState host;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isBusy = host._saving || host._busy;
    final isAnonymous = host._account?.isAnonymous ?? true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FormCard(
          children: [
            ProfileTextField(
              label: l10n.displayName,
              controller: host._displayNameController,
              enabled: !isBusy,
              limeBorder: true,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return l10n.nameRequired;
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
              label: l10n.email,
              value: host._account?.email?.isNotEmpty == true
                  ? host._account!.email!
                  : l10n.notLinked,
              showChevron: !isAnonymous,
              onTap: (!isAnonymous && !isBusy) ? host._changeEmail : null,
            ),
            if (isAnonymous)
              SettingsRow(
                label: l10n.createAccount,
                onTap: isBusy ? null : host._linkEmail,
                showDivider: false,
              )
            else
              SettingsRow(
                label: l10n.changePassword,
                showDivider: false,
                onTap: isBusy ? null : host._changePassword,
              ),
          ],
        ),
      ],
    );
  }
}

class _PersonalSettingsPage extends StatelessWidget {
  const _PersonalSettingsPage({required this.host});

  final _AccountSettingsScreenState host;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isBusy = host._saving || host._busy;
    final genderOptions = localizedGenderOptions(l10n);

    return _FormCard(
      children: [
        host._dropdownField<String>(
          label: l10n.gender,
          value: host._genderValue,
          items: genderOptions,
          hint: l10n.selectGender,
          enabled: !isBusy,
          onChanged: (v) => host.updateGender(v),
        ),
        const SizedBox(height: 16),
        ProfileTextField(
          label: l10n.phoneNumber,
          controller: host._phoneController,
          keyboardType: TextInputType.phone,
          enabled: !isBusy,
          limeBorder: true,
        ),
        const SizedBox(height: 16),
        ProfileTextField(
          label: l10n.birthYear,
          controller: host._birthYearController,
          keyboardType: TextInputType.number,
          enabled: !isBusy,
          limeBorder: true,
          validator: (v) {
            if (v != null &&
                v.trim().isNotEmpty &&
                int.tryParse(v.trim()) == null) {
              return l10n.enterValidYear;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ProfileTextField(
                label: l10n.heightCm,
                controller: host._heightController,
                keyboardType: TextInputType.number,
                allowDecimal: true,
                enabled: !isBusy,
                limeBorder: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ProfileTextField(
                label: l10n.weightKg,
                controller: host._weightController,
                keyboardType: TextInputType.number,
                allowDecimal: true,
                enabled: !isBusy,
                limeBorder: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AthleteSettingsPage extends StatelessWidget {
  const _AthleteSettingsPage({required this.host});

  final _AccountSettingsScreenState host;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isBusy = host._saving || host._busy;
    final activityOptions = localizedActivityOptions(l10n);

    return _FormCard(
      children: [
        Text(l10n.primarySport, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.cardDarker,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardDark),
          ),
          child: Text(
            host._profile?.primarySportName.isNotEmpty == true
                ? host._profile!.primarySportName
                : l10n.noSportSelected,
            style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.5)),
          ),
        ),
        const SizedBox(height: 16),
        ProfileTextField(
          label: l10n.school,
          controller: host._schoolController,
          enabled: !isBusy,
          limeBorder: true,
        ),
        const SizedBox(height: 16),
        ProfileTextField(
          label: l10n.graduationYear,
          controller: host._graduationYearController,
          keyboardType: TextInputType.number,
          enabled: !isBusy,
          limeBorder: true,
          validator: (v) {
            if (v != null &&
                v.trim().isNotEmpty &&
                int.tryParse(v.trim()) == null) {
              return l10n.enterValidYear;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        host._dropdownField<int>(
          label: l10n.trainingDaysPerWeek,
          value: host._trainingDaysValue,
          items: {for (int i = 0; i <= 7; i++) i: l10n.trainingDaysCount(i)},
          hint: l10n.selectTrainingDays,
          enabled: !isBusy,
          onChanged: (v) => host.updateTrainingDays(v),
        ),
        const SizedBox(height: 16),
        host._dropdownField<String>(
          label: l10n.activityLevel,
          value: host._activityLevelValue,
          items: activityOptions,
          hint: l10n.selectActivityLevel,
          enabled: !isBusy,
          onChanged: (v) => host.updateActivityLevel(v),
        ),
      ],
    );
  }
}

class _NutritionSettingsPage extends StatelessWidget {
  const _NutritionSettingsPage({required this.host});

  final _AccountSettingsScreenState host;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isBusy = host._saving || host._busy;

    return _FormCard(
      children: [
        Row(
          children: [
            Expanded(
              child: ProfileTextField(
                label: l10n.caloriesKcal,
                controller: host._caloriesController,
                keyboardType: TextInputType.number,
                enabled: !isBusy,
                limeBorder: true,
                validator: (v) => host._requirePositiveInt(v, l10n),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ProfileTextField(
                label: l10n.proteinG,
                controller: host._proteinController,
                keyboardType: TextInputType.number,
                enabled: !isBusy,
                limeBorder: true,
                validator: (v) => host._requirePositiveInt(v, l10n),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ProfileTextField(
                label: l10n.carbsG,
                controller: host._carbsController,
                keyboardType: TextInputType.number,
                enabled: !isBusy,
                limeBorder: true,
                validator: (v) => host._requirePositiveInt(v, l10n),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ProfileTextField(
                label: l10n.fatsG,
                controller: host._fatsController,
                keyboardType: TextInputType.number,
                enabled: !isBusy,
                limeBorder: true,
                validator: (v) => host._requirePositiveInt(v, l10n),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ProfileTextField(
                label: l10n.hydrationL,
                controller: host._hydrationController,
                keyboardType: TextInputType.number,
                allowDecimal: true,
                enabled: !isBusy,
                limeBorder: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ProfileTextField(
                label: l10n.sleepHrs,
                controller: host._sleepHoursController,
                keyboardType: TextInputType.number,
                allowDecimal: true,
                enabled: !isBusy,
                limeBorder: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DietarySettingsPage extends StatelessWidget {
  const _DietarySettingsPage({required this.host});

  final _AccountSettingsScreenState host;

  @override
  Widget build(BuildContext context) {
    final isBusy = host._saving || host._busy;

    return _FormCard(
      children: [
        MealPreferencesForm(
          selectedStyles: host._selectedStyles,
          onStyleToggled: host.toggleMealStyle,
          allergensController: host._allergensController,
          restrictionsController: host._restrictionsController,
          otherStyleController: host._otherStyleController,
          othersSelected: host._othersSelected,
          onOthersSelectedChanged: host.updateOthersSelected,
          enabled: !isBusy,
          useLimeBorders: true,
        ),
      ],
    );
  }
}

class _DisplaySettingsPage extends StatelessWidget {
  const _DisplaySettingsPage({required this.host});

  final _AccountSettingsScreenState host;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeScope = AppLocaleScope.of(context);
    final appSettings = AppSettingsScope.of(context);
    final isBusy = host._saving || host._busy;

    return SettingsSection(
      title: '',
      children: [
        SettingsRow(
          label: l10n.languageLabel,
          value: localeScope.language.label(l10n),
          onTap: isBusy ? null : host._showLanguagePicker,
        ),
        SettingsRow(
          label: l10n.accessibilityMode,
          trailing: Switch(
            value: appSettings.accessibilityModeEnabled,
            activeThumbColor: AppColors.lime,
            onChanged: isBusy || appSettings.saving
                ? null
                : host._toggleAccessibilityMode,
          ),
          showChevron: false,
          onTap: isBusy || appSettings.saving
              ? null
              : () => host._toggleAccessibilityMode(
                  !appSettings.accessibilityModeEnabled,
                ),
        ),
        SettingsRow(
          label: l10n.textSize,
          value: localizedTextScaleLabel(l10n, appSettings.textScale),
          onTap: isBusy || appSettings.saving
              ? null
              : host._showTextScalePicker,
        ),
        SettingsRow(
          label: l10n.themeColors,
          value: localizedThemePaletteLabel(l10n, appSettings.themePalette),
          showDivider: false,
          onTap: isBusy || appSettings.saving
              ? null
              : host._showThemePalettePicker,
        ),
      ],
    );
  }
}

class _AppSettingsPage extends StatelessWidget {
  const _AppSettingsPage({required this.host});

  final _AccountSettingsScreenState host;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appSettings = AppSettingsScope.of(context);
    final isBusy = host._saving || host._busy;

    return SettingsSection(
      title: '',
      children: [
        SettingsRow(
          label: l10n.sleepMode,
          trailing: Switch(
            value: appSettings.sleepModeEnabled,
            activeThumbColor: AppColors.sleepAccent,
            onChanged: isBusy || appSettings.saving
                ? null
                : host._toggleSleepMode,
          ),
          showChevron: false,
          onTap: isBusy || appSettings.saving
              ? null
              : () => host._toggleSleepMode(!appSettings.sleepModeEnabled),
        ),
        SettingsRow(
          label: l10n.notifications,
          onTap: isBusy
              ? null
              : () => host._openSettingsSection('/app/notifications'),
        ),
        SettingsRow(
          label: l10n.units,
          showDivider: false,
          onTap: isBusy ? null : () => host._showComingSoon(l10n.units),
        ),
      ],
    );
  }
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
          _error = friendlyAuthErrorMessage(AppLocalizations.of(context)!, e);
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
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      backgroundColor: AppColors.cardDark,
      title: Text(l10n.changeEmail),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: l10n.newEmail),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return l10n.authValidationEmailRequired;
                }
                if (!v.contains('@')) return l10n.authValidationEmailInvalid;
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.currentPassword),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return l10n.enterPassword;
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
          child: Text(l10n.cancel),
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
              : Text(l10n.update),
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
          _error = friendlyAuthErrorMessage(AppLocalizations.of(context)!, e);
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
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      backgroundColor: AppColors.cardDark,
      title: Text(l10n.changePassword),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.currentPassword),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return l10n.fieldRequired;
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.newPassword),
              validator: (v) {
                if (v == null || v.trim().length < 6) {
                  return l10n.passwordMinCharacters;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.confirmPassword),
              validator: (v) {
                if (v != _newPasswordController.text) {
                  return l10n.passwordsDoNotMatch;
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
          child: Text(l10n.cancel),
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
              : Text(l10n.update),
        ),
      ],
    );
  }
}
