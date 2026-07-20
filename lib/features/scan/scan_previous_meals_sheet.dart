import 'package:flutter/material.dart';
import 'package:nutrilens/app/meal_log_refresh_scope.dart';
import 'package:nutrilens/app/user_scope.dart';
import 'package:nutrilens/features/schedule/schedule_view_filter.dart';
import 'package:nutrilens/models/meal.dart';
import 'package:nutrilens/theme/app_colors.dart';

class ScanPreviousMealsSheet extends StatefulWidget {
  const ScanPreviousMealsSheet({super.key, required this.meals});

  final List<Meal> meals;

  static Future<bool?> show(
    BuildContext context, {
    required List<Meal> meals,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardDark,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ScanPreviousMealsSheet(meals: meals),
      ),
    );
  }

  static Future<bool?> open(BuildContext context) async {
    final scope = UserScope.of(context);
    final profile = await scope.repository.getProfile(scope.uid);
    if (profile == null || !context.mounted) {
      return null;
    }

    final meals = await scope.repository.getRecentMeals(
      scope.uid,
      limit: maxPreviousMeals,
      timezone: profile.timezone,
    );

    if (!context.mounted) {
      return null;
    }

    return show(context, meals: meals);
  }

  @override
  State<ScanPreviousMealsSheet> createState() => _ScanPreviousMealsSheetState();
}

class _ScanPreviousMealsSheetState extends State<ScanPreviousMealsSheet> {
  String? _loggingMealId;
  String? _error;

  Future<void> _quickAddMeal(Meal meal) async {
    if (_loggingMealId != null) {
      return;
    }

    setState(() {
      _loggingMealId = meal.mealId ?? meal.name;
      _error = null;
    });

    final scope = UserScope.of(context);
    final profile = await scope.repository.getProfile(scope.uid);
    if (!mounted) {
      return;
    }
    if (profile == null) {
      setState(() {
        _error = 'Unable to load your profile.';
        _loggingMealId = null;
      });
      return;
    }

    final loggedMeal = Meal(
      name: meal.name,
      nutrition: meal.nutrition,
      source: meal.source,
      loggedAt: DateTime.now().toUtc(),
      notes: meal.notes,
    );

    try {
      await scope.repository.logMeal(
        scope.uid,
        loggedMeal,
        profile.timezone,
      );
      MealLogRefreshScope.maybeOf(context)?.requestRefresh();
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'Unable to log meal: $error';
        _loggingMealId = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxSheetHeight = MediaQuery.sizeOf(context).height * 0.75;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxSheetHeight),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            Text(
              'Previous meals',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap a meal to log it again. Showing up to '
              '$maxPreviousMeals recent meals.',
              style: TextStyle(
                color: AppColors.textMuted.withValues(alpha: 0.72),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: AppColors.orange),
              ),
            ],
            const SizedBox(height: 16),
            if (widget.meals.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'No meals logged yet.',
                  textAlign: TextAlign.center,
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.meals.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final meal = widget.meals[index];
                  final mealKey = meal.mealId ?? meal.name;
                  final isLogging = _loggingMealId == mealKey;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    enabled: _loggingMealId == null,
                    onTap: () => _quickAddMeal(meal),
                    title: Text(meal.name),
                    subtitle: Text(
                      '${meal.nutrition.caloriesKcal} kcal · '
                      '${meal.nutrition.proteinG}g protein',
                    ),
                    trailing: isLogging
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            Icons.add_circle_outline_rounded,
                            color: AppColors.lime.withValues(alpha: 0.9),
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
