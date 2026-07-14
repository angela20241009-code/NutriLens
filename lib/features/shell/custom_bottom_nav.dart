import 'package:flutter/material.dart';
import 'package:nutrilens/app/app_settings_scope.dart';
import 'package:nutrilens/theme/theme_palette_scope.dart';

class CustomBottomNav extends StatelessWidget {
  const CustomBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  static const _navHeight = 80.0;
  static const _fabSize = 60.0;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final settings = AppSettingsScope.maybeOf(context);
    final accessibility = settings?.accessibilityModeEnabled ?? false;
    final iconSize = accessibility ? 32.0 : 28.0;
    final labelSize = accessibility ? 13.0 : 12.0;
    final fabIconSize = accessibility ? 32.0 : 30.0;
    final primary = ThemePaletteScope.primary(context);
    final onPrimary = ThemePaletteScope.onPrimary(context);
    final inactive = ThemePaletteScope.navInactive(context);

    return SizedBox(
      height: _navHeight + bottomPadding + 12,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: _navHeight + bottomPadding,
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
                    icon: Icons.home_rounded,
                    label: 'Home',
                    selected: selectedIndex == 0,
                    onTap: () => onTap(0),
                    iconSize: iconSize,
                    labelSize: labelSize,
                    activeColor: primary,
                    inactiveColor: inactive,
                    boldLabels: accessibility,
                  ),
                  _NavItem(
                    icon: Icons.restaurant_rounded,
                    label: 'Meals',
                    selected: selectedIndex == 1,
                    onTap: () => onTap(1),
                    iconSize: iconSize,
                    labelSize: labelSize,
                    activeColor: primary,
                    inactiveColor: inactive,
                    boldLabels: accessibility,
                  ),
                  SizedBox(width: _fabSize + 16),
                  _NavItem(
                    icon: Icons.calendar_today_rounded,
                    label: 'Schedule',
                    selected: selectedIndex == 3,
                    onTap: () => onTap(3),
                    iconSize: iconSize,
                    labelSize: labelSize,
                    activeColor: primary,
                    inactiveColor: inactive,
                    boldLabels: accessibility,
                  ),
                  _NavItem(
                    icon: Icons.person_rounded,
                    label: 'Profile',
                    selected: selectedIndex == 4,
                    onTap: () => onTap(4),
                    iconSize: iconSize,
                    labelSize: labelSize,
                    activeColor: primary,
                    inactiveColor: inactive,
                    boldLabels: accessibility,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: bottomPadding + 22,
            child: GestureDetector(
              onTap: () => onTap(2),
              child: Container(
                width: _fabSize,
                height: _fabSize,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(18),
                  border: accessibility
                      ? Border.all(color: Colors.white, width: 2)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.5),
                      blurRadius: accessibility ? 24 : 20,
                      spreadRadius: accessibility ? 3 : 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  color: onPrimary,
                  size: fabIconSize,
                ),
              ),
            ),
          ),
        ],
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
