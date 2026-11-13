import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/core/theme/app_palette.dart';
import 'package:mesmots/features/appearance/domain/entities/appearance_settings.dart';
import 'package:mesmots/features/appearance/presentation/extensions/appearance_theme.dart';

void main() {
  test('the app uses the light palette', () {
    // Act
    final theme = AppearanceSettings.initial.themeData;

    // Assert
    expect(theme.brightness, Brightness.light);
    expect(theme.extension<AppPalette>()!.tile, AppPalette.light.tile);
  });

  test('high contrast reaches the palette', () {
    // Arrange
    const settings = AppearanceSettings(highContrast: true);

    // Act & Assert
    expect(settings.palette.highContrast, isTrue);
    expect(settings.themeData.extension<AppPalette>()!.highContrast, isTrue);
  });
}
