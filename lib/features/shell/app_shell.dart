import 'package:flutter/material.dart';
import 'package:nutrilens/features/shell/app_mode.dart';
import 'package:nutrilens/features/shell/meal_tracking_shell.dart';
import 'package:nutrilens/features/shell/mode_segmented_control.dart';
import 'package:nutrilens/features/shell/sleep_mode_shell.dart';
import 'package:nutrilens/theme/app_colors.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppMode _appMode = AppMode.mealTracking;
  int _mealTabIndex = 0;
  int _sleepTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ModeSegmentedControl(
              mode: _appMode,
              onModeChanged: (mode) => setState(() => _appMode = mode),
            ),
            Expanded(
              child: _appMode == AppMode.mealTracking
                  ? MealTrackingShell(
                      selectedIndex: _mealTabIndex,
                      onIndexChanged: (i) => setState(() => _mealTabIndex = i),
                    )
                  : SleepModeShell(
                      selectedIndex: _sleepTabIndex,
                      onIndexChanged: (i) => setState(() => _sleepTabIndex = i),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
