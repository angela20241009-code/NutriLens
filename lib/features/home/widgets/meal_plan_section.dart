import 'package:flutter/material.dart';
import 'package:nutrilens/features/home/home_dashboard_data.dart';
import 'package:nutrilens/features/home/widgets/meal_plan_card.dart';
import 'package:nutrilens/l10n/app_localizations.dart';
import 'package:nutrilens/theme/app_colors.dart';

class MealPlanSection extends StatelessWidget {
  const MealPlanSection({super.key, required this.meals, this.error});

  final List<HomeMealPlanItem> meals;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.homeTodayMealPlan,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 14),
        if (meals.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              error == null
                  ? l10n.homeNoMealsPlanned
                  : l10n.homeMealPlanUnavailable,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        else
          SizedBox(
            height: 210,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: meals.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return MealPlanCard(meal: meals[index]);
              },
            ),
          ),
      ],
    );
  }
}
