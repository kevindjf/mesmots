import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_colors.dart';

/// Small square icon button for colored rows and cards: a translucent white
/// background and a white icon, pressed down when tapped.
class TintedIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final double size;

  const TintedIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.size = 40,
  });

  @override
  State<TintedIconButton> createState() => _TintedIconButtonState();
}

class _TintedIconButtonState extends State<TintedIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: Semantics(
        button: true,
        label: widget.tooltip,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            widget.onTap();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: widget.size,
            height: widget.size,
            transform: Matrix4.translationValues(0, _isPressed ? 2 : 0, 0),
            decoration: BoxDecoration(
              color: AppColors.textOnColor
                  .withValues(alpha: _isPressed ? 0.4 : 0.25),
              borderRadius: BorderRadius.circular(widget.size / 4),
            ),
            child: Icon(
              widget.icon,
              color: AppColors.textOnColor,
              size: widget.size * 0.6,
            ),
          ),
        ),
      ),
    );
  }
}
