import 'package:flutter/material.dart';
import 'package:mesmots/core/extensions/palette_context.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/core/extensions/motion_context.dart';
import 'package:mesmots/shared/widgets/app_card.dart';

/// One spelling proposed in "Le bon mot".
///
/// Once the child has answered: the right spelling turns green (and grows
/// if the child picked another one), the wrong pick turns red.
class QcmOptionCard extends StatelessWidget {
  final String text;
  final bool isCorrect;
  final bool isAnswered;
  final bool isSelected;
  final VoidCallback onTap;

  const QcmOptionCard({
    super.key,
    required this.text,
    required this.isCorrect,
    required this.isAnswered,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final showCorrect = isAnswered && isCorrect;
    final showIncorrect = isAnswered && isSelected && !isCorrect;
    // Highlight the right spelling when the child missed it.
    final missed = showCorrect && !isSelected;
    final isDimmed = isAnswered && !showCorrect && !showIncorrect;

    return AnimatedScale(
      scale: missed ? 1.08 : 1,
      duration: context.motion(const Duration(milliseconds: 300)),
      curve: Curves.easeOutBack,
      child: AnimatedOpacity(
        opacity: isDimmed ? 0.5 : 1,
        duration: context.motion(const Duration(milliseconds: 200)),
        child: GameCard(
          isCorrect: showCorrect,
          isIncorrect: showIncorrect,
          onTap: isAnswered ? null : onTap,
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: AppTypography.headingMedium,
                fontWeight: AppTypography.bold,
                color: showCorrect
                    ? context.palette.onBlock(AppColors.success)
                    : showIncorrect
                        ? context.palette.onBlock(AppColors.error)
                        : context.palette.panelText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
