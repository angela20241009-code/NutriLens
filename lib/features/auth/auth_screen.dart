import 'package:flutter/material.dart';
import 'package:nutrilens/app/app_locale_scope.dart';
import 'package:nutrilens/features/settings/language_picker.dart';
import 'package:nutrilens/l10n/app_localizations.dart';
import 'package:nutrilens/l10n/l10n_extensions.dart';
import 'package:nutrilens/theme/app_colors.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.onCreateAccount,
    required this.onSignIn,
    required this.onContinueAsGuest,
  });

  final Future<void> Function(String email, String password) onCreateAccount;
  final Future<void> Function(String email, String password) onSignIn;
  final Future<void> Function() onContinueAsGuest;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  AuthMode _mode = AuthMode.createAccount;
  bool _busy = false;
  bool _acceptedLegalTerms = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _busy) {
      return;
    }
    if (_mode == AuthMode.createAccount && !_acceptedLegalTerms) {
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
        await widget.onCreateAccount(email, password);
      } else {
        await widget.onSignIn(email, password);
      }
    } catch (error) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _error = friendlyAuthErrorMessage(l10n, error);
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
      await widget.onContinueAsGuest();
    } catch (error) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _error = friendlyAuthErrorMessage(l10n, error);
        _busy = false;
      });
    }
  }

  String? _validateEmail(String? value, AppLocalizations l10n) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return l10n.authValidationEmailRequired;
    }
    if (!email.contains('@')) {
      return l10n.authValidationEmailInvalid;
    }
    return null;
  }

  String? _validatePassword(String? value, AppLocalizations l10n) {
    final password = value?.trim() ?? '';
    if (password.length < 6) {
      return l10n.authValidationPasswordMin;
    }
    return null;
  }

  Future<void> _pickLanguage() async {
    if (_busy) {
      return;
    }
    await pickAndApplyLanguage(context: context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeScope = AppLocaleScope.of(context);
    final isCreate = _mode == AuthMode.createAccount;
    final canSubmitCreateAccount = !isCreate || _acceptedLegalTerms;

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
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _busy ? null : _pickLanguage,
                        icon: const Icon(Icons.language),
                        label: Text(localeScope.language.label(l10n)),
                      ),
                    ),
                    Text(
                      l10n.appTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isCreate ? l10n.authCreateTitle : l10n.authWelcomeBack,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 28),
                    SegmentedButton<AuthMode>(
                      segments: [
                        ButtonSegment(
                          value: AuthMode.createAccount,
                          icon: const Icon(Icons.person_add_outlined),
                          label: Text(l10n.authCreate),
                        ),
                        ButtonSegment(
                          value: AuthMode.signIn,
                          icon: const Icon(Icons.login),
                          label: Text(l10n.authSignIn),
                        ),
                      ],
                      selected: {_mode},
                      onSelectionChanged: _busy
                          ? null
                          : (selection) {
                              setState(() {
                                _mode = selection.first;
                                _error = null;
                                if (_mode != AuthMode.createAccount) {
                                  _acceptedLegalTerms = false;
                                }
                              });
                            },
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: InputDecoration(labelText: l10n.authEmail),
                      enabled: !_busy,
                      validator: (value) => _validateEmail(value, l10n),
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
                      decoration: InputDecoration(labelText: l10n.authPassword),
                      enabled: !_busy,
                      validator: (value) => _validatePassword(value, l10n),
                      onFieldSubmitted: (_) {
                        if (canSubmitCreateAccount) {
                          _submit();
                        }
                      },
                    ),
                    if (isCreate) ...[
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        value: _acceptedLegalTerms,
                        onChanged: _busy
                            ? null
                            : (accepted) {
                                setState(
                                  () => _acceptedLegalTerms = accepted ?? false,
                                );
                              },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.lime,
                        checkColor: AppColors.onLime,
                        title: Text(
                          l10n.authLegalAgreement,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        subtitle: Text(
                          '${l10n.authPrivacyPolicy} • ${l10n.authTermsAndConditions}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
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
                        onPressed: _busy || !canSubmitCreateAccount
                            ? null
                            : _submit,
                        child: _busy
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.onLime,
                                ),
                              )
                            : Text(
                                isCreate
                                    ? l10n.authCreateAccount
                                    : l10n.authSignIn,
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: _busy ? null : _continueAsGuest,
                      icon: const Icon(Icons.person_outline),
                      label: Text(l10n.authContinueAsGuest),
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
