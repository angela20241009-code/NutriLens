import 'package:flutter/material.dart';
import 'package:nutrilens/features/shell/app_shell.dart';
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
      home: const AppShell(),
    );
  }
}
