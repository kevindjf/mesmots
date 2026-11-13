import 'package:flutter/material.dart';
import 'package:mesmots/core/extensions/palette_context.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/constants/app_typography.dart';

class GameHeader extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final int validatedCount;
  final int totalCount;
  final Color? progressColor;
  final Widget? timer; // optional timer widget displayed next to percentage

  const GameHeader({
    super.key,
    required this.progress,
    required this.validatedCount,
    required this.totalCount,
    this.progressColor,
    this.timer,
  });

  @override
  Widget build(BuildContext context) {
    final barColor = progressColor ?? AppColors.primary;
    final palette = context.palette;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.paddingS,
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: palette.panel,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: palette.panelOutline,
        boxShadow: [
          BoxShadow(
            color: palette.panelShadow,
            blurRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$validatedCount/$totalCount ${AppStrings.validated}',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: AppTypography.bodyMedium,
                  fontWeight: AppTypography.semiBold,
                  color: palette.panelText,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (timer != null) ...[
                    timer!,
                    const SizedBox(width: AppDimensions.spacingS),
                  ],
                  Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: AppTypography.bodyMedium,
                      fontWeight: AppTypography.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: barColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: constraints.maxWidth * progress.clamp(0.0, 1.0),
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
