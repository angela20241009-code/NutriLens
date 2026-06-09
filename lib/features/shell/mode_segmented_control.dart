import 'package:flutter/material.dart';
import 'package:nutrilens/features/shell/app_mode.dart';
import 'package:nutrilens/theme/app_colors.dart';

class ModeSegmentedControl extends StatelessWidget {
  const ModeSegmentedControl({
    super.key,
    required this.mode,
    required this.onModeChanged,
    required this.onProfilePressed,
  });

  final AppMode mode;
  final ValueChanged<AppMode> onModeChanged;
  final VoidCallback onProfilePressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 10, 28, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _ModeTab(
                        label: 'Meal Tracking',
                        selected: mode == AppMode.mealTracking,
                        selectedColor: AppColors.lime,
                        onTap: () => onModeChanged(AppMode.mealTracking),
                      ),
                    ),
                    Expanded(
                      child: _ModeTab(
                        label: 'Sleep',
                        selected: mode == AppMode.sleep,
                        selectedColor: AppColors.sleepAccent,
                        onTap: () => onModeChanged(AppMode.sleep),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                Stack(
                  children: [
                    Container(height: 1, color: AppColors.cardDark),
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      alignment: mode == AppMode.mealTracking
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: FractionallySizedBox(
                        widthFactor: 0.5,
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: 156,
                            height: 3,
                            decoration: BoxDecoration(
                              color: mode == AppMode.mealTracking
                                  ? AppColors.lime
                                  : AppColors.sleepAccent,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          _ProfileShortcut(onTap: onProfilePressed),
        ],
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        style: TextStyle(
          fontSize: 14,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          color: selected ? selectedColor : AppColors.textMuted,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: selected ? 10 : 0,
                height: 10,
                margin: EdgeInsets.only(right: selected ? 8 : 0),
                decoration: BoxDecoration(
                  color: selectedColor,
                  shape: BoxShape.circle,
                ),
              ),
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileShortcut extends StatelessWidget {
  const _ProfileShortcut({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.lime, width: 2),
          color: AppColors.cardDarker,
        ),
        child: const Icon(
          Icons.person_rounded,
          color: AppColors.textMuted,
          size: 25,
        ),
      ),
    );
  }
}
