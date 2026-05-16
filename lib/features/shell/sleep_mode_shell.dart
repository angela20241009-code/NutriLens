import 'package:flutter/material.dart';
import 'package:nutrilens/features/profile/profile_screen.dart';
import 'package:nutrilens/features/shell/sleep_bottom_nav.dart';
import 'package:nutrilens/features/sleep/sleep_dashboard_screen.dart';
import 'package:nutrilens/features/sleep/sleep_log_screen.dart';

class SleepModeShell extends StatelessWidget {
  const SleepModeShell({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const SleepDashboardScreen(),
      const SleepLogScreen(),
      const ProfileScreen(),
    ];

    return Column(
      children: [
        Expanded(
          child: IndexedStack(
            index: selectedIndex,
            children: screens,
          ),
        ),
        SleepBottomNav(
          selectedIndex: selectedIndex,
          onTap: onIndexChanged,
        ),
      ],
    );
  }
}
