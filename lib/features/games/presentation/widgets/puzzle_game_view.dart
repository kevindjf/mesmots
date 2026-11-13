import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/core/extensions/motion_context.dart';
import 'package:mesmots/features/games/domain/entities/letter_puzzle.dart';
import 'package:mesmots/features/games/presentation/providers/puzzle_game_engine.dart';
import 'package:mesmots/features/games/presentation/widgets/game_header.dart';
import 'package:mesmots/features/games/presentation/widgets/puzzle_word.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_status.dart';
import 'package:mesmots/shared/widgets/circle_icon_button.dart';
import 'package:mesmots/shared/widgets/game_control_button.dart';
import 'package:mesmots/shared/widgets/letter_button.dart';
import 'package:mesmots/shared/widgets/progress_stars.dart';
import 'package:mesmots/shared/widgets/speaker_button.dart';

/// Screen content of a letter puzzle game: close button, progress, word to
/// hear, stars, the word's boxes, the tiles and the controls.
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: AppDimensions.paddingM,
          ),
          child: Row(
            children: [
              CircleIconButton.surface(
                icon: Icons.close,
                onTap: () => Navigator.pop(context),
              ),
              const Spacer(),
            ],
          ),
        ),
        GameHeader(
          progress: state.progress,
          validatedCount: state.validatedCount,
          totalCount: state.totalCount,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingXl),
            child: Column(
              children: [
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
                  engine.spellAloud
                      ? AppStrings.spellingListen
                      : AppStrings.tapToReplay,
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: AppTypography.bodySmall,
                    color: AppColors.textOnColor,
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
                        style: const TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: AppTypography.headingLarge,
                          fontWeight: AppTypography.bold,
                          color: AppColors.textOnColor,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}
