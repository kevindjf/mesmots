import 'package:flutter/material.dart';
import 'package:mesmots/core/extensions/palette_context.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/core/extensions/motion_context.dart';
import 'package:mesmots/features/games/domain/entities/letter_puzzle.dart';
import 'package:mesmots/features/games/presentation/providers/puzzle_game_engine.dart';
import 'package:mesmots/features/games/presentation/widgets/game_layout.dart';
import 'package:mesmots/features/games/presentation/widgets/puzzle_word.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_status.dart';
import 'package:mesmots/shared/widgets/circle_icon_button.dart';
import 'package:mesmots/shared/widgets/game_control_button.dart';
import 'package:mesmots/shared/widgets/letter_button.dart';
import 'package:mesmots/shared/widgets/progress_stars.dart';
import 'package:mesmots/shared/widgets/speaker_button.dart';
import 'package:mesmots/shared/widgets/centered_scroll_view.dart';

/// Screen content of a letter puzzle game: close button, progress, word to
/// hear, stars, the word's boxes, the tiles and the controls. Sideways, the
/// word on the left, the tiles and the controls on the right.
class PuzzleGameView extends StatelessWidget {
  final PuzzleGameState state;
  final LetterPuzzle puzzle;
  final PuzzleGameEngine engine;

  const PuzzleGameView({
    super.key,
    required this.state,
    required this.puzzle,
    required this.engine,
  });

  @override
  Widget build(BuildContext context) {
    final canEdit = puzzle.canPlay && puzzle.hasRemovable;
    final prompt = <Widget>[
      if (engine.spellAloud)
        CircleIconButton.colored(
          icon: Icons.abc_rounded,
          onTap: engine.replaySpelling,
          color: AppColors.buttonPurple,
          shadowColor: AppColors.buttonPurpleShadow,
          size: 80,
          iconSize: AppDimensions.iconXl,
        )
      else
        SpeakerButton(word: puzzle.word, size: 80),
      const SizedBox(height: AppDimensions.spacingS),
      Text(
        engine.spellAloud ? AppStrings.spellingListen : AppStrings.tapToReplay,
        style: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: AppTypography.bodySmall,
          color: context.palette.onBackground,
          fontStyle: FontStyle.italic,
        ),
      ),
      const SizedBox(height: AppDimensions.spacingL),
      AnimatedProgressStars(
        count: state.stars,
        max: WordStatus.masteryThreshold,
        size: AppDimensions.iconL,
      ),
      const SizedBox(height: AppDimensions.spacingXl),
      PuzzleWord(
        puzzle: puzzle,
        onSlotTap: engine.remove,
        highlighted: state.spokenPosition,
      ),
      // The right spelling, shown after a mistake.
      SizedBox(
        height: 56,
        child: Center(
          child: AnimatedOpacity(
            opacity: puzzle.phase == PuzzlePhase.wrong ? 1 : 0,
            duration: context.motion(
              const Duration(milliseconds: 200),
            ),
            child: Text(
              puzzle.word,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: AppTypography.headingLarge,
                fontWeight: AppTypography.bold,
                color: context.palette.onBackground,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    ];
    final answer = <Widget>[
      Wrap(
        spacing: AppDimensions.spacingM,
        runSpacing: AppDimensions.spacingM,
        alignment: WrapAlignment.center,
        children: [
          for (var i = 0; i < puzzle.tiles.length; i++)
            LetterButton(
              letter: puzzle.tiles[i],
              uppercase: false,
              isDisabled: puzzle.isTileUsed(i),
              onTap: puzzle.canPlay ? () => engine.place(i) : null,
            ),
        ],
      ),
      const SizedBox(height: AppDimensions.spacingXxl),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GameControlButton(
            icon: Icons.backspace_outlined,
            label: AppStrings.erase,
            onTap: engine.removeLast,
            isEnabled: canEdit,
          ),
          GameControlButton(
            icon: Icons.refresh,
            label: AppStrings.clearAll,
            onTap: engine.clear,
            isEnabled: canEdit,
          ),
          GameControlButton(
            icon: Icons.lightbulb_outline,
            label: AppStrings.hint,
            onTap: engine.hint,
            isEnabled: puzzle.canPlay,
          ),
        ],
      ),
    ];
    const padding = EdgeInsets.all(AppDimensions.paddingXl);

    return GameLayout(
      progress: state.progress,
      validatedCount: state.validatedCount,
      totalCount: state.totalCount,
      portrait: CenteredScrollView(
        padding: padding,
        child: Column(children: [...prompt, ...answer]),
      ),
      prompt: CenteredScrollView(
        alwaysCenter: true,
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(children: prompt),
      ),
      answer: CenteredScrollView(
        alwaysCenter: true,
        padding: padding,
        child: Column(children: answer),
      ),
    );
  }
}
