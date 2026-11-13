import 'package:flutter/material.dart';
import 'package:mesmots/shared/widgets/circle_icon_button.dart';

/// Reusable 3D back button (Mr. Square style).
///
/// Wraps [CircleIconButton] with an arrow_back icon.
/// Supports custom colors and sizes for different contexts
/// (e.g. smaller variant for landscape headers).
class BackButton3D extends StatelessWidget {
  final VoidCallback onTap;
  final Color? color;
  final Color? shadowColor;
  final Color? iconColor;
  final double size;

  /// Theme tile back button with primary icon, unless colors are given.
  const BackButton3D({
    super.key,
    required this.onTap,
    this.color,
    this.shadowColor,
    this.iconColor,
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
