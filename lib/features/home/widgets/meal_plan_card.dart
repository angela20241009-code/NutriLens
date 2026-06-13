import 'package:flutter/material.dart';
import 'package:nutrilens/features/home/home_dashboard_data.dart';
import 'package:nutrilens/theme/app_colors.dart';
import 'package:nutrilens/widgets/pill_badge.dart';

class MealPlanCard extends StatelessWidget {
  const MealPlanCard({super.key, required this.meal});

  final HomeMealPlanItem meal;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 168,
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              _MealImage(imageUrl: meal.imageUrl, mealType: meal.mealType),
              Positioned(
                top: 10,
                left: 10,
                child: PillBadge(label: meal.mealType),
              ),
              if (meal.logged)
                const Positioned(top: 10, right: 10, child: _LoggedCheck()),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${meal.calories} kcal · ${meal.protein}g P',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
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

class _MealImage extends StatelessWidget {
  const _MealImage({required this.imageUrl, required this.mealType});

  final String? imageUrl;
  final String mealType;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    return SizedBox(
      height: 120,
      width: double.infinity,
      child: url == null || url.isEmpty
          ? _PlaceholderGradient(mealType: mealType)
          : Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _PlaceholderGradient(mealType: mealType),
            ),
    );
  }
}

class _PlaceholderGradient extends StatelessWidget {
  const _PlaceholderGradient({required this.mealType});

  final String mealType;

  @override
  Widget build(BuildContext context) {
    final isBreakfast = mealType == 'BREAKFAST';
    final isDinner = mealType == 'DINNER';
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isBreakfast
              ? [const Color(0xFF8B6914), const Color(0xFF4A3810)]
              : isDinner
              ? [const Color(0xFF5A3E85), const Color(0xFF2B2240)]
              : [const Color(0xFF2D6A4F), const Color(0xFF1B4332)],
        ),
      ),
      child: Center(
        child: Icon(
          isBreakfast
              ? Icons.breakfast_dining_rounded
              : isDinner
              ? Icons.dinner_dining_rounded
              : Icons.lunch_dining_rounded,
          color: Colors.white.withValues(alpha: 0.5),
          size: 40,
        ),
      ),
    );
  }
}

class _LoggedCheck extends StatelessWidget {
  const _LoggedCheck();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: AppColors.lime,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check_rounded, color: AppColors.onLime, size: 18),
    );
  }
}
