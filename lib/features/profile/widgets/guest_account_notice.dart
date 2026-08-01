import 'package:flutter/material.dart';
import 'package:nutrilens/l10n/app_localizations.dart';
import 'package:nutrilens/theme/app_colors.dart';

class GuestAccountNotice extends StatelessWidget {
  const GuestAccountNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.orange.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: AppColors.orange.withValues(alpha: 0.95),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.guestAccountNotice,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
