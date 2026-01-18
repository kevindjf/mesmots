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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: gameStateAsync.when(
        data: (gameState) {
          if (gameState.question == null) {
            // Game complete! Navigate to Fill-in-the-blanks
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
                      Text(
                        AppStrings.tapToReplay,
                        style: const TextStyle(
                          fontSize: AppTypography.bodySmall,
                          color: AppColors.textSecondary,
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
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusL,
                          ),
                          border: Border.all(
                            color: AppColors.textLight,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            gameState.userInput.isEmpty
                                ? '...'
                                : gameState.userInput,
                            style: const TextStyle(
                              fontSize: AppTypography.headingMedium,
                              fontWeight: AppTypography.semiBold,
                              letterSpacing: 4,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXl),

                      // Scrambled letters grid
                      Wrap(
                        spacing: AppDimensions.spacingM,
                        runSpacing: AppDimensions.spacingM,
                        alignment: WrapAlignment.center,
                        children: question.scrambledLetters.map((letter) {
                          // Check if letter is already used
                          final letterCount = question.word
                              .split('')
                              .where((l) => l == letter)
                              .length;
                          final usedCount = gameState.userInput
                              .split('')
                              .where((l) => l == letter)
                              .length;
                          final isDisabled = usedCount >= letterCount;

                          return _buildLetterButton(
                            letter,
                            isDisabled,
                            gameProvider,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppDimensions.spacingXxl),

                      // Control buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Clear button
                          _buildControlButton(
                            icon: Icons.refresh,
                            label: 'Effacer',
                            onTap: gameProvider.clearInput,
                            isEnabled: gameState.userInput.isNotEmpty,
                          ),

                          // Backspace button
                          _buildControlButton(
                            icon: Icons.backspace_outlined,
                            label: 'Retour',
                            onTap: gameProvider.removeLetter,
                            isEnabled: gameState.userInput.isNotEmpty,
                          ),

                          // Submit button
                          _buildControlButton(
                            icon: Icons.check,
                            label: 'Valider',
                            onTap: gameProvider.submitAnswer,
                            isEnabled: gameState.userInput.length ==
                                question.word.length,
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Erreur: $error'),
        ),
      ),
    );
  }

  Widget _buildLetterButton(
    String letter,
    bool isDisabled,
    ScrambleGame gameProvider,
  ) {
    return SizedBox(
      width: 60,
      height: 60,
      child: ElevatedButton(
        onPressed: isDisabled ? null : () => gameProvider.addLetter(letter),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isDisabled ? AppColors.background : AppColors.cardBackground,
          foregroundColor:
              isDisabled ? AppColors.textLight : AppColors.textPrimary,
          elevation: isDisabled ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            side: BorderSide(
              color: isDisabled ? AppColors.textLight : AppColors.primary,
              width: 2,
            ),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          letter.toUpperCase(),
          style: const TextStyle(
            fontSize: AppTypography.headingMedium,
            fontWeight: AppTypography.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isEnabled,
    bool isPrimary = false,
  }) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.4,
      child: Column(
        children: [
          IconButton(
            onPressed: isEnabled ? onTap : null,
            icon: Icon(icon),
            iconSize: 32,
            color: isPrimary ? AppColors.success : AppColors.primary,
            style: IconButton.styleFrom(
              backgroundColor: isPrimary
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.primary.withOpacity(0.1),
              padding: const EdgeInsets.all(AppDimensions.paddingL),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            label,
            style: TextStyle(
              fontSize: AppTypography.bodySmall,
              color: isPrimary ? AppColors.success : AppColors.primary,
              fontWeight: AppTypography.regular,
            ),
          ),
        ],
      ),
    );
  }
}
