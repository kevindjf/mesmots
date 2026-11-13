import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/theme/app_palette.dart';
import 'package:mesmots/features/appearance/domain/entities/appearance_settings.dart';

/// UI attributes of each [ThemeChoice].
extension ThemeChoicePresentation on ThemeChoice {
  String get label => switch (this) {
        ThemeChoice.light => AppStrings.themeLight,
        ThemeChoice.dark => AppStrings.themeDark,
      };

  /// Palette drawn in the theme preview.
  AppPalette get previewPalette => switch (this) {
        ThemeChoice.light => AppPalette.light,
        ThemeChoice.dark => AppPalette.dark,
      };
}
