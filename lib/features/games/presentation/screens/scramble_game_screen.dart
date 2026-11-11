import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/features/games/presentation/providers/scramble_game_provider.dart';
import 'package:mesmots/features/games/presentation/screens/fill_blanks_game_screen.dart';
import 'package:mesmots/features/games/presentation/widgets/game_header.dart';
import 'package:mesmots/features/games/presentation/widgets/success_overlay.dart';
import 'package:mesmots/core/utils/string_utils.dart';
import 'package:mesmots/shared/widgets/circle_icon_button.dart';
import 'package:mesmots/shared/widgets/game_control_button.dart';
import 'package:mesmots/shared/widgets/gradient_background.dart';
import 'package:mesmots/shared/widgets/letter_button.dart';
import 'package:mesmots/shared/widgets/progress_stars.dart';
import 'package:mesmots/shared/widgets/speaker_button.dart';

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
              if (gameState.question == null) {
                return SuccessOverlay(
                  onNextLevel: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FillBlanksGameScreen(listId: listId),
                      ),
                    );
                  },
                  onBackToList: () {
                    Navigator.pop(context);
                  },
                );
              }

              final gameProvider = ref.read(scrambleGameProvider(listId).notifier);
              final question = gameState.question!;

              return Column(
                children: [
                  // Header with close button
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

                  // Progress header
                  GameHeader(
                    progress: gameState.progress,
                    validatedCount: gameState.validatedCount,
                    totalCount: gameState.totalCount,
                  ),

                  // Main content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingXl),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Speaker button
                          SpeakerButton(
                            word: question.word,
                            size: 80,
                          ),
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
                          const SizedBox(height: AppDimensions.spacingXl),

                          // Stars
                          AnimatedProgressStars(
                            count: question.successCount,
                            size: AppDimensions.iconL,
                          ),
                          const SizedBox(height: AppDimensions.spacingXxl),

                          // User input display
                          Container(
                            height: 60,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingL,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.primaryDark,
                                  blurRadius: 0,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                gameState.userInput.isEmpty
                                    ? '...'
                                    : gameState.userInput,
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: AppTypography.headingMedium,
                                  fontWeight: AppTypography.semiBold,
                                  letterSpacing: 4,
                                  color: gameState.userInput.isEmpty
                                      ? AppColors.textLight
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spacingXl),

                          // Scrambled letters grid
                          Builder(builder: (context) {
                            // Compute which tile indices are used by matching
                            // each userInput character to a specific scrambled tile
                            final usedIndices = <int>{};
                            for (final inputChar in gameState.userInput.graphemes) {
                              for (int i = 0; i < question.scrambledLetters.length; i++) {
                                if (!usedIndices.contains(i) &&
                                    question.scrambledLetters[i] == inputChar) {
                                  usedIndices.add(i);
                                  break;
                                }
                              }
                            }

                            return Wrap(
                              spacing: AppDimensions.spacingM,
                              runSpacing: AppDimensions.spacingM,
                              alignment: WrapAlignment.center,
                              children: question.scrambledLetters
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                return LetterButton(
                                  letter: entry.value,
                                  isDisabled: usedIndices.contains(entry.key),
                                  onTap: () => gameProvider.addLetter(entry.value),
                                );
                              }).toList(),
                            );
                          },),
                          const SizedBox(height: AppDimensions.spacingXxl),

                          // Control buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GameControlButton(
                                icon: Icons.refresh,
                                label: 'Effacer',
                                onTap: gameProvider.clearInput,
                                isEnabled: gameState.userInput.isNotEmpty,
                              ),
                              GameControlButton(
                                icon: Icons.backspace_outlined,
                                label: 'Retour',
                                onTap: gameProvider.removeLetter,
                                isEnabled: gameState.userInput.isNotEmpty,
                              ),
                              GameControlButton(
                                icon: Icons.check,
                                label: 'Valider',
                                onTap: gameProvider.submitAnswer,
                                isEnabled: gameState.userInput.graphemeLen ==
                                    question.word.graphemeLen,
                                isPrimary: true,
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
                'Erreur: $error',
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
