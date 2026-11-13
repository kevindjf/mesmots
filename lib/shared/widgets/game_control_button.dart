import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/core/extensions/palette_context.dart';

/// Control button for game screens (Effacer, Aide, Valider)
/// Style Mr. Square with 3D shadow effect
class GameControlButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isEnabled;
  final bool isPrimary;

  const GameControlButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isEnabled = true,
    this.isPrimary = false,
  });

  @override
  State<GameControlButton> createState() => _GameControlButtonState();
}

class _GameControlButtonState extends State<GameControlButton> {
  bool _isPressed = false;

  @override
  void didUpdateWidget(covariant GameControlButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEnabled != oldWidget.isEnabled) {
      _isPressed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final Color bgColor;
    final Color shadowColor;
    final Color iconColor;

    if (widget.isPrimary) {
      bgColor = AppColors.success;
      shadowColor = const Color(0xFF3D8B40);
      iconColor = AppColors.textOnColor;
    } else {
      bgColor = palette.tile;
      shadowColor = palette.tileShadow;
      iconColor = palette.tileAccent;
    }

    return Opacity(
      opacity: widget.isEnabled ? 1.0 : 0.4,
      child: GestureDetector(
        onTapDown:
            widget.isEnabled ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: widget.isEnabled
            ? (_) {
                setState(() => _isPressed = false);
                widget.onTap();
              }
            : null,
        onTapCancel:
            widget.isEnabled ? () => setState(() => _isPressed = false) : null,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: 56,
              height: 56,
              transform: Matrix4.translationValues(0, _isPressed ? 2 : 0, 0),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 0,
                    offset: Offset(0, _isPressed ? 2 : 4),
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                color: iconColor,
                size: 28,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            Text(
              widget.label,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: AppTypography.bodySmall,
                fontWeight: AppTypography.semiBold,
                // Labels sit on the background.
                color: palette.onBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
