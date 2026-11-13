import 'package:flutter/material.dart';
import 'package:mesmots/core/extensions/palette_context.dart';
import 'package:mesmots/core/theme/app_palette.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/core/extensions/motion_context.dart';
import 'package:mesmots/core/utils/string_utils.dart';
import 'package:mesmots/features/games/presentation/providers/writing_game_provider.dart';
import 'package:mesmots/shared/widgets/shake.dart';

/// The word typed in "Écriture": green when right; after a mistake each
/// letter is green or red and the box shakes.
class WritingAnswer extends StatelessWidget {
  final WritingQuestion question;

  const WritingAnswer({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    final phase = question.phase;
    final palette = context.palette;
    final background = switch (phase) {
      WritingPhase.correct => AppColors.success,
      // Stays white: the green and red letters must read on it.
      WritingPhase.wrong => AppColors.surface,
      WritingPhase.typing => palette.tile,
    };
    final shadow = switch (phase) {
      WritingPhase.correct => AppColors.successShadow,
      WritingPhase.wrong => AppColors.errorShadow,
      WritingPhase.typing => palette.tileShadow,
    };

    return Shake(
      trigger: phase == WritingPhase.wrong ? 1 : 0,
      child: AnimatedContainer(
        duration: context.motion(const Duration(milliseconds: 200)),
        width: double.infinity,
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          boxShadow: [
            BoxShadow(color: shadow, blurRadius: 0, offset: const Offset(0, 4)),
          ],
        ),
        alignment: Alignment.center,
        child: FittedBox(fit: BoxFit.scaleDown, child: _text(palette)),
      ),
    );
  }

  Widget _text(AppPalette palette) {
    const style = TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: 32,
      fontWeight: AppTypography.bold,
      letterSpacing: 2,
    );
    switch (question.phase) {
      case WritingPhase.correct:
        return Text(
          question.input,
          style: style.copyWith(color: palette.onBlock(AppColors.success)),
        );
      case WritingPhase.wrong:
        final letters = question.input.graphemes;
        return Text.rich(
          TextSpan(
            children: [
              for (var i = 0; i < letters.length; i++)
                TextSpan(
                  text: letters[i],
                  style: style.copyWith(
                    color: question.marks[i]
                        ? AppColors.successDark
                        : AppColors.error,
                    decoration:
                        question.marks[i] ? null : TextDecoration.underline,
                    decorationColor: AppColors.error,
                    decorationThickness: 2,
                  ),
                ),
            ],
          ),
        );
      case WritingPhase.typing:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              question.input,
              style: style.copyWith(color: palette.tileText),
            ),
            // Cursor
            Container(
              width: 3,
              height: 34,
              margin: const EdgeInsets.only(left: 2),
              color: AppColors.primary,
            ),
          ],
        );
    }
  }
}
