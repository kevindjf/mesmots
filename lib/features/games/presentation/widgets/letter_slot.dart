import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/core/extensions/motion_context.dart';
import 'package:mesmots/shared/widgets/pop_in.dart';

/// Look of a [LetterSlot].
enum LetterSlotState {
  /// Waiting for a letter.
  empty,

  /// Holds a letter the child can take back.
  filled,

  /// Holds a right letter kept after a mistake or given by the help.
  locked,

  /// Word right: green.
  correct,

  /// Wrong letter: red.
  wrong,
}

/// One box of the answer in "Lettres mélangées".
class LetterSlot extends StatelessWidget {
  final String? letter;
  final LetterSlotState state;
  final double size;
  final VoidCallback? onTap;

  const LetterSlot({
    super.key,
    required this.letter,
    required this.state,
    required this.size,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (background, shadow, text) = switch (state) {
      LetterSlotState.empty => (
          AppColors.surface.withValues(alpha: 0.35),
          Colors.transparent,
          AppColors.textPrimary,
        ),
      LetterSlotState.filled => (
          AppColors.surface,
          AppColors.primaryDark,
          AppColors.textPrimary,
        ),
      LetterSlotState.locked => (
          AppColors.surface,
          AppColors.primaryDark,
          AppColors.successDark,
        ),
      LetterSlotState.correct => (
          AppColors.success,
          AppColors.successShadow,
          AppColors.textOnColor,
        ),
      LetterSlotState.wrong => (
          AppColors.error,
          AppColors.errorShadow,
          AppColors.textOnColor,
        ),
    };

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: context.motion(const Duration(milliseconds: 200)),
        width: size,
        height: size * 1.15,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          boxShadow: [
            BoxShadow(color: shadow, blurRadius: 0, offset: const Offset(0, 3)),
          ],
        ),
        alignment: Alignment.center,
        child: letter == null
            ? null
            : PopIn(
                key: ValueKey(letter),
                duration: const Duration(milliseconds: 350),
                fromScale: 0.5,
                child: Text(
                  letter!,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: size * 0.55,
                    fontWeight: AppTypography.bold,
                    color: text,
                  ),
                ),
              ),
      ),
    );
  }
}
