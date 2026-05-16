import 'package:flutter/material.dart';
import 'package:nutrilens/features/shell/app_mode.dart';
import 'package:nutrilens/theme/app_colors.dart';

class ModeSegmentedControl extends StatelessWidget {
  const ModeSegmentedControl({
    super.key,
    required this.mode,
    required this.onModeChanged,
  });

  final AppMode mode;
  final ValueChanged<AppMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            Expanded(
              child: _Segment(
                label: 'Meal Tracking',
                selected: mode == AppMode.mealTracking,
                selectedColor: AppColors.lime,
                selectedTextColor: AppColors.onLime,
                onTap: () => onModeChanged(AppMode.mealTracking),
              ),
            ),
            Expanded(
              child: _Segment(
                label: 'Sleep',
                selected: mode == AppMode.sleep,
                selectedColor: AppColors.sleepAccent,
                selectedTextColor: AppColors.textPrimary,
                onTap: () => onModeChanged(AppMode.sleep),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.selectedTextColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color selectedColor;
  final Color selectedTextColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? selectedTextColor : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
