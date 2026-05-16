import 'package:flutter/material.dart';
import 'package:nutrilens/data/mock_home_data.dart';
import 'package:nutrilens/theme/app_colors.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                MockHomeData.greeting,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                '${MockHomeData.userName} 👋',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ],
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.lime, width: 2),
            color: AppColors.cardDark,
          ),
          child: const Icon(
            Icons.person_rounded,
            color: AppColors.textMuted,
            size: 28,
          ),
        ),
      ],
    );
  }
}
