import 'package:flutter/material.dart';
import 'package:nutrilens/theme/app_colors.dart';

Future<bool> showDeleteAccountConfirmationDialog({
  required BuildContext context,
  required bool isAnonymous,
  String? email,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: const Text('Delete account?'),
        content: Text(
          isAnonymous
              ? 'This permanently deletes your guest account and all logged meals, sleep, and profile data on this device. This cannot be undone.'
              : 'This permanently deletes ${email ?? 'your account'} and all associated data. This cannot be undone.',
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
            child: const Text('Delete account'),
          ),
        ],
      );
    },
  );

  return result == true;
}
