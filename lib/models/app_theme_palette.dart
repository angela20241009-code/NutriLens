import 'package:flutter/material.dart';

enum AppThemePalette {
  classic('classic'),
  ocean('ocean'),
  sunset('sunset'),
  forest('forest');

  const AppThemePalette(this.firestoreValue);

  final String firestoreValue;

  static AppThemePalette fromFirestore(String? value) {
    return AppThemePalette.values.firstWhere(
      (palette) => palette.firestoreValue == value,
      orElse: () => AppThemePalette.classic,
    );
  }

  String get label => switch (this) {
    AppThemePalette.classic => 'Classic lime',
    AppThemePalette.ocean => 'Ocean blue',
    AppThemePalette.sunset => 'Sunset coral',
    AppThemePalette.forest => 'Forest green',
  };

  Color get primary => switch (this) {
    AppThemePalette.classic => const Color(0xFFB8FF3C),
    AppThemePalette.ocean => const Color(0xFF4FC3F7),
    AppThemePalette.sunset => const Color(0xFFFF8A65),
    AppThemePalette.forest => const Color(0xFF81C784),
  };

  Color get onPrimary => const Color(0xFF000000);

  Color get secondary => switch (this) {
    AppThemePalette.classic => const Color(0xFFBF5AF2),
    AppThemePalette.ocean => const Color(0xFF7C4DFF),
    AppThemePalette.sunset => const Color(0xFFFFB74D),
    AppThemePalette.forest => const Color(0xFFA5D6A7),
  };

  Color get sleepAccent => secondary;
}
