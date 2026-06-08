import 'package:flutter/material.dart';
import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/services/user_repository.dart';
import 'package:nutrilens/theme/app_colors.dart';

Future<UserAccount?> showLinkEmailDialog({
  required BuildContext context,
  required UserRepository repository,
  required String uid,
}) async {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: const Text('Link email'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter an email';
                  }
                  if (!value.contains('@')) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('Link'),
          ),
        ],
      );
    },
  );

  if (confirmed != true) {
    emailController.dispose();
    passwordController.dispose();
    return null;
  }

  try {
    return await repository.linkEmail(
      uid: uid,
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to link email: $error')),
      );
    }
    return null;
  } finally {
    emailController.dispose();
    passwordController.dispose();
  }
}
