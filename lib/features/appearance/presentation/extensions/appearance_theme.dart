import 'package:flutter/material.dart';
import 'package:mesmots/core/theme/app_palette.dart';
import 'package:mesmots/core/theme/app_theme.dart';
import 'package:mesmots/features/appearance/domain/entities/appearance_settings.dart';

/// Theme to give [MaterialApp] for the chosen appearance.
///
/// The device light/dark setting is ignored: only the parent's choice counts.
extension AppearanceTheme on AppearanceSettings {
  AppPalette get palette => switch (theme) {
        ThemeChoice.light => AppPalette.light,
        ThemeChoice.dark => AppPalette.dark,
      }
          .copyWith(highContrast: highContrast);

  ThemeData get themeData => AppTheme.of(palette);
}
