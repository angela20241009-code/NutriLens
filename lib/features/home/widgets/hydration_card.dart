import 'package:flutter/material.dart';
import 'package:nutrilens/data/mock_home_data.dart';
import 'package:nutrilens/theme/app_colors.dart';

class HydrationCard extends StatelessWidget {
  const HydrationCard({super.key});

  @override
  Widget build(BuildContext context) {
    const current = MockHomeData.hydrationCurrent;
    const perPill = 1.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.electricBlue,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.water_drop_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hydration',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  '${MockHomeData.hydrationCurrent}L / ${MockHomeData.hydrationTarget}L target',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _HydrationPill(
                fillAmount: (current - 0 * perPill).clamp(0.0, perPill) / perPill,
              ),
              const SizedBox(width: 6),
              _HydrationPill(
                fillAmount:
                    (current - 1 * perPill).clamp(0.0, perPill) / perPill,
              ),
              const SizedBox(width: 6),
              _HydrationPill(
                fillAmount:
                    (current - 2 * perPill).clamp(0.0, perPill) / perPill,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HydrationPill extends StatelessWidget {
  const _HydrationPill({required this.fillAmount});

  final double fillAmount;

  @override
  Widget build(BuildContext context) {
    const height = 36.0;
    const width = 10.0;

    final clampedFill = fillAmount.clamp(0.0, 1.0);

    if (clampedFill >= 1.0) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: width,
          height: height * clampedFill,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }
}
