import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_typography.dart';

/// A colored square tile showing one letter, with a 3D shadow.
class LetterTile extends StatelessWidget {
  final String letter;
  final double size;
  final Color color;
  final Color shadowColor;

  /// Rotation in radians, for a playful look.
  final double angle;

  const LetterTile({
    super.key,
    required this.letter,
    required this.color,
    required this.shadowColor,
    this.size = 44,
    this.angle = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          boxShadow: [
            BoxShadow(
                color: shadowColor, blurRadius: 0, offset: const Offset(0, 4)),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          letter,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: size * 0.6,
            fontWeight: AppTypography.bold,
            color: AppColors.textOnColor,
          ),
        ),
      ),
    );
  }
}
