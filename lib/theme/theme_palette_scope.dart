import 'package:flutter/material.dart';
import 'package:nutrilens/models/app_theme_palette.dart';
import 'package:nutrilens/theme/app_colors.dart';

class ThemePaletteScope extends InheritedWidget {
  const ThemePaletteScope({
    super.key,
    required this.palette,
    required super.child,
  });

  final AppThemePalette palette;

  static AppThemePalette of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<ThemePaletteScope>()
            ?.palette ??
        AppThemePalette.classic;
  }

  static Color primary(BuildContext context) => of(context).primary;

  static Color onPrimary(BuildContext context) => of(context).onPrimary;

  static Color secondary(BuildContext context) => of(context).secondary;

  static Color navInactive(BuildContext context) {
    return AppColors.navInactive.withValues(alpha: 0.72);
  }

  @override
  bool updateShouldNotify(ThemePaletteScope oldWidget) {
    return palette != oldWidget.palette;
  }
}
