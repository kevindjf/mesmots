import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/theme/app_palette.dart';
import 'package:mesmots/features/appearance/domain/entities/appearance_settings.dart';

/// UI attributes of each [ThemeChoice].
extension ThemeChoicePresentation on ThemeChoice {
  String get label => switch (this) {
        ThemeChoice.turquoise => AppStrings.themeTurquoise,
        ThemeChoice.light => AppStrings.themeLight,
        ThemeChoice.dark => AppStrings.themeDark,
        ThemeChoice.system => AppStrings.themeSystem,
      };

  /// Palettes shown in the preview: two for [ThemeChoice.system].
  List<AppPalette> get previewPalettes => switch (this) {
        ThemeChoice.turquoise => [AppPalette.turquoise],
        ThemeChoice.light => [AppPalette.light],
        ThemeChoice.dark => [AppPalette.dark],
        ThemeChoice.system => [AppPalette.light, AppPalette.dark],
      };
}
