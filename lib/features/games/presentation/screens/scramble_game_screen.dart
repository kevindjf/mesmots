import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/core/extensions/motion_context.dart';
import 'package:mesmots/features/games/presentation/providers/scramble_game_provider.dart';
import 'package:mesmots/features/games/presentation/widgets/game_header.dart';
import 'package:mesmots/features/games/presentation/widgets/scramble_answer.dart';
import 'package:mesmots/features/games/presentation/widgets/success_overlay.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_status.dart';
import 'package:mesmots/shared/widgets/circle_icon_button.dart';
import 'package:mesmots/shared/widgets/game_control_button.dart';
import 'package:mesmots/shared/widgets/gradient_background.dart';
import 'package:mesmots/shared/widgets/letter_button.dart';
import 'package:mesmots/shared/widgets/progress_stars.dart';
import 'package:mesmots/shared/widgets/speaker_button.dart';

/// "Lettres mélangées": hear the word and put its letters back in order.
class ScrambleGameScreen extends ConsumerWidget {
  final String listId;

  const ScrambleGameScreen({
    super.key,
    required this.listId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameStateAsync = ref.watch(scrambleGameProvider(listId));

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: gameStateAsync.when(
            data: (gameState) {
              final question = gameState.question;
              if (question == null) {
                return SuccessOverlay(
                  onReplay: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ScrambleGameScreen(listId: listId),
                      ),
                    );
                  },
                  onBackToList: () => Navigator.pop(context),
                );
              }

              final game = ref.read(scrambleGameProvider(listId).notifier);
              final hasFreeSlot = question.slots.asMap().entries.any(
                    (e) =>
                        e.value != null &&
                        !question.lockedSlots.contains(e.key),
                  );

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
                    progress: gameState.progress,
                    validatedCount: gameState.validatedCount,
                    totalCount: gameState.totalCount,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppDimensions.paddingXl),
                      child: Column(
                        children: [
                          SpeakerButton(word: question.word, size: 80),
                          const SizedBox(height: AppDimensions.spacingS),
                          const Text(
                            AppStrings.tapToReplay,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: AppTypography.bodySmall,
                              color: AppColors.textOnColor,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spacingL),
                          AnimatedProgressStars(
                            count: question.stars,
                            max: WordStatus.masteryThreshold,
                            size: AppDimensions.iconL,
                          ),
                          const SizedBox(height: AppDimensions.spacingXl),
                          ScrambleAnswer(
                            question: question,
                            onSlotTap: game.removeSlot,
                          ),
                          // The right spelling, shown after a mistake.
                          SizedBox(
                            height: 56,
                            child: Center(
                              child: AnimatedOpacity(
                                opacity: question.phase == ScramblePhase.wrong
                                    ? 1
                                    : 0,
                                duration: context.motion(
                                  const Duration(milliseconds: 200),
                                ),
                                child: Text(
                                  question.word,
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
                              for (var i = 0; i < question.tiles.length; i++)
                                LetterButton(
                                  letter: question.tiles[i],
                                  uppercase: false,
                                  isDisabled: question.isTileUsed(i),
                                  onTap: question.canPlay
                                      ? () => game.placeTile(i)
                                      : null,
                                ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.spacingXxl),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GameControlButton(
                                icon: Icons.refresh,
                                label: AppStrings.clearAll,
                                onTap: game.clearAll,
                                isEnabled: question.canPlay && hasFreeSlot,
                              ),
                              GameControlButton(
                                icon: Icons.lightbulb_outline,
                                label: AppStrings.hint,
                                onTap: game.hint,
                                isEnabled: question.canPlay,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.textOnColor),
            ),
            error: (error, stack) => Center(
              child: Text(
                AppStrings.errorGeneric,
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  color: AppColors.textOnColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
