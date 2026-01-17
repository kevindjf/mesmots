import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';

/// Progress bar widget
class AppProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Color? color;
  final Color? backgroundColor;
  final double? height;

  const AppProgressBar({
    super.key,
    required this.progress,
    this.color,
    this.backgroundColor,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? AppDimensions.progressBarHeight,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.textLight.withOpacity(0.3),
        borderRadius:
            BorderRadius.circular(AppDimensions.progressBarRadius),
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(AppDimensions.progressBarRadius),
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppColors.primary,
          ),
        ),
      ),
    );
  }
}

/// Progress bar with percentage label
class AppProgressBarWithLabel extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final String? label;
  final Color? color;

  const AppProgressBarWithLabel({
    super.key,
    required this.progress,
    this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (label != null)
              Text(
                label!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            Text(
              '$percentage%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingS),
        AppProgressBar(
          progress: progress,
          color: color,
        ),
      ],
    );
  }
}
