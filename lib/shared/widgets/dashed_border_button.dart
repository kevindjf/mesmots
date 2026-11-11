import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_typography.dart';

/// A button with a dashed border
class DashedBorderButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool isLocked;
  final Color? borderColor;
  final Color? textColor;

  const DashedBorderButton({
    super.key,
    required this.text,
    this.onTap,
    this.icon,
    this.trailingIcon,
    this.isLocked = false,
    this.borderColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? AppColors.dashedBorder;
    final effectiveTextColor = textColor ?? Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: DashedBorderPainter(
          color: effectiveBorderColor,
          strokeWidth: 4,
          dashWidth: 8,
          dashSpace: 8,
          borderRadius: AppDimensions.radiusL,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.paddingL,
            horizontal: AppDimensions.paddingM,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: effectiveTextColor,
                  size: AppDimensions.iconS,
                ),
                const SizedBox(width: AppDimensions.spacingXs),
              ],
              Text(
                text,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: AppTypography.bodyLarge,
                  fontWeight: AppTypography.bold,
                  color: effectiveTextColor,
                ),
              ),
              if (trailingIcon != null || isLocked) ...[
                const SizedBox(width: AppDimensions.spacingS),
                Icon(
                  trailingIcon ?? Icons.lock_outline,
                  color: effectiveTextColor,
                  size: AppDimensions.iconS,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for dashed border
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double borderRadius;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 2,
    this.dashWidth = 8,
    this.dashSpace = 5,
    this.borderRadius = 16,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    path.addRRect(rrect);

    final dashPath = _createDashedPath(path);
    canvas.drawPath(dashPath, paint);
  }

  Path _createDashedPath(Path source) {
    final dashPath = Path();
    final metrics = source.computeMetrics();

    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final dashEnd = distance + dashWidth;
        dashPath.addPath(
          metric.extractPath(distance, dashEnd.clamp(0, metric.length)),
          Offset.zero,
        );
        distance = dashEnd + dashSpace;
      }
    }

    return dashPath;
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) {
    return color != oldDelegate.color ||
        strokeWidth != oldDelegate.strokeWidth ||
        dashWidth != oldDelegate.dashWidth ||
        dashSpace != oldDelegate.dashSpace ||
        borderRadius != oldDelegate.borderRadius;
  }
}
