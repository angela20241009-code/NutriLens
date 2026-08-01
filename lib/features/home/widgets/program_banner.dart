import 'package:flutter/material.dart';
import 'package:nutrilens/l10n/app_localizations.dart';
import 'package:nutrilens/l10n/l10n_extensions.dart';
import 'package:nutrilens/models/user_profile.dart';
import 'package:nutrilens/theme/app_colors.dart';

class ProgramBanner extends StatelessWidget {
  const ProgramBanner({super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final programName = _programName(l10n, profile);
    final badge = _badge(profile);
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
              programName,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.electricBlue,
              ),
            ),
          ),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.electricBlue.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge,
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

  String _programName(AppLocalizations l10n, UserProfile profile) {
    final teamProgramName = profile.teamProgramName?.trim();
    if (teamProgramName != null && teamProgramName.isNotEmpty) {
      return teamProgramName;
    }

    final schoolName = profile.schoolName?.trim();
    final sportName = localizedSportName(l10n, profile.primarySportId);
    if (schoolName != null && schoolName.isNotEmpty && sportName.isNotEmpty) {
      return l10n.homeSchoolSportProgram(schoolName, sportName);
    }

    if (sportName.isNotEmpty) {
      return l10n.homeSportNutritionProgram(sportName);
    }

    return l10n.homePersonalNutritionProgram;
  }

  String? _badge(UserProfile profile) {
    final tier = profile.programTier?.trim();
    if (tier == null || tier.isEmpty) {
      return null;
    }
    return tier.toUpperCase();
  }
}
