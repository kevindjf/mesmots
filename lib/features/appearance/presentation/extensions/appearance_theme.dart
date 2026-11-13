import 'package:flutter/material.dart';
import 'package:mesmots/core/theme/app_palette.dart';
import 'package:mesmots/core/theme/app_theme.dart';
import 'package:mesmots/features/appearance/domain/entities/appearance_settings.dart';

/// Theme to give [MaterialApp] for the chosen appearance.
extension AppearanceTheme on AppearanceSettings {
  AppPalette get palette => AppPalette.light.copyWith(highContrast: highContrast);

  ThemeData get themeData => AppTheme.of(palette);
}
