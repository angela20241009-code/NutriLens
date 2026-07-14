import 'package:flutter/material.dart';
import 'package:nutrilens/app/app_settings_scope.dart';
import 'package:nutrilens/theme/theme_palette_scope.dart';

class SleepBottomNav extends StatelessWidget {
  const SleepBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final settings = AppSettingsScope.maybeOf(context);
    final accessibility = settings?.accessibilityModeEnabled ?? false;
    final iconSize = accessibility ? 32.0 : 28.0;
    final labelSize = accessibility ? 13.0 : 12.0;
    final accent = ThemePaletteScope.secondary(context);
    final inactive = ThemePaletteScope.navInactive(context);

    return Container(
      height: 80 + bottomPadding,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: accessibility
                ? Colors.white.withValues(alpha: 0.24)
                : Colors.white.withValues(alpha: 0.12),
            width: accessibility ? 1.0 : 0.5,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Row(
          children: [
            _NavItem(
              icon: Icons.bedtime_rounded,
              label: 'Sleep',
              selected: selectedIndex == 0,
              onTap: () => onTap(0),
              iconSize: iconSize,
              labelSize: labelSize,
              activeColor: accent,
              inactiveColor: inactive,
              boldLabels: accessibility,
            ),
            _NavItem(
              icon: Icons.edit_note_rounded,
              label: 'Log',
              selected: selectedIndex == 1,
              onTap: () => onTap(1),
              iconSize: iconSize,
              labelSize: labelSize,
              activeColor: accent,
              inactiveColor: inactive,
              boldLabels: accessibility,
            ),
            _NavItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              selected: selectedIndex == 2,
              onTap: () => onTap(2),
              iconSize: iconSize,
              labelSize: labelSize,
              activeColor: accent,
              inactiveColor: inactive,
              boldLabels: accessibility,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.iconSize,
    required this.labelSize,
    required this.activeColor,
    required this.inactiveColor,
    required this.boldLabels,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double iconSize;
  final double labelSize;
  final Color activeColor;
  final Color inactiveColor;
  final bool boldLabels;

  @override
  Widget build(BuildContext context) {
    final color = selected ? activeColor : inactiveColor;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: iconSize),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: labelSize,
                fontWeight: boldLabels ? FontWeight.w700 : FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
