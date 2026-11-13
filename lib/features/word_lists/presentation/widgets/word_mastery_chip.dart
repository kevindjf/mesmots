import 'package:flutter/material.dart';
import 'package:mesmots/core/extensions/palette_context.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_status.dart';

/// Word chip showing its mastery stars.
class WordMasteryChip extends StatelessWidget {
  final String word;
  final WordStatus status;
  final VoidCallback? onTap;

  const WordMasteryChip({
    super.key,
    required this.word,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMastered = status.isMastered;

    return GestureDetector(
      onTap: onTap,
      child: _buildChip(context, isMastered),
    );
  }

  Widget _buildChip(BuildContext context, bool isMastered) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: AppDimensions.minTouchTarget,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      decoration: BoxDecoration(
        color: isMastered ? AppColors.success : context.palette.panel,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: isMastered
                ? AppColors.successShadow
                : context.palette.panelShadow,
            blurRadius: 0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            word,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: AppTypography.bodyMedium,
              fontWeight: AppTypography.semiBold,
              color: isMastered
                  ? context.palette.onBlock(AppColors.success)
                  : context.palette.panelText,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(WordStatus.masteryThreshold, (index) {
              final filled = index < status.stars;
              return Icon(
                filled ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 16,
                color: isMastered
                    ? AppColors.textOnColor
                    : filled
                        ? AppColors.buttonOrange
                        : context.palette.panelHint,
              );
            }),
          ),
        ],
      ),
    );
  }
}
