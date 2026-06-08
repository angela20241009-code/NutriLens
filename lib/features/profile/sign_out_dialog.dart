import 'package:flutter/material.dart';
import 'package:nutrilens/theme/app_colors.dart';

Future<bool> showSignOutConfirmationDialog({
  required BuildContext context,
  required bool isAnonymous,
  String? email,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: const Text('Sign out?'),
        content: Text(
          isAnonymous
              ? 'You haven\'t linked an email. Signing out may lose your data on this device.'
              : 'Sign out of ${email ?? 'your account'}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.orange,
              foregroundColor: AppColors.textPrimary,
            ),
            child: const Text('Sign out'),
          ),
        ],
      );
    },
  );

  return result == true;
}
