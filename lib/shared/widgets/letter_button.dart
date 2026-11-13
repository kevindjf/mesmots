import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/core/extensions/palette_context.dart';

/// 3D letter button used in scramble and keyboard games
class LetterButton extends StatefulWidget {
  final String letter;
  final VoidCallback? onTap;
  final bool isDisabled;
  final double size;
  final double fontSize;

  /// Show the letter in capitals (keyboard keys) or as written (spelling).
  final bool uppercase;

  const LetterButton({
    super.key,
    required this.letter,
    this.onTap,
    this.isDisabled = false,
    this.size = 52,
    this.fontSize = AppTypography.headingMedium,
    this.uppercase = true,
  });

  /// Smaller variant for keyboard layout
  const LetterButton.keyboard({
    super.key,
    required this.letter,
    this.onTap,
    this.isDisabled = false,
    double? size,
  })  : size = size ?? 34,
        fontSize = AppTypography.bodyMedium,
        uppercase = true;

  @override
  State<LetterButton> createState() => _LetterButtonState();
}

class _LetterButtonState extends State<LetterButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isActive = !widget.isDisabled && widget.onTap != null;
    final palette = context.palette;

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
          color: widget.isDisabled ? palette.tileDisabled : palette.tile,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          boxShadow: widget.isDisabled
              ? []
              : [
                  BoxShadow(
                    color: palette.tileShadow,
                    blurRadius: 0,
                    offset: Offset(0, _isPressed ? 1 : 3),
                  ),
                ],
        ),
        child: Center(
          child: Text(
            widget.uppercase ? widget.letter.toUpperCase() : widget.letter,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: widget.fontSize,
              fontWeight: AppTypography.bold,
              color: widget.isDisabled
                  ? palette.tileDisabledContent
                  : palette.tileAccent,
            ),
          ),
        ),
      ),
    );
  }
}
