import 'package:flutter/material.dart';
import 'package:nutrilens/theme/app_colors.dart';

class SleepLogScreen extends StatelessWidget {
  const SleepLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Sleep Log',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
