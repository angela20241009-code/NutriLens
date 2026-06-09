import 'package:flutter/material.dart';
import 'package:nutrilens/app/session_scope.dart';
import 'package:nutrilens/app/user_scope.dart';
import 'package:nutrilens/features/profile/link_email_dialog.dart';
import 'package:nutrilens/features/profile/sign_out_dialog.dart';
import 'package:nutrilens/features/profile/widgets/settings_section.dart';
import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/services/user_repository.dart';
import 'package:nutrilens/theme/app_colors.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  late UserRepository _repository;
  late String _uid;
  late Future<void> Function() _signOutUser;
  bool _hasScopes = false;
  UserAccount? _account;
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAccount();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userScope = UserScope.of(context);
    final sessionScope = SessionScope.of(context);
    final scopeChanged =
        !_hasScopes ||
        _repository != userScope.repository ||
        _uid != userScope.uid ||
        _signOutUser != sessionScope.signOut;

    _repository = userScope.repository;
    _uid = userScope.uid;
    _signOutUser = sessionScope.signOut;
    _hasScopes = true;

    if (scopeChanged && !_loading) {
      setState(() {
        _loading = true;
      });
      _loadAccount();
    }
  }

  Future<void> _loadAccount() async {
    try {
      final account = await _repository.getAccount(_uid);
      if (mounted) {
        setState(() {
          _account = account;
          _loading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to load account: $error')),
        );
      }
    }
  }

  Future<void> _linkEmail() async {
    if (_busy || _account == null) {
      return;
    }

    setState(() {
      _busy = true;
    });

    final updated = await showLinkEmailDialog(
      context: context,
      repository: _repository,
      uid: _uid,
    );

    if (mounted) {
      setState(() {
        _busy = false;
        if (updated != null) {
          _account = updated;
        }
      });
      if (updated != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully')),
        );
      }
    }
  }

  Future<void> _signOut() async {
    if (_busy || _account == null) {
      return;
    }

    final confirmed = await showSignOutConfirmationDialog(
      context: context,
      isAnonymous: _account!.isAnonymous,
      email: _account!.email,
    );

    if (!confirmed || !mounted) {
      return;
    }

    setState(() {
      _busy = true;
    });

    try {
      await _signOutUser();
    } catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Unable to sign out: $error')));
      }
    }
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature coming soon')));
  }

  String get _emailDisplay {
    final email = _account?.email;
    if (email != null && email.isNotEmpty) {
      return email;
    }
    return 'Not linked';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Settings'),
        leading: BackButton(
          color: AppColors.lime,
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    SettingsSection(
                      title: 'Account',
                      children: [
                        SettingsRow(
                          label: 'Email',
                          value: _emailDisplay,
                          showChevron: false,
                          onTap: null,
                        ),
                        if (_account?.isAnonymous == true)
                          SettingsRow(
                            label: 'Create account',
                            onTap: _busy ? null : _linkEmail,
                          ),
                        SettingsRow(
                          label: 'Sign out',
                          labelColor: AppColors.orange,
                          showDivider: false,
                          onTap: _busy ? null : _signOut,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SettingsSection(
                      title: 'App',
                      children: [
                        SettingsRow(
                          label: 'Notifications',
                          onTap: _busy
                              ? null
                              : () => _showComingSoon('Notifications'),
                        ),
                        SettingsRow(
                          label: 'Units',
                          showDivider: false,
                          onTap: _busy ? null : () => _showComingSoon('Units'),
                        ),
                      ],
                    ),
                  ],
                ),
                if (_busy)
                  const ColoredBox(
                    color: Color(0x66000000),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
    );
  }
}
