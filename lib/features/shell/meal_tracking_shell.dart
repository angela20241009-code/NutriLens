import 'package:flutter/material.dart';
import 'package:nutrilens/features/home/home_dashboard_screen.dart';
import 'package:nutrilens/features/meals/meals_screen.dart';
import 'package:nutrilens/features/profile/profile_screen.dart';
import 'package:nutrilens/features/scan/scan_screen.dart';
import 'package:nutrilens/features/schedule/schedule_screen.dart';
import 'package:nutrilens/features/shell/custom_bottom_nav.dart';

class MealTrackingShell extends StatelessWidget {
  const MealTrackingShell({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeDashboardScreen(
        onMealsTap: () => onIndexChanged(1),
        onProfileTap: () => onIndexChanged(4),
      ),
      const MealsScreen(),
      const ScanScreen(),
      ScheduleScreen(isActive: selectedIndex == 3),
      const ProfileScreen(),
    ];

    return Column(
      children: [
        Expanded(
          child: IndexedStack(index: selectedIndex, children: screens),
        ),
        CustomBottomNav(selectedIndex: selectedIndex, onTap: onIndexChanged),
      ],
    );
  }
}
