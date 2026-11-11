import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/features/games/presentation/providers/writing_game_provider.dart';
import 'package:mesmots/features/games/presentation/widgets/game_header.dart';
import 'package:mesmots/features/games/presentation/widgets/success_overlay.dart';
import 'package:mesmots/shared/widgets/azerty_keyboard.dart';
import 'package:mesmots/shared/widgets/circle_icon_button.dart';
import 'package:mesmots/shared/widgets/game_control_button.dart';
import 'package:mesmots/shared/widgets/gradient_background.dart';
import 'package:mesmots/shared/widgets/progress_stars.dart';
import 'package:mesmots/shared/widgets/speaker_button.dart';

class WritingGameScreen extends ConsumerWidget {
  final String listId;

  const WritingGameScreen({
    super.key,
    required this.listId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameStateAsync = ref.watch(writingGameProvider(listId));

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: gameStateAsync.when(
            data: (gameState) {
              if (gameState.question == null) {
                return SuccessOverlay(
                  onReplay: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WritingGameScreen(listId: listId),
                      ),
                    );
                  },
                  onBackToList: () {
                    Navigator.pop(context);
                  },
                );
              }

              final gameProvider = ref.read(writingGameProvider(listId).notifier);
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
                    child: Column(
                      children: [
                        // Top section: speaker + stars + text display
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingXl,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: AppDimensions.spacingL),

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
                                const SizedBox(height: AppDimensions.spacingL),

                                // Stars
                                AnimatedProgressStars(
                                  count: question.successCount,
                                  size: AppDimensions.iconL,
                                ),
                                const SizedBox(height: AppDimensions.spacingXl),

                                // Read-only text display (like scramble game)
                                Container(
                                  width: double.infinity,
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
                                      question.userInput.isEmpty
                                          ? '...'
                                          : question.userInput,
                                      style: TextStyle(
                                        fontFamily: AppTypography.fontFamily,
                                        fontSize: AppTypography.headingMedium,
                                        fontWeight: AppTypography.semiBold,
                                        letterSpacing: 4,
                                        color: question.userInput.isEmpty
                                            ? AppColors.textLight
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.spacingL),
                              ],
                            ),
                          ),
                        ),

                        // Bottom section: keyboard + action buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingS,
                          ),
                          child: AzertyKeyboard(
                            onLetterTap: (letter) => gameProvider.addLetter(letter),
                            onBackspace: gameProvider.removeLetter,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingM),

                        // Control buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingXl,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GameControlButton(
                                icon: Icons.refresh,
                                label: 'Effacer',
                                onTap: gameProvider.clearInput,
                                isEnabled: question.userInput.isNotEmpty,
                              ),
                              GameControlButton(
                                icon: Icons.check,
                                label: 'Valider',
                                onTap: gameProvider.submitAnswer,
                                isEnabled: question.userInput.trim().isNotEmpty,
                                isPrimary: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingM),
                      ],
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
