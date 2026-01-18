import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/features/games/presentation/providers/fill_blanks_game_provider.dart';
import 'package:mesmots/features/games/presentation/widgets/game_header.dart';
import 'package:mesmots/features/games/presentation/widgets/success_overlay.dart';
import 'package:mesmots/shared/widgets/progress_stars.dart';
import 'package:mesmots/shared/widgets/speaker_button.dart';

class FillBlanksGameScreen extends ConsumerWidget {
  final String listId;

  const FillBlanksGameScreen({
    super.key,
    required this.listId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameStateAsync = ref.watch(fillBlanksGameProvider(listId));

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
            // Game complete!
            return SuccessOverlay(
              onNextLevel: () {
                // TODO: Navigate to next level (Writing)
                Navigator.pop(context);
              },
              onBackToList: () {
                Navigator.pop(context);
              },
            );
          }

          final gameProvider =
              ref.read(fillBlanksGameProvider(listId).notifier);
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

                      // Word display with blanks
                      _buildWordDisplay(question),
                      const SizedBox(height: AppDimensions.spacingXxl),

                      // Letter keyboard
                      _buildLetterKeyboard(gameProvider),
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
                            isEnabled: question.userInputs.isNotEmpty,
                          ),

                          // Backspace button
                          _buildControlButton(
                            icon: Icons.backspace_outlined,
                            label: 'Retour',
                            onTap: gameProvider.removeLetter,
                            isEnabled: question.userInputs.isNotEmpty,
                          ),

                          // Submit button (only enabled when all blanks filled)
                          _buildControlButton(
                            icon: Icons.check,
                            label: 'Valider',
                            onTap: gameProvider.submitAnswer,
                            isEnabled: question.areAllBlanksFilled,
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

  /// Build word display with blanks and filled letters
  Widget _buildWordDisplay(FillBlanksQuestion question) {
    return Wrap(
      spacing: AppDimensions.spacingS,
      runSpacing: AppDimensions.spacingS,
      alignment: WrapAlignment.center,
      children: List.generate(question.word.length, (index) {
        final isBlank = question.isBlank(index);
        final letter = question.getLetterAt(index);

        return Container(
          width: 45,
          height: 60,
          decoration: BoxDecoration(
            color: isBlank
                ? (letter != null
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.cardBackground)
                : AppColors.background,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            border: Border.all(
              color: isBlank ? AppColors.primary : AppColors.textLight,
              width: isBlank ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              letter?.toUpperCase() ?? '_',
              style: TextStyle(
                fontSize: AppTypography.headingMedium,
                fontWeight:
                    isBlank ? AppTypography.bold : AppTypography.semiBold,
                color: isBlank
                    ? (letter != null
                        ? AppColors.primary
                        : AppColors.textSecondary)
                    : AppColors.textPrimary,
              ),
            ),
          ),
        );
      }),
    );
  }

  /// Build AZERTY keyboard layout
  Widget _buildLetterKeyboard(FillBlanksGame gameProvider) {
    // French AZERTY keyboard layout
    final rows = [
      ['A', 'Z', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
      ['Q', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'M'],
      ['W', 'X', 'C', 'V', 'B', 'N'],
    ];

    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((letter) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _buildKeyboardButton(letter, gameProvider),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  /// Build a single keyboard button
  Widget _buildKeyboardButton(String letter, FillBlanksGame gameProvider) {
    return SizedBox(
      width: 32,
      height: 40,
      child: ElevatedButton(
        onPressed: () => gameProvider.addLetter(letter),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cardBackground,
          foregroundColor: AppColors.textPrimary,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            side: const BorderSide(
              color: AppColors.textLight,
              width: 1,
            ),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          letter,
          style: const TextStyle(
            fontSize: AppTypography.bodyMedium,
            fontWeight: AppTypography.regular,
          ),
        ),
      ),
    );
  }

  /// Build control button
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
