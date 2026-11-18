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

  /// Thinner, for a screen held sideways where height is short.
  final bool compact;

  const GameHeader({
    super.key,
    required this.progress,
    required this.validatedCount,
    required this.totalCount,
    this.progressColor,
    this.timer,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final barColor = progressColor ?? AppColors.success;
    final palette = context.palette;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: compact ? 0 : AppDimensions.paddingS,
      ),
      padding: compact
          ? const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingM,
              vertical: AppDimensions.paddingS,
            )
          : const EdgeInsets.all(AppDimensions.paddingM),
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
              // Shrinks first when the header is narrow (a phone held
              // sideways), so the percentage always shows.
              Flexible(
                child: Text(
                  '$validatedCount/$totalCount ${AppStrings.validated}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: AppTypography.bodyMedium,
                    fontWeight: AppTypography.semiBold,
                    color: palette.panelText,
                  ),
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
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: AppTypography.bodyMedium,
                      fontWeight: AppTypography.bold,
                      color: palette.panelText,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: compact ? AppDimensions.spacingXs : AppDimensions.spacingS,
          ),
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
