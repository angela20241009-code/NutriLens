import 'package:flutter/material.dart';
import 'package:nutrilens/l10n/app_localizations.dart';
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

Future<String?> showDeleteAccountReauthDialog({
  required BuildContext context,
  String? email,
}) async {
  return showDialog<String>(
    context: context,
    builder: (context) => _DeleteAccountReauthDialog(email: email),
  );
}

class _DeleteAccountReauthDialog extends StatefulWidget {
  const _DeleteAccountReauthDialog({this.email});

  final String? email;

  @override
  State<_DeleteAccountReauthDialog> createState() =>
      _DeleteAccountReauthDialogState();
}

class _DeleteAccountReauthDialogState extends State<_DeleteAccountReauthDialog> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    Navigator.of(context).pop(_passwordController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      backgroundColor: AppColors.cardDark,
      title: Text(l10n.deleteAccountReauthTitle),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.deleteAccountReauthBody),
            if (widget.email != null && widget.email!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                widget.email!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: l10n.deleteAccountReauthPassword,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().length < 6) {
                  return l10n.authErrorWeakPassword;
                }
                return null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.orange,
            foregroundColor: AppColors.textPrimary,
          ),
          child: Text(l10n.deleteAccount),
        ),
      ],
    );
  }
}
