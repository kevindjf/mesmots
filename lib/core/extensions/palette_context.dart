import 'package:flutter/material.dart';
import 'package:mesmots/core/theme/app_palette.dart';

/// Access to the [AppPalette] of the current theme.
extension PaletteContext on BuildContext {
  /// The theme palette, the original turquoise one when none is set.
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.turquoise;
}
