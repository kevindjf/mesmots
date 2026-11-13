import 'package:flutter/material.dart';
import 'package:mesmots/core/extensions/palette_context.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/core/extensions/motion_context.dart';
import 'package:mesmots/shared/widgets/pop_in.dart';

/// Look of a [LetterSlot].
enum LetterSlotState {
  /// Waiting for a letter.
  empty,

  /// A letter of the word given by the game (not to find).
  given,

  /// Holds a letter the child can take back.
  filled,

  /// Holds a right letter kept after a mistake or given by the help.
  locked,

  /// Word right: green.
  correct,

  /// Wrong letter: red.
  wrong,
}

/// One letter box of a word puzzle ("Lettres mélangées", "Mots à trous").
class LetterSlot extends StatelessWidget {
  final String? letter;
  final LetterSlotState state;
  final double size;
  final VoidCallback? onTap;

  /// The letter of this box is being spelled aloud.
  final bool isHighlighted;

  const LetterSlot({
    super.key,
    required this.letter,
    required this.state,
    required this.size,
    this.onTap,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final (background, shadow, text) = switch (state) {
      LetterSlotState.empty => (
          palette.slot,
          Colors.transparent,
          palette.tileText,
        ),
      // Plain letters on the background: clearly not a box to fill.
      LetterSlotState.given => (
          Colors.transparent,
          Colors.transparent,
          palette.onBackground,
        ),
      LetterSlotState.filled => (
          palette.tile,
          palette.tileShadow,
          palette.tileText,
        ),
      // Stays white: the dark green letter must read on it in every theme.
      LetterSlotState.locked => (
          AppColors.surface,
          AppColors.successShadow,
          AppColors.successDark,
        ),
      LetterSlotState.correct => (
          AppColors.success,
          AppColors.successShadow,
          palette.onBlock(AppColors.success),
        ),
      LetterSlotState.wrong => (
          AppColors.error,
          AppColors.errorShadow,
          palette.onBlock(AppColors.error),
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
          border: isHighlighted
              ? Border.all(color: AppColors.accent, width: 3)
              : state == LetterSlotState.empty
                  ? Border.all(color: palette.slotBorder, width: 2)
                  : null,
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
