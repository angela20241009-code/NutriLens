import 'package:flutter/material.dart';
import 'package:nutrilens/app/meal_plan_refresh_scope.dart';
import 'package:nutrilens/app/user_scope.dart';
import 'package:nutrilens/features/profile/meal_preferences_form.dart';
import 'package:nutrilens/models/user_profile.dart';
import 'package:nutrilens/theme/app_colors.dart';

class MealPreferencesSheet extends StatefulWidget {
  const MealPreferencesSheet({super.key, this.initialProfile});

  final UserProfile? initialProfile;

  static Future<bool?> show(
    BuildContext context, {
    UserProfile? initialProfile,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => MealPreferencesSheet(initialProfile: initialProfile),
    );
  }

  @override
  State<MealPreferencesSheet> createState() => _MealPreferencesSheetState();
}

class _MealPreferencesSheetState extends State<MealPreferencesSheet> {
  final _allergensController = TextEditingController();
  final _restrictionsController = TextEditingController();
  final _otherStyleController = TextEditingController();
  final _selectedStyles = <String>{};
  bool _othersSelected = false;

  Future<UserProfile?>? _profileFuture;
  UserProfile? _profile;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final profile = widget.initialProfile;
    if (profile != null) {
      _applyProfile(profile);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _profileFuture ??= UserScope.of(context).repository.getProfile(
      UserScope.of(context).uid,
    );
  }

  void _applyProfile(UserProfile profile) {
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
  }

  Future<void> _save() async {
    if (_saving || _profile == null) {
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final scope = UserScope.of(context);
    final dietaryProfile = dietaryProfileFromForm(
      selectedStyles: _selectedStyles,
      allergensText: _allergensController.text,
      restrictionsText: _restrictionsController.text,
      otherStyleText: _otherStyleController.text,
      othersSelected: _othersSelected,
    );

    try {
      final updated = _profile!.copyWith(dietaryProfile: dietaryProfile);
      await scope.repository.saveProfile(updated);
      MealPlanRefreshScope.maybeOf(context)?.requestRefresh();
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'Unable to save preferences: $error';
        _saving = false;
      });
    }
  }

  @override
  void dispose() {
    _allergensController.dispose();
    _restrictionsController.dispose();
    _otherStyleController.dispose();
    super.dispose();
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
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.data != null &&
                _profile == null) {
              final profile = snapshot.data!;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted || _profile != null) {
                  return;
                }
                setState(() {
                  _profile = profile;
                  _applyProfile(profile);
                });
              });
            }

            final isLoadingProfile =
                snapshot.connectionState != ConnectionState.done;
            final profileError =
                !isLoadingProfile &&
                    (snapshot.hasError || snapshot.data == null)
                ? 'Unable to load your profile.'
                : null;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
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
                    'Meal preferences',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pick food styles and allergies so we can personalize your meal plan.',
                    style: TextStyle(
                      color: AppColors.textMuted.withValues(alpha: 0.72),
                    ),
                  ),
                  const SizedBox(height: 20),
                  MealPreferencesForm(
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
                    enabled: !isLoadingProfile && profileError == null && !_saving,
                    useLimeBorders: true,
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
                        isLoadingProfile || profileError != null || _saving
                        ? null
                        : _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.lime,
                      foregroundColor: AppColors.onLime,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.onLime,
                            ),
                          )
                        : const Text('Save & refresh meal plan'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
