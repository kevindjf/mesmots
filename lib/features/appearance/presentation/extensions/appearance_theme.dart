import 'package:flutter/material.dart';
import 'package:mesmots/core/theme/app_palette.dart';
import 'package:mesmots/core/theme/app_theme.dart';
import 'package:mesmots/features/appearance/domain/entities/appearance_settings.dart';

/// What [MaterialApp] needs to show the chosen appearance.
extension AppearanceTheme on AppearanceSettings {
  /// Theme for the light side ([ThemeChoice.system]) or the only theme.
  ThemeData get themeData => AppTheme.of(_palette(switch (this.theme) {
        ThemeChoice.turquoise => AppPalette.turquoise,
        ThemeChoice.dark => AppPalette.dark,
        ThemeChoice.light || ThemeChoice.system => AppPalette.light,
      }));

  /// Theme used when the device is in dark mode.
  ThemeData get darkThemeData => AppTheme.of(_palette(AppPalette.dark));

  /// Only [ThemeChoice.system] follows the device setting.
  ThemeMode get themeMode => switch (this.theme) {
        ThemeChoice.system => ThemeMode.system,
        ThemeChoice.dark => ThemeMode.dark,
        ThemeChoice.turquoise || ThemeChoice.light => ThemeMode.light,
      };

  AppPalette _palette(AppPalette base) =>
      base.copyWith(highContrast: highContrast);
}
