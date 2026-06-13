import 'package:flutter/material.dart';
import 'package:nutrilens/features/shell/app_mode.dart';
import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/theme/app_colors.dart';

class ModeSegmentedControl extends StatelessWidget {
  const ModeSegmentedControl({
    super.key,
    required this.mode,
    required this.style,
    required this.onModeChanged,
  });

  final AppMode mode;
  final SegmentControlStyle style;
  final ValueChanged<AppMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return switch (style) {
      SegmentControlStyle.minimalTabs => _MinimalTabsModeControl(
        mode: mode,
        onModeChanged: onModeChanged,
      ),
      SegmentControlStyle.classicPill => _ClassicPillModeControl(
        mode: mode,
        onModeChanged: onModeChanged,
      ),
    };
  }
}

class _MinimalTabsModeControl extends StatelessWidget {
  const _MinimalTabsModeControl({
    required this.mode,
    required this.onModeChanged,
  });

  final AppMode mode;
  final ValueChanged<AppMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 10, 28, 14),
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
    );
  }
}

class _ClassicPillModeControl extends StatelessWidget {
  const _ClassicPillModeControl({
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
              child: _ClassicSegment(
                label: 'Meal Tracking',
                selected: mode == AppMode.mealTracking,
                selectedColor: AppColors.lime,
                selectedTextColor: AppColors.onLime,
                onTap: () => onModeChanged(AppMode.mealTracking),
              ),
            ),
            Expanded(
              child: _ClassicSegment(
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

class _ClassicSegment extends StatelessWidget {
  const _ClassicSegment({
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
