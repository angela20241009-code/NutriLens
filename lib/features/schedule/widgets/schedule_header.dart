import 'package:flutter/material.dart';
import 'package:nutrilens/theme/app_colors.dart';

class ScheduleHeader extends StatelessWidget {
  const ScheduleHeader({
    super.key,
    required this.onAddTap,
  });

  final VoidCallback onAddTap;

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
                'Schedule',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Train · Match · Fuel',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onAddTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.lime,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.add_rounded,
              color: AppColors.onLime,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}
