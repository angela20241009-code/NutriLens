import 'package:flutter/material.dart';
import 'package:nutrilens/features/profile/meal_preferences_constants.dart';
import 'package:nutrilens/features/profile/widgets/profile_text_field.dart';
import 'package:nutrilens/l10n/app_localizations.dart';
import 'package:nutrilens/l10n/l10n_extensions.dart';
import 'package:nutrilens/models/dietary_profile.dart';
import 'package:nutrilens/theme/app_colors.dart';

List<String> splitMealPreferenceList(String input) {
  return input
      .split(RegExp(r'[\n,]'))
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toList();
}

List<String> mealStylePreferencesFromForm({
  required Set<String> selectedStyles,
  required String otherStyleText,
  required bool othersSelected,
}) {
  return [
    ...selectedStyles,
    if (othersSelected) ...splitMealPreferenceList(otherStyleText),
  ];
}

void populateMealStyleFormState({
  required List<String> preferences,
  required Set<String> selectedStyles,
  required TextEditingController otherStyleController,
  required ValueSetter<bool> setOthersSelected,
}) {
  selectedStyles
    ..clear()
    ..addAll(preferences.where(mealStyleOptions.contains));
  final customStyles = preferences
      .where((style) => !mealStyleOptions.contains(style))
      .toList();
  otherStyleController.text = customStyles.join(', ');
  setOthersSelected(customStyles.isNotEmpty);
}

DietaryProfile dietaryProfileFromForm({
  required Set<String> selectedStyles,
  required String allergensText,
  required String restrictionsText,
  required String otherStyleText,
  required bool othersSelected,
}) {
  return DietaryProfile(
    allergens: splitMealPreferenceList(allergensText),
    restrictions: splitMealPreferenceList(restrictionsText),
    preferences: mealStylePreferencesFromForm(
      selectedStyles: selectedStyles,
      otherStyleText: otherStyleText,
      othersSelected: othersSelected,
    ),
  );
}

class MealPreferencesForm extends StatelessWidget {
  const MealPreferencesForm({
    super.key,
    required this.selectedStyles,
    required this.onStyleToggled,
    required this.allergensController,
    required this.restrictionsController,
    required this.otherStyleController,
    required this.othersSelected,
    required this.onOthersSelectedChanged,
    this.enabled = true,
    this.useLimeBorders = false,
  });

  final Set<String> selectedStyles;
  final ValueChanged<String> onStyleToggled;
  final TextEditingController allergensController;
  final TextEditingController restrictionsController;
  final TextEditingController otherStyleController;
  final bool othersSelected;
  final ValueChanged<bool> onOthersSelectedChanged;
  final bool enabled;
  final bool useLimeBorders;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.mealStylesTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final style in mealStyleOptions)
              FilterChip(
                label: Text(localizedMealStyle(l10n, style)),
                selected: selectedStyles.contains(style),
                onSelected: enabled ? (_) => onStyleToggled(style) : null,
                selectedColor: AppColors.lime,
                checkmarkColor: AppColors.onLime,
                labelStyle: TextStyle(
                  color: selectedStyles.contains(style)
                      ? AppColors.onLime
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                backgroundColor: AppColors.cardDarker,
                side: BorderSide(
                  color: selectedStyles.contains(style)
                      ? AppColors.lime
                      : Colors.white.withValues(alpha: 0.12),
                ),
              ),
            FilterChip(
              label: Text(l10n.mealStyleOthers),
              selected: othersSelected,
              onSelected: enabled
                  ? (selected) {
                      onOthersSelectedChanged(selected);
                      if (!selected) {
                        otherStyleController.clear();
                      }
                    }
                  : null,
              selectedColor: AppColors.lime,
              checkmarkColor: AppColors.onLime,
              labelStyle: TextStyle(
                color: othersSelected ? AppColors.onLime : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              backgroundColor: AppColors.cardDarker,
              side: BorderSide(
                color: othersSelected
                    ? AppColors.lime
                    : Colors.white.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
        if (othersSelected) ...[
          const SizedBox(height: 16),
          ProfileTextField(
            label: l10n.mealStyleOtherLabel,
            controller: otherStyleController,
            enabled: enabled,
            limeBorder: useLimeBorders,
            helperText: l10n.mealStyleOtherHelper,
          ),
        ],
        const SizedBox(height: 20),
        ProfileTextField(
          label: l10n.allergensLabel,
          controller: allergensController,
          maxLines: 3,
          enabled: enabled,
          limeBorder: useLimeBorders,
          helperText: l10n.allergensHelper,
        ),
        const SizedBox(height: 16),
        ProfileTextField(
          label: l10n.restrictionsLabel,
          controller: restrictionsController,
          maxLines: 3,
          enabled: enabled,
          limeBorder: useLimeBorders,
          helperText: l10n.restrictionsHelper,
        ),
      ],
    );
  }
}
