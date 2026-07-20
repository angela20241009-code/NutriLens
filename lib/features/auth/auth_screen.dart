import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutrilens/features/profile/meal_preferences_form.dart';
import 'package:nutrilens/models/dietary_profile.dart';
import 'package:nutrilens/theme/app_colors.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.onCreateAccount,
    required this.onSignIn,
    required this.onContinueAsGuest,
  });

  final Future<void> Function(
    String email,
    String password,
    DietaryProfile dietaryProfile,
  )
  onCreateAccount;
  final Future<void> Function(String email, String password) onSignIn;
  final Future<void> Function(DietaryProfile dietaryProfile) onContinueAsGuest;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _allergensController = TextEditingController();
  final _restrictionsController = TextEditingController();
  final _otherStyleController = TextEditingController();
  final _selectedStyles = <String>{};
  bool _othersSelected = false;

  AuthMode _mode = AuthMode.createAccount;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _allergensController.dispose();
    _restrictionsController.dispose();
    _otherStyleController.dispose();
    super.dispose();
  }

  DietaryProfile get _dietaryProfile => dietaryProfileFromForm(
    selectedStyles: _selectedStyles,
    allergensText: _allergensController.text,
    restrictionsText: _restrictionsController.text,
    otherStyleText: _otherStyleController.text,
    othersSelected: _othersSelected,
  );

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _busy) {
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      if (_mode == AuthMode.createAccount) {
        await widget.onCreateAccount(email, password, _dietaryProfile);
      } else {
        await widget.onSignIn(email, password);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = friendlyAuthError(error);
        _busy = false;
      });
    }
  }

  Future<void> _continueAsGuest() async {
    if (_busy) {
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.onContinueAsGuest(_dietaryProfile);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = friendlyAuthError(error);
        _busy = false;
      });
    }
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Enter an email';
    }
    if (!email.contains('@')) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value?.trim() ?? '';
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isCreate = _mode == AuthMode.createAccount;
    final showPreferences = isCreate;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'NutriLens',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isCreate ? 'Create your account' : 'Welcome back',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 28),
                    SegmentedButton<AuthMode>(
                      segments: const [
                        ButtonSegment(
                          value: AuthMode.createAccount,
                          icon: Icon(Icons.person_add_outlined),
                          label: Text('Create'),
                        ),
                        ButtonSegment(
                          value: AuthMode.signIn,
                          icon: Icon(Icons.login),
                          label: Text('Sign in'),
                        ),
                      ],
                      selected: {_mode},
                      onSelectionChanged: _busy
                          ? null
                          : (selection) {
                              setState(() {
                                _mode = selection.first;
                                _error = null;
                              });
                            },
                    ),
                    if (showPreferences) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Meal preferences',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tell us what you like and what to avoid before you sign in.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      MealPreferencesForm(
                        selectedStyles: _selectedStyles,
                        onStyleToggled: (style) {
                          setState(() {
                            if (_selectedStyles.contains(style)) {
                              _selectedStyles.remove(style);
                            } else {
                              _selectedStyles.add(style);
                            }
                          });
                        },
                        allergensController: _allergensController,
                        restrictionsController: _restrictionsController,
                        otherStyleController: _otherStyleController,
                        othersSelected: _othersSelected,
                        onOthersSelectedChanged: (selected) {
                          setState(() => _othersSelected = selected);
                        },
                        enabled: !_busy,
                        useLimeBorders: true,
                      ),
                      const SizedBox(height: 24),
                    ],
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(labelText: 'Email'),
                      enabled: !_busy,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      autofillHints: [
                        isCreate
                            ? AutofillHints.newPassword
                            : AutofillHints.password,
                      ],
                      decoration: const InputDecoration(labelText: 'Password'),
                      enabled: !_busy,
                      validator: _validatePassword,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        _error!,
                        style: const TextStyle(color: AppColors.orange),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: _busy ? null : _submit,
                        child: _busy
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.onLime,
                                ),
                              )
                            : Text(isCreate ? 'Create account' : 'Sign in'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: _busy ? null : _continueAsGuest,
                      icon: const Icon(Icons.person_outline),
                      label: const Text('Continue as guest'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum AuthMode { createAccount, signIn }

String friendlyAuthError(Object error) {
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'weak-password' => 'Use a stronger password.',
      'email-already-in-use' => 'That email already has an account.',
      'invalid-email' => 'Enter a valid email address.',
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' => 'Email or password is incorrect.',
      'network-request-failed' => 'Check your connection and try again.',
      _ => error.message ?? 'Authentication failed. Try again.',
    };
  }
  final message = error.toString();
  if (message.contains('email-already-in-use')) {
    return 'That email already has an account.';
  }
  if (message.contains('invalid-credential')) {
    return 'Email or password is incorrect.';
  }
  return 'Authentication failed. Try again.';
}
