import 'package:flutter/material.dart';
import 'package:jerevise/core/constants/app_colors.dart';
import 'package:jerevise/shared/widgets/circle_icon_button.dart';

/// Reusable 3D back button (Mr. Square style).
///
/// Wraps [CircleIconButton] with an arrow_back icon.
/// Supports custom colors and sizes for different contexts
/// (e.g. smaller variant for landscape headers).
class BackButton3D extends StatelessWidget {
  final VoidCallback onTap;
  final Color color;
  final Color shadowColor;
  final Color iconColor;
  final double size;

  /// Default white back button with turquoise icon (used on turquoise backgrounds).
  const BackButton3D({
    super.key,
    required this.onTap,
    this.color = AppColors.surface,
    this.shadowColor = AppColors.primaryDark,
    this.iconColor = AppColors.primary,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return CircleIconButton(
      icon: Icons.arrow_back,
      onTap: onTap,
      color: color,
      shadowColor: shadowColor,
      iconColor: iconColor,
      size: size,
    );
  }
}
