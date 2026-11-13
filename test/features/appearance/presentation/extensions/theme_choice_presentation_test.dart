import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/theme/app_palette.dart';
import 'package:mesmots/features/appearance/domain/entities/appearance_settings.dart';
import 'package:mesmots/features/appearance/presentation/extensions/theme_choice_presentation.dart';

void main() {
  test('each theme has its label and preview palette', () {
    // Act & Assert
    expect(ThemeChoice.light.label, AppStrings.themeLight);
    expect(ThemeChoice.dark.label, AppStrings.themeDark);
    expect(ThemeChoice.light.previewPalette, AppPalette.light);
    expect(ThemeChoice.dark.previewPalette, AppPalette.dark);
  });
}
