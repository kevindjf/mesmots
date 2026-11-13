import 'package:flutter/material.dart';
import 'package:mesmots/core/extensions/palette_context.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/features/games/domain/entities/crossword.dart';
import 'package:mesmots/features/games/domain/entities/grid_point.dart';

/// Clue of a crossword: its number, direction and a speaker.
/// The written word is never shown, the child listens to it.
class CrosswordClueChip extends StatelessWidget {
  final CrosswordEntry entry;
  final bool isSelected;
  final bool isSolved;
  final VoidCallback onTap;

  const CrosswordClueChip({
    super.key,
    required this.entry,
    required this.isSelected,
    required this.isSolved,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color background = isSolved
        ? AppColors.success
        : isSelected
            ? AppColors.buttonOrange
            : context.palette.panel;
    final Color foreground = isSolved || isSelected
        ? context.palette.onBlock(background)
        : context.palette.panelText;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(
          minHeight: AppDimensions.minTouchTarget,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingS,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          boxShadow: [
            BoxShadow(
              color: context.palette.panelShadow,
              blurRadius: 0,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${entry.number}',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: AppTypography.bodyLarge,
                fontWeight: AppTypography.bold,
                color: foreground,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingXs),
            Icon(
              entry.direction == WordDirection.horizontal
                  ? Icons.arrow_forward_rounded
                  : Icons.arrow_downward_rounded,
              size: AppDimensions.iconS,
              color: foreground,
            ),
            const SizedBox(width: AppDimensions.spacingXs),
            Icon(
              isSolved ? Icons.check_rounded : Icons.volume_up_rounded,
              size: AppDimensions.iconS,
              color: foreground,
            ),
          ],
        ),
      ),
    );
  }
}
