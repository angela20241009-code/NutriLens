import 'package:flutter/material.dart';
import 'package:nutrilens/theme/app_colors.dart';

class SleepQuestionCard extends StatelessWidget {
  const SleepQuestionCard({
    super.key,
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
                  selectedColor: AppColors.sleepAccent,
                  labelStyle: TextStyle(
                    color: selected == option
                        ? AppColors.textPrimary
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  backgroundColor: AppColors.fitnessBlack,
                  side: BorderSide(
                    color: selected == option
                        ? AppColors.sleepAccent
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
