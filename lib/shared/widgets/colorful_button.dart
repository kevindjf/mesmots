import 'package:flutter/material.dart';
import 'package:mesmots/core/extensions/palette_context.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_typography.dart';

/// A colorful button with shadow effect like Mr. Square
class ColorfulButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color color;
  final Color shadowColor;
  final Color? textColor;
  final double? width;

  const ColorfulButton({
    super.key,
    required this.text,
    this.icon,
    this.onTap,
    this.color = AppColors.buttonOrange,
    this.shadowColor = AppColors.buttonOrangeShadow,
    this.textColor,
    this.width,
  });

  // Named constructors for common colors
  const ColorfulButton.orange({
    super.key,
    required this.text,
    this.icon,
    this.onTap,
    this.textColor,
    this.width,
  })  : color = AppColors.buttonOrange,
        shadowColor = AppColors.buttonOrangeShadow;

  const ColorfulButton.coral({
    super.key,
    required this.text,
    this.icon,
    this.onTap,
    this.textColor,
    this.width,
  })  : color = AppColors.buttonCoral,
        shadowColor = AppColors.buttonCoralShadow;

  const ColorfulButton.pink({
    super.key,
    required this.text,
    this.icon,
    this.onTap,
    this.textColor,
    this.width,
  })  : color = AppColors.buttonPink,
        shadowColor = AppColors.buttonPinkShadow;

  const ColorfulButton.magenta({
    super.key,
    required this.text,
    this.icon,
    this.onTap,
    this.textColor,
    this.width,
  })  : color = AppColors.buttonMagenta,
        shadowColor = AppColors.buttonMagentaShadow;

  const ColorfulButton.blue({
    super.key,
    required this.text,
    this.icon,
    this.onTap,
    this.textColor,
    this.width,
  })  : color = AppColors.buttonBlue,
        shadowColor = AppColors.buttonBlueShadow;

  @override
  State<ColorfulButton> createState() => _ColorfulButtonState();
}

class _ColorfulButtonState extends State<ColorfulButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final textColor = widget.textColor ?? context.palette.onBlock(widget.color);
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.width,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingXl,
          vertical: AppDimensions.paddingM,
        ),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          boxShadow: [
            // Bottom shadow for 3D effect
            BoxShadow(
              color: widget.shadowColor,
              offset: Offset(0, _isPressed ? 2 : 6),
              blurRadius: 0,
            ),
          ],
        ),
        transform: Matrix4.translationValues(0, _isPressed ? 4 : 0, 0),
        child: Row(
          mainAxisSize:
              widget.width != null ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                color: textColor,
                size: 28,
              ),
              const SizedBox(width: AppDimensions.spacingL),
            ],
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  widget.text.toUpperCase(),
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: AppTypography.headingSmall,
                    fontWeight: AppTypography.bold,
                    color: textColor,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small icon button with colorful style
class ColorfulIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;
  final Color shadowColor;
  final double size;

  const ColorfulIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.color = AppColors.buttonBlue,
    this.shadowColor = AppColors.buttonBlueShadow,
    this.size = 56,
  });

  @override
  State<ColorfulIconButton> createState() => _ColorfulIconButtonState();
}

class _ColorfulIconButtonState extends State<ColorfulIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          boxShadow: [
            BoxShadow(
              color: widget.shadowColor,
              offset: Offset(0, _isPressed ? 2 : 4),
              blurRadius: 0,
            ),
          ],
        ),
        transform: Matrix4.translationValues(0, _isPressed ? 2 : 0, 0),
        child: Icon(
          widget.icon,
          color: AppColors.textOnColor,
          size: widget.size * 0.5,
        ),
      ),
    );
  }
}
