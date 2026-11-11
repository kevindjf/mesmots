import 'package:flutter/material.dart';
import 'package:jerevise/core/constants/app_colors.dart';
import 'package:jerevise/core/constants/app_dimensions.dart';
import 'package:jerevise/core/constants/app_typography.dart';

/// Section card with Mr. Square style (3D shadow, press animation)
class SectionCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Color shadowColor;
  final VoidCallback? onTap;
  final bool isLocked;

  const SectionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.shadowColor,
    this.onTap,
    this.isLocked = false,
  });

  @override
  State<SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<SectionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.isLocked || widget.onTap == null;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled
          ? null
          : (_) {
              setState(() => _isPressed = false);
              widget.onTap?.call();
            },
      onTapCancel: isDisabled
          ? null
          : () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(0, _isPressed ? 4 : 0, 0),
        padding: const EdgeInsets.all(AppDimensions.paddingXl),
        decoration: BoxDecoration(
          color: isDisabled
              ? widget.color.withValues(alpha: 0.5)
              : widget.color,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          boxShadow: [
            BoxShadow(
              color: isDisabled
                  ? widget.shadowColor.withValues(alpha: 0.3)
                  : widget.shadowColor,
              blurRadius: 0,
              offset: Offset(0, _isPressed ? 2 : 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              ),
              child: Center(
                child: Icon(
                  widget.icon,
                  size: 36,
                  color: AppColors.textOnColor,
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingL),

            // Title and description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: AppTypography.headingSmall,
                      fontWeight: AppTypography.bold,
                      color: AppColors.textOnColor,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXs),
                  Text(
                    widget.description,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: AppTypography.bodyMedium,
                      fontWeight: AppTypography.regular,
                      color: AppColors.textOnColor.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),

            // Lock icon or arrow
            if (widget.isLocked)
              Icon(
                Icons.lock_outline,
                color: AppColors.textOnColor.withValues(alpha: 0.6),
                size: AppDimensions.iconL,
              )
            else
              const Icon(
                Icons.chevron_right,
                color: AppColors.textOnColor,
                size: AppDimensions.iconL,
              ),
          ],
        ),
      ),
    );
  }
}
