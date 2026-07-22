import 'package:flutter/material.dart';
import 'package:nutrilens/models/meal_plan.dart';
import 'package:nutrilens/theme/app_colors.dart';

class ScheduleMealPlanSection extends StatelessWidget {
  const ScheduleMealPlanSection({
    super.key,
    required this.meals,
    this.error,
    this.loading = false,
  });

  final List<MealPlanMeal> meals;
  final String? error;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Meal plan', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 14),
        if (loading)
          const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (meals.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              error == null
                  ? 'No meals planned for this day.'
                  : 'Meal plan is unavailable right now.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
        else
          Column(
            children: [
              for (var i = 0; i < meals.length; i++)
                Padding(
                  padding: EdgeInsets.only(bottom: i == meals.length - 1 ? 0 : 12),
                  child: _PlannedMealTile(meal: meals[i]),
                ),
            ],
          ),
      ],
    );
  }
}

class _PlannedMealTile extends StatelessWidget {
  const _PlannedMealTile({required this.meal});

  final MealPlanMeal meal;

  @override
  Widget build(BuildContext context) {
    final recipe = meal.recipe;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.lime.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.lime.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              image: recipe.imageUrl == null
                  ? null
                  : DecorationImage(
                      image: NetworkImage(recipe.imageUrl!),
                      fit: BoxFit.cover,
                    ),
            ),
            child: recipe.imageUrl == null
                ? const Icon(Icons.restaurant_rounded, color: AppColors.lime)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.badgeLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: AppColors.lime.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  recipe.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${recipe.calories.round()} kcal • ${recipe.nutrition.proteinG}g protein',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
