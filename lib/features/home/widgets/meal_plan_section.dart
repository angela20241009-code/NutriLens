import 'package:flutter/material.dart';
import 'package:nutrilens/features/home/home_dashboard_data.dart';
import 'package:nutrilens/features/home/widgets/meal_plan_card.dart';
import 'package:nutrilens/theme/app_colors.dart';

class MealPlanSection extends StatelessWidget {
  const MealPlanSection({super.key, required this.meals, this.error});

  final List<HomeMealPlanItem> meals;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Meal Plan",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'See all',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lime,
                ),
              ),
            ),
          ],
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
                  ? 'No meals planned for today yet.'
                  : 'Meal plan is unavailable right now.',
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
