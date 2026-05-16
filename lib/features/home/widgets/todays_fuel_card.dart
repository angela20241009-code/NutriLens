import 'package:flutter/material.dart';
import 'package:nutrilens/data/mock_home_data.dart';
import 'package:nutrilens/theme/app_colors.dart';
import 'package:nutrilens/widgets/macro_progress_row.dart';
import 'package:nutrilens/widgets/pill_badge.dart';

class TodaysFuelCard extends StatelessWidget {
  const TodaysFuelCard({super.key});

  @override
  Widget build(BuildContext context) {
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
                label: MockHomeData.sport,
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
                  text: _formatNumber(MockHomeData.caloriesCurrent),
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
                TextSpan(
                  text:
                      ' /${_formatNumber(MockHomeData.caloriesTarget)} kcal',
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
              for (var i = 0; i < MockHomeData.macros.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                MacroProgressRow(macro: MockHomeData.macros[i]),
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
