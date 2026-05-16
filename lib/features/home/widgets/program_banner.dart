import 'package:flutter/material.dart';
import 'package:nutrilens/data/mock_home_data.dart';
import 'package:nutrilens/theme/app_colors.dart';

class ProgramBanner extends StatelessWidget {
  const ProgramBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.programBannerBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.electricBlue.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.apartment_rounded,
            size: 18,
            color: AppColors.electricBlue.withValues(alpha: 0.9),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              MockHomeData.programName,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.electricBlue,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.electricBlue.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              MockHomeData.programBadge,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.electricBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
