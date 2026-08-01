import 'package:flutter/material.dart';
import 'package:nutrilens/l10n/app_localizations.dart';
import 'package:nutrilens/theme/app_colors.dart';

Future<bool> showSignOutConfirmationDialog({
  required BuildContext context,
  required bool isAnonymous,
  String? email,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      return AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text(l10n.signOutTitle),
        content: Text(
          isAnonymous
              ? l10n.signOutGuestBody
              : l10n.signOutAccountBody(email ?? l10n.yourAccount),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.orange,
              foregroundColor: AppColors.textPrimary,
            ),
            child: Text(l10n.signOut),
          ),
        ],
      );
    },
  );

  return result == true;
}
