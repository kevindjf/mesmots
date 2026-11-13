import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/core/extensions/palette_context.dart';

/// One key of [ChildKeyboard]: a theme tile with a 3D shadow, pressed effect.
/// Shows [label] or [icon].
class KeyboardKey extends StatefulWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback? onTap;
  final double width;
  final double height;

  /// Colors default to the theme tile.
  final Color? color;
  final Color? shadowColor;
  final Color? contentColor;

  const KeyboardKey({
    super.key,
    this.label,
    this.icon,
    required this.onTap,
    required this.width,
    this.height = 44,
    this.color,
    this.shadowColor,
    this.contentColor,
  });

  @override
  State<KeyboardKey> createState() => _KeyboardKeyState();
}

class _KeyboardKeyState extends State<KeyboardKey> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (widget.onTap != null) setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final palette = context.palette;
    final contentColor = widget.contentColor ?? palette.tileText;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) {
        _setPressed(false);
        widget.onTap?.call();
      },
      onTapCancel: () => _setPressed(false),
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          width: widget.width,
          height: widget.height,
          transform: Matrix4.translationValues(0, _isPressed ? 2 : 0, 0),
          decoration: BoxDecoration(
            color: widget.color ?? palette.tile,
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            boxShadow: [
              BoxShadow(
                color: widget.shadowColor ?? palette.tileShadow,
                blurRadius: 0,
                offset: Offset(0, _isPressed ? 1 : 3),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: widget.icon != null
              ? Icon(widget.icon, color: contentColor, size: 22)
              : Text(
                  widget.label ?? '',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 20,
                    fontWeight: AppTypography.bold,
                    color: contentColor,
                  ),
                ),
        ),
      ),
    );
  }
}
