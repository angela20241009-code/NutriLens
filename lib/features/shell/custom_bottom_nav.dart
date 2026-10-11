import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrilens/app/app_settings_scope.dart';
import 'package:nutrilens/l10n/app_localizations.dart';
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
  static const _scanButtonSize = 44.0;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final settings = AppSettingsScope.maybeOf(context);
    final accessibility = settings?.accessibilityModeEnabled ?? false;
    final iconSize = accessibility ? 30.0 : 24.0;
    final labelSize = accessibility ? 12.0 : 11.0;
    final scanIconSize = accessibility ? 26.0 : 22.0;
    final primary = ThemePaletteScope.primary(context);
    final onPrimary = ThemePaletteScope.onPrimary(context);
    final inactive = ThemePaletteScope.navInactive(context);
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;

    return Container(
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
              label: l10n.navHome,
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
              label: l10n.navMeals,
              selected: selectedIndex == 1,
              onTap: () => onTap(1),
              iconSize: iconSize,
              labelSize: labelSize,
              activeColor: primary,
              inactiveColor: inactive,
              boldLabels: accessibility,
            ),
            _ScanNavItem(
              selected: selectedIndex == 2,
              onTap: () => onTap(2),
              activeColor: primary,
              onActiveColor: onPrimary,
              inactiveColor: inactive,
              label: _scanTabLabel(languageCode),
              labelSize: labelSize,
              iconSize: scanIconSize,
              buttonSize: _scanButtonSize,
              boldLabels: accessibility,
            ),
            _NavItem(
              icon: Icons.calendar_today_rounded,
              label: l10n.navSchedule,
              selected: selectedIndex == 3,
              onTap: () => onTap(3),
              iconSize: iconSize,
              labelSize: labelSize,
              activeColor: primary,
              inactiveColor: inactive,
              boldLabels: accessibility,
            ),
            _NavItem(
              icon: CupertinoIcons.eyeglasses,
              label: _lensTabLabel(languageCode),
              selected: selectedIndex == 4,
              onTap: () => onTap(4),
              iconSize: iconSize,
              labelSize: labelSize,
              activeColor: primary,
              inactiveColor: inactive,
              boldLabels: accessibility,
            ),
            _NavItem(
              icon: Icons.person_rounded,
              label: l10n.navProfile,
              selected: selectedIndex == 5,
              onTap: () => onTap(5),
              iconSize: iconSize,
              labelSize: labelSize,
              activeColor: primary,
              inactiveColor: inactive,
              boldLabels: accessibility,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanNavItem extends StatelessWidget {
  const _ScanNavItem({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.activeColor,
    required this.onActiveColor,
    required this.inactiveColor,
    required this.labelSize,
    required this.iconSize,
    required this.buttonSize,
    required this.boldLabels,
  });

  final bool selected;
  final String label;
  final VoidCallback onTap;
  final Color activeColor;
  final Color onActiveColor;
  final Color inactiveColor;
  final double labelSize;
  final double iconSize;
  final double buttonSize;
  final bool boldLabels;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: activeColor.withValues(alpha: 0.45),
                          blurRadius: 16,
                          spreadRadius: 1,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                color: onActiveColor,
                size: iconSize,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: labelSize,
                fontWeight: boldLabels ? FontWeight.w700 : FontWeight.w600,
                color: selected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _scanTabLabel(String languageCode) {
  return switch (languageCode) {
    'es' => 'Escanear',
    'zh' => '扫描',
    _ => 'Scan',
  };
}

String _lensTabLabel(String languageCode) {
  return switch (languageCode) {
    'es' => 'Lente',
    'zh' => '镜头',
    _ => 'Lens',
  };
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
