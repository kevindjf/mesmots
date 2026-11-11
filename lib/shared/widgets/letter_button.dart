import 'package:flutter/material.dart';
import 'package:jerevise/core/constants/app_colors.dart';
import 'package:jerevise/core/constants/app_dimensions.dart';
import 'package:jerevise/core/constants/app_typography.dart';

/// 3D letter button used in scramble and keyboard games
class LetterButton extends StatefulWidget {
  final String letter;
  final VoidCallback? onTap;
  final bool isDisabled;
  final double size;
  final double fontSize;

  const LetterButton({
    super.key,
    required this.letter,
    this.onTap,
    this.isDisabled = false,
    this.size = 52,
    this.fontSize = AppTypography.headingMedium,
  });

  /// Smaller variant for keyboard layout
  const LetterButton.keyboard({
    super.key,
    required this.letter,
    this.onTap,
    this.isDisabled = false,
    double? size,
  })  : size = size ?? 34,
        fontSize = AppTypography.bodyMedium;

  @override
  State<LetterButton> createState() => _LetterButtonState();
}

class _LetterButtonState extends State<LetterButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isActive = !widget.isDisabled && widget.onTap != null;

    return GestureDetector(
      onTapDown: isActive ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isActive
          ? (_) {
              setState(() => _isPressed = false);
              widget.onTap!();
            }
          : null,
      onTapCancel: isActive ? () => setState(() => _isPressed = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.size,
        height: widget.size,
        transform: Matrix4.translationValues(0, _isPressed ? 2 : 0, 0),
        decoration: BoxDecoration(
          color: widget.isDisabled
              ? AppColors.textLight.withValues(alpha: 0.3)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          boxShadow: widget.isDisabled
              ? []
              : [
                  BoxShadow(
                    color: AppColors.primaryDark,
                    blurRadius: 0,
                    offset: Offset(0, _isPressed ? 1 : 3),
                  ),
                ],
        ),
        child: Center(
          child: Text(
            widget.letter.toUpperCase(),
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: widget.fontSize,
              fontWeight: AppTypography.bold,
              color: widget.isDisabled
                  ? AppColors.textLight
                  : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
