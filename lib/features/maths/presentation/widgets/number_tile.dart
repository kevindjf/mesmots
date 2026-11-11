import 'package:flutter/material.dart';
import 'package:jerevise/core/constants/app_colors.dart';
import 'package:jerevise/core/constants/app_dimensions.dart';
import 'package:jerevise/core/constants/app_typography.dart';

class NumberTile extends StatefulWidget {
  final int value;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;
  final Color? shadowColor;

  const NumberTile({
    super.key,
    required this.value,
    required this.isSelected,
    required this.onTap,
    this.color,
    this.shadowColor,
  });

  @override
  State<NumberTile> createState() => _NumberTileState();
}

class _NumberTileState extends State<NumberTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.color ??
        (widget.isSelected ? AppColors.sectionMaths : AppColors.surface);
    final shadow = widget.shadowColor ??
        (widget.isSelected ? AppColors.sectionMathsShadow : AppColors.primaryDark);
    final textColor =
        widget.isSelected ? AppColors.textOnColor : AppColors.textPrimary;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 64,
        height: 64,
        transform: Matrix4.translationValues(0, _isPressed ? 3 : 0, 0),
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          boxShadow: [
            BoxShadow(
              color: shadow,
              blurRadius: 0,
              offset: Offset(0, _isPressed ? 1 : 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '${widget.value}',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: AppTypography.headingMedium,
              fontWeight: AppTypography.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
