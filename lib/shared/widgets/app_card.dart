import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/theme/app_palette.dart';
import 'package:mesmots/core/extensions/palette_context.dart';

/// Standard application card with 3D shadow
class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final card = Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? palette.panel,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: backgroundColor == null ? palette.panelOutline : null,
        boxShadow: [
          BoxShadow(
            color: palette.panelShadow,
            blurRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppDimensions.paddingL),
        child: child,
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}

/// Game card with 3D shadow and state feedback
class GameCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isCorrect;
  final bool isIncorrect;
  final EdgeInsetsGeometry? padding;

  const GameCard({
    super.key,
    required this.child,
    this.onTap,
    this.isSelected = false,
    this.isCorrect = false,
    this.isIncorrect = false,
    this.padding,
  });

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  bool _isPressed = false;

  Color _backgroundColor(AppPalette palette) {
    if (widget.isCorrect) return AppColors.success;
    if (widget.isIncorrect) return AppColors.error;
    if (widget.isSelected) return AppColors.buttonBlue.withValues(alpha: 0.2);
    return palette.panel;
  }

  Color _shadowColor(AppPalette palette) {
    if (widget.isCorrect) return const Color(0xFF3D8B40);
    if (widget.isIncorrect) return const Color(0xFFCC3B3B);
    return palette.panelShadow;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GestureDetector(
      onTapDown: widget.onTap != null
          ? (_) => setState(() => _isPressed = true)
          : null,
      onTapUp: widget.onTap != null
          ? (_) {
              setState(() => _isPressed = false);
              widget.onTap!();
            }
          : null,
      onTapCancel: widget.onTap != null
          ? () => setState(() => _isPressed = false)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(0, _isPressed ? 2 : 0, 0),
        decoration: BoxDecoration(
          color: _backgroundColor(palette),
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          border: palette.outlineOf(
            widget.isCorrect || widget.isIncorrect || widget.isSelected
                ? _backgroundColor(palette)
                : null,
          ),
          boxShadow: [
            BoxShadow(
              color: _shadowColor(palette),
              blurRadius: 0,
              offset: Offset(0, _isPressed ? 2 : 4),
            ),
          ],
        ),
        child: Padding(
          padding: widget.padding ??
              const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingL,
                vertical: AppDimensions.paddingM,
              ),
          child: widget.child,
        ),
      ),
    );
  }
}
