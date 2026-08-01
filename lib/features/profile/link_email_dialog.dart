import 'package:flutter/material.dart';
import 'package:nutrilens/l10n/app_localizations.dart';
import 'package:nutrilens/l10n/l10n_extensions.dart';
import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/services/user_repository.dart';
import 'package:nutrilens/theme/app_colors.dart';

Future<UserAccount?> showLinkEmailDialog({
  required BuildContext context,
  required UserRepository repository,
  required String uid,
}) async {
  final credentials = await showDialog<_LinkEmailCredentials>(
    context: context,
    builder: (_) => const _LinkEmailDialog(),
  );

  if (credentials == null) {
    return null;
  }

  try {
    return await repository.linkEmail(
      uid: uid,
      email: credentials.email,
      password: credentials.password,
    );
  } catch (error) {
    if (context.mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${l10n.createAccount}: ${friendlyAuthErrorMessage(l10n, error)}',
          ),
        ),
      );
    }
    return null;
  }
}

class _LinkEmailCredentials {
  const _LinkEmailCredentials({required this.email, required this.password});

  final String email;
  final String password;
}

class _LinkEmailDialog extends StatefulWidget {
  const _LinkEmailDialog();

  @override
  State<_LinkEmailDialog> createState() => _LinkEmailDialogState();
}

class _LinkEmailDialogState extends State<_LinkEmailDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      _LinkEmailCredentials(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      backgroundColor: AppColors.cardDark,
      title: Text(l10n.createAccount),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: l10n.email),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.authValidationEmailRequired;
                }
                if (!value.contains('@')) {
                  return l10n.authValidationEmailInvalid;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.authPassword),
              validator: (value) {
                if (value == null || value.trim().length < 6) {
                  return l10n.authValidationPasswordMin;
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
        FilledButton(onPressed: _submit, child: Text(l10n.authCreate)),
      ],
    );
  }
}
