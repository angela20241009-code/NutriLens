import 'package:flutter/material.dart';
import 'package:nutrilens/features/home/widgets/home_header.dart';
import 'package:nutrilens/features/home/widgets/hydration_card.dart';
import 'package:nutrilens/features/home/widgets/meal_plan_section.dart';
import 'package:nutrilens/features/home/widgets/next_session_card.dart';
import 'package:nutrilens/features/home/widgets/program_banner.dart';
import 'package:nutrilens/features/home/widgets/todays_fuel_card.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          HomeHeader(),
          SizedBox(height: 16),
          ProgramBanner(),
          SizedBox(height: 20),
          TodaysFuelCard(),
          SizedBox(height: 16),
          NextSessionCard(),
          SizedBox(height: 24),
          MealPlanSection(),
          SizedBox(height: 20),
          HydrationCard(),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
