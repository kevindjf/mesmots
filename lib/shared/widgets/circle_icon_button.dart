import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';

/// Circular icon button with 3D shadow effect (style Mr. Square)
class CircleIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;
  final Color shadowColor;
  final Color iconColor;
  final double size;

  const CircleIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.color = AppColors.surface,
    this.shadowColor = AppColors.primaryDark,
    this.iconColor = AppColors.primary,
    this.size = 44,
  });

  /// White button with primary icon (e.g. back button)
  const CircleIconButton.surface({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 44,
  })  : color = AppColors.surface,
        shadowColor = AppColors.primaryDark,
        iconColor = AppColors.primary;

  /// Colored button with white icon
  const CircleIconButton.colored({
    super.key,
    required this.icon,
    this.onTap,
    required this.color,
    required this.shadowColor,
    this.size = 44,
  }) : iconColor = AppColors.textOnColor;

  @override
  State<CircleIconButton> createState() => _CircleIconButtonState();
}

class _CircleIconButtonState extends State<CircleIconButton> {
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
        transform: Matrix4.translationValues(0, _isPressed ? 2 : 0, 0),
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.shadowColor,
              blurRadius: 0,
              offset: Offset(0, _isPressed ? 2 : 4),
            ),
          ],
        ),
        child: Icon(
          widget.icon,
          color: widget.iconColor,
          size: AppDimensions.iconM,
        ),
      ),
    );
  }
}
