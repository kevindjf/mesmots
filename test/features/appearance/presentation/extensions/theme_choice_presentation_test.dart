import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/core/theme/app_palette.dart';
import 'package:mesmots/features/appearance/domain/entities/appearance_settings.dart';
import 'package:mesmots/features/appearance/presentation/extensions/theme_choice_presentation.dart';

void main() {
  test('every theme has its own label', () {
    // Act
    final labels = ThemeChoice.values.map((choice) => choice.label).toSet();

    // Assert
    expect(labels.length, ThemeChoice.values.length);
  });

  test('auto previews both light and dark', () {
    // Act & Assert
    expect(
      ThemeChoice.system.previewPalettes,
      [AppPalette.light, AppPalette.dark],
    );
    expect(ThemeChoice.turquoise.previewPalettes, [AppPalette.turquoise]);
  });
}
