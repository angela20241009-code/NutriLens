import 'package:flutter/material.dart';
import 'package:nutrilens/app/meal_log_refresh_scope.dart';
import 'package:nutrilens/app/user_scope.dart';
import 'package:nutrilens/features/profile/widgets/profile_text_field.dart';
import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/theme/app_colors.dart';

class LogMealSheet extends StatefulWidget {
  const LogMealSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const LogMealSheet(),
    );
  }

  @override
  State<LogMealSheet> createState() => _LogMealSheetState();
}

class _LogMealSheetState extends State<LogMealSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatsController = TextEditingController();

  Future<UserProfile?>? _profileFuture;
  UserProfile? _profile;
  String? _error;
  bool _isSaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = UserScope.of(context);
    _profileFuture ??= scope.repository.getProfile(scope.uid);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSaving || _profile == null) {
      return;
    }

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    final scope = UserScope.of(context);
    final profile = _profile!;
    final meal = Meal(
      name: _nameController.text.trim(),
      nutrition: NutritionEntry(
        caloriesKcal: int.parse(_caloriesController.text),
        proteinG: int.parse(_proteinController.text),
        carbsG: int.parse(_carbsController.text),
        fatsG: int.parse(_fatsController.text),
      ),
      source: MealSource.manual,
      loggedAt: DateTime.now().toUtc(),
    );

    try {
      await scope.repository.logMeal(scope.uid, meal, profile.timezone);
      MealLogRefreshScope.maybeOf(context)?.requestRefresh();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Meal logged successfully')));
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to log meal: $error';
        _isSaving = false;
      });
    }
  }

  String? _requiredText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _requiredNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    final parsed = int.tryParse(value);
    if (parsed == null || parsed < 0) {
      return 'Enter a valid number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      top: false,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: bottomInset),
        child: FutureBuilder<UserProfile?>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              _profile = snapshot.data;
            }

            final isLoadingProfile =
                snapshot.connectionState != ConnectionState.done;
            final profileError =
                !isLoadingProfile &&
                    (snapshot.hasError || snapshot.data == null)
                ? 'Unable to load your profile. Try again in a moment.'
                : null;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.textMuted,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Log meal',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 20),
                    ProfileTextField(
                      label: 'Meal name',
                      controller: _nameController,
                      validator: _requiredText,
                      limeBorder: true,
                    ),
                    const SizedBox(height: 16),
                    ProfileTextField(
                      label: 'Calories kcal',
                      controller: _caloriesController,
                      keyboardType: TextInputType.number,
                      validator: _requiredNumber,
                      limeBorder: true,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ProfileTextField(
                            label: 'Protein g',
                            controller: _proteinController,
                            keyboardType: TextInputType.number,
                            validator: _requiredNumber,
                            limeBorder: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ProfileTextField(
                            label: 'Carbs g',
                            controller: _carbsController,
                            keyboardType: TextInputType.number,
                            validator: _requiredNumber,
                            limeBorder: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ProfileTextField(
                      label: 'Fats g',
                      controller: _fatsController,
                      keyboardType: TextInputType.number,
                      validator: _requiredNumber,
                      limeBorder: true,
                    ),
                    if (profileError != null || _error != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _error ?? profileError!,
                        style: const TextStyle(color: AppColors.orange),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed:
                          isLoadingProfile || profileError != null || _isSaving
                          ? null
                          : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.lime,
                        foregroundColor: AppColors.onLime,
                        disabledBackgroundColor: AppColors.limeDark,
                        disabledForegroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isLoadingProfile || _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.onLime,
                              ),
                            )
                          : const Text('Log meal'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
