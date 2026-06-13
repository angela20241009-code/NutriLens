import 'package:flutter/material.dart';
import 'package:nutrilens/models/daily_targets.dart';
import 'package:nutrilens/models/nutrition_entry.dart';
import 'package:nutrilens/theme/app_colors.dart';
import 'package:nutrilens/widgets/macro_progress_row.dart';
import 'package:nutrilens/widgets/pill_badge.dart';

class TodaysFuelCard extends StatelessWidget {
  const TodaysFuelCard({
    super.key,
    required this.sport,
    required this.totals,
    required this.targets,
  });

  final String sport;
  final NutritionEntry totals;
  final DailyTargets targets;

  @override
  Widget build(BuildContext context) {
    final macros = [
      MacroProgress(
        label: 'PROTEIN',
        current: totals.proteinG,
        target: targets.proteinG,
        unit: 'g',
      ),
      MacroProgress(
        label: 'CARBS',
        current: totals.carbsG,
        target: targets.carbsG,
        unit: 'g',
      ),
      MacroProgress(
        label: 'FATS',
        current: totals.fatsG,
        target: targets.fatsG,
        unit: 'g',
      ),
    ];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lime,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "TODAY'S FUEL",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppColors.limeDark,
                ),
              ),
              PillBadge(
                label: sport.isEmpty ? 'Sport' : sport,
                backgroundColor: AppColors.onLime,
                textColor: AppColors.textPrimary,
                icon: Icons.sports_tennis_rounded,
              ),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: AppColors.onLime),
              children: [
                TextSpan(
                  text: _formatNumber(totals.caloriesKcal),
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
                TextSpan(
                  text: ' /${_formatNumber(targets.caloriesKcal)} kcal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: AppColors.onLime.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              for (var i = 0; i < macros.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                MacroProgressRow(macro: macros[i]),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatNumber(int n) {
    final s = n.toString();
    if (s.length <= 3) return s;
    return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
  }
}
