import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/theme/app_palette.dart';

void main() {
  group('contrastRatio', () {
    test('black on white is the maximum, 21', () {
      // Act
      final ratio = AppPalette.contrastRatio(
        const Color(0xFF000000),
        const Color(0xFFFFFFFF),
      );

      // Assert
      expect(ratio, closeTo(21, 0.01));
    });

    test('white on orange is far below the 4.5 threshold', () {
      // Act
      final ratio =
          AppPalette.contrastRatio(AppColors.buttonOrange, AppColors.surface);

      // Assert
      expect(ratio, closeTo(1.94, 0.01));
    });
  });

  group('onBlock', () {
    test('stays white when high contrast is off', () {
      // Arrange
      final palette = AppPalette.light;

      // Act & Assert
      expect(palette.onBlock(AppColors.buttonOrange), AppColors.textOnColor);
    });

    test('turns dark on a bright block when high contrast is on', () {
      // Arrange
      final palette = AppPalette.light.copyWith(highContrast: true);

      // Act & Assert
      expect(palette.onBlock(AppColors.buttonOrange), AppColors.textPrimary);
      expect(palette.onBlock(AppColors.buttonMagenta), AppColors.textPrimary);
    });

    test('keeps white on a block where it already reads well', () {
      // Arrange
      final palette = AppPalette.dark.copyWith(highContrast: true);

      // Act & Assert
      expect(palette.onBlock(AppColors.buttonPurple), AppColors.textOnColor);
    });
  });

  test('shapeColor cycles through the tints', () {
    // Arrange
    final tints = AppPalette.light.shapeTints;

    // Act & Assert
    expect(AppPalette.light.shapeColor(0), tints[0]);
    expect(AppPalette.light.shapeColor(tints.length + 1), tints[1]);
  });

  test('copyWith only changes the high contrast flag', () {
    // Act
    final copy = AppPalette.dark.copyWith(highContrast: true);

    // Assert
    expect(copy.highContrast, isTrue);
    expect(copy.panel, AppPalette.dark.panel);
    expect(copy.brightness, AppPalette.dark.brightness);
  });

  test('lerp switches palettes at half way', () {
    // Act & Assert
    expect(AppPalette.light.lerp(AppPalette.dark, 0.4), AppPalette.light);
    expect(AppPalette.light.lerp(AppPalette.dark, 0.6), AppPalette.dark);
  });
}
