import 'package:flutter/material.dart';
import 'package:nutrilens/models/daily_targets.dart';
import 'package:nutrilens/models/nutrition_entry.dart';
import 'package:nutrilens/theme/app_colors.dart';

class TodaysFuelCard extends StatelessWidget {
  const TodaysFuelCard({
    super.key,
    required this.sport,
    required this.totals,
    required this.targets,
    required this.onViewDetailsTap,
  });

  final String sport;
  final NutritionEntry totals;
  final DailyTargets targets;
  final VoidCallback onViewDetailsTap;

  @override
  Widget build(BuildContext context) {
    final calorieProgress = _progress(
      totals.caloriesKcal,
      targets.caloriesKcal,
    );

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_fire_department_outlined,
                color: AppColors.textPrimary,
                size: 28,
              ),
              const SizedBox(width: 10),
              Text(
                "Today's fuel",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              InkWell(
                onTap: onViewDetailsTap,
                borderRadius: BorderRadius.circular(18),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: Row(
                    children: [
                      Text(
                        'View details',
                        style: TextStyle(
                          color: AppColors.lime,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.lime,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 340;
              if (isCompact) {
                return Column(
                  children: [
                    _CalorieRing(
                      current: totals.caloriesKcal,
                      target: targets.caloriesKcal,
                      progress: calorieProgress,
                    ),
                    const SizedBox(height: 24),
                    _MacroList(totals: totals, targets: targets),
                  ],
                );
              }

              return Row(
                children: [
                  _CalorieRing(
                    current: totals.caloriesKcal,
                    target: targets.caloriesKcal,
                    progress: calorieProgress,
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _MacroList(totals: totals, targets: targets),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  double _progress(int current, int target) {
    if (target <= 0) {
      return 0;
    }
    return (current / target).clamp(0.0, 1.0);
  }
}

class _CalorieRing extends StatelessWidget {
  const _CalorieRing({
    required this.current,
    required this.target,
    required this.progress,
  });

  final int current;
  final int target;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 156,
      height: 156,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 10,
              strokeCap: StrokeCap.round,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation(AppColors.lime),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatNumber(current),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '/ ${_formatNumber(target)} kcal',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
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

class _MacroList extends StatelessWidget {
  const _MacroList({required this.totals, required this.targets});

  final NutritionEntry totals;
  final DailyTargets targets;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MacroRow(
          label: 'Protein',
          current: totals.proteinG,
          target: targets.proteinG,
          color: AppColors.fitnessPurple,
        ),
        const SizedBox(height: 20),
        _MacroRow(
          label: 'Carbs',
          current: totals.carbsG,
          target: targets.carbsG,
          color: AppColors.fitnessGreen,
        ),
        const SizedBox(height: 20),
        _MacroRow(
          label: 'Fats',
          current: totals.fatsG,
          target: targets.fatsG,
          color: AppColors.fitnessWhite,
        ),
      ],
    );
  }
}

class _MacroRow extends StatelessWidget {
  const _MacroRow({
    required this.label,
    required this.current,
    required this.target,
    required this.color,
  });

  final String label;
  final int current;
  final int target;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final progress = target <= 0 ? 0.0 : (current / target).clamp(0.0, 1.0);

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
                children: [
                  TextSpan(text: '$current'),
                  TextSpan(
                    text: ' / ${target}g',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
