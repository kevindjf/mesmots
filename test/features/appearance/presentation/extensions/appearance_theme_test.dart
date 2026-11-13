import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/core/theme/app_palette.dart';
import 'package:mesmots/features/appearance/domain/entities/appearance_settings.dart';
import 'package:mesmots/features/appearance/presentation/extensions/appearance_theme.dart';

AppPalette _paletteOf(ThemeData theme) => theme.extension<AppPalette>()!;

void main() {
  test('turquoise keeps the original palette, in light mode only', () {
    // Arrange
    const settings = AppearanceSettings(theme: ThemeChoice.turquoise);

    // Act & Assert
    expect(
      _paletteOf(settings.themeData).panel,
      AppPalette.turquoise.panel,
    );
    expect(
      _paletteOf(settings.themeData).backgroundGradient,
      AppPalette.turquoise.backgroundGradient,
    );
    expect(settings.themeMode, ThemeMode.light);
  });

  test('system follows the device between light and dark', () {
    // Arrange
    const settings = AppearanceSettings(theme: ThemeChoice.system);

    // Act & Assert
    expect(settings.themeMode, ThemeMode.system);
    expect(_paletteOf(settings.themeData).tile, AppPalette.light.tile);
    expect(_paletteOf(settings.darkThemeData).tile, AppPalette.dark.tile);
  });

  test('dark forces the dark theme', () {
    // Arrange
    const settings = AppearanceSettings(theme: ThemeChoice.dark);

    // Act & Assert
    expect(settings.themeMode, ThemeMode.dark);
    expect(settings.darkThemeData.brightness, Brightness.dark);
  });

  test('high contrast reaches the palette', () {
    // Arrange
    const settings = AppearanceSettings(highContrast: true);

    // Act & Assert
    expect(_paletteOf(settings.themeData).highContrast, isTrue);
  });
}
