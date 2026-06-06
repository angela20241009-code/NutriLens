import 'package:flutter/material.dart';
import 'package:nutrilens/app/user_scope.dart';
import 'package:nutrilens/features/onboarding/onboarding_flow.dart';
import 'package:nutrilens/features/shell/app_shell.dart';
import 'package:nutrilens/models/user_account.dart';
import 'package:nutrilens/theme/app_theme.dart';

class NutriLensApp extends StatelessWidget {
  const NutriLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriLens',
      theme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: const _AppEntryGate(),
    );
  }
}

class _AppEntryGate extends StatefulWidget {
  const _AppEntryGate();

  @override
  State<_AppEntryGate> createState() => _AppEntryGateState();
}

class _AppEntryGateState extends State<_AppEntryGate> {
  Future<UserAccount?>? _accountFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _accountFuture ??= () {
      final scope = UserScope.of(context);
      return scope.repository.getAccount(scope.uid);
    }();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserAccount?>(
      future: _accountFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Failed to load account:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final account = snapshot.data;
        if (account?.onboardingCompleted == true) {
          return const AppShell();
        }

        return const OnboardingFlow();
      },
    );
  }
}
