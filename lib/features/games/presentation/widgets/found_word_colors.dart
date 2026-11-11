import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_colors.dart';

/// Highlight colors for words found in letter grids.
extension FoundWordColors on int {
  static const List<Color> _palette = [
    AppColors.buttonOrange,
    AppColors.buttonBlue,
    AppColors.buttonPink,
    AppColors.buttonMagenta,
    AppColors.buttonCoral,
    AppColors.success,
  ];

  /// Color of the found word at this index
  Color get foundWordColor => _palette[this % _palette.length];
}
