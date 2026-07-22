import 'package:flutter/material.dart';
import 'package:nutrilens/models/meal_plan.dart';
import 'package:nutrilens/theme/app_colors.dart';

class ScheduleMealPlanSection extends StatelessWidget {
  const ScheduleMealPlanSection({
    super.key,
    required this.meals,
    this.error,
    this.loading = false,
    this.onMealTap,
    this.onRegenerateMeal,
    this.regeneratingSlot,
  });

  final List<MealPlanMeal> meals;
  final String? error;
  final bool loading;
  final ValueChanged<String>? onMealTap;
  final ValueChanged<MealPlanMeal>? onRegenerateMeal;
  final MealSlot? regeneratingSlot;

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
                  child: _PlannedMealTile(
                    meal: meals[i],
                    onTap: onMealTap == null
                        ? null
                        : () => onMealTap!(meals[i].recipe.title),
                    onRegenerate: onRegenerateMeal == null
                        ? null
                        : () => onRegenerateMeal!(meals[i]),
                    isRegenerating: regeneratingSlot == meals[i].slot,
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _PlannedMealTile extends StatelessWidget {
  const _PlannedMealTile({
    required this.meal,
    this.onTap,
    this.onRegenerate,
    this.isRegenerating = false,
  });

  final MealPlanMeal meal;
  final VoidCallback? onTap;
  final VoidCallback? onRegenerate;
  final bool isRegenerating;

  @override
  Widget build(BuildContext context) {
    final recipe = meal.recipe;

    return Material(
      color: AppColors.cardDark,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.lime.withValues(alpha: 0.35)),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
                          ? const Icon(
                              Icons.restaurant_rounded,
                              color: AppColors.lime,
                            )
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
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${recipe.calories.round()} kcal • ${recipe.nutrition.proteinG}g protein',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.textMuted.withValues(
                                    alpha: 0.75,
                                  ),
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (onTap != null)
                      Icon(
                        Icons.search_rounded,
                        color: AppColors.lime.withValues(alpha: 0.85),
                      ),
                  ],
                ),
              ),
            ),
            if (onRegenerate != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: isRegenerating ? null : onRegenerate,
                    icon: isRegenerating
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.lime.withValues(alpha: 0.85),
                            ),
                          )
                        : Icon(
                            Icons.refresh_rounded,
                            size: 18,
                            color: AppColors.lime.withValues(alpha: 0.9),
                          ),
                    label: Text(
                      isRegenerating ? 'Generating...' : 'New meal',
                      style: TextStyle(
                        color: AppColors.lime.withValues(alpha: 0.95),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
