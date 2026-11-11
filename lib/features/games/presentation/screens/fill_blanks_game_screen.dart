import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jerevise/core/constants/app_colors.dart';
import 'package:jerevise/core/constants/app_dimensions.dart';
import 'package:jerevise/core/constants/app_strings.dart';
import 'package:jerevise/core/constants/app_typography.dart';
import 'package:jerevise/features/games/presentation/providers/fill_blanks_game_provider.dart';
import 'package:jerevise/features/games/presentation/screens/writing_game_screen.dart';
import 'package:jerevise/features/games/presentation/widgets/game_header.dart';
import 'package:jerevise/features/games/presentation/widgets/success_overlay.dart';
import 'package:jerevise/core/utils/string_utils.dart';
import 'package:jerevise/shared/widgets/circle_icon_button.dart';
import 'package:jerevise/shared/widgets/game_control_button.dart';
import 'package:jerevise/shared/widgets/gradient_background.dart';
import 'package:jerevise/shared/widgets/letter_button.dart';
import 'package:jerevise/shared/widgets/progress_stars.dart';
import 'package:jerevise/shared/widgets/speaker_button.dart';

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
                        builder: (context) => WritingGameScreen(listId: listId),
                      ),
                    );
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

                          // Word display with blanks
                          _buildWordDisplay(question),
                          const SizedBox(height: AppDimensions.spacingXxl),

                          // Letter keyboard
                          _buildLetterKeyboard(question, gameProvider),
                          const SizedBox(height: AppDimensions.spacingXxl),

                          // Control buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GameControlButton(
                                icon: Icons.refresh,
                                label: 'Effacer',
                                onTap: gameProvider.clearInput,
                                isEnabled: question.userInputs.isNotEmpty,
                              ),
                              GameControlButton(
                                icon: Icons.backspace_outlined,
                                label: 'Retour',
                                onTap: gameProvider.removeLetter,
                                isEnabled: question.userInputs.isNotEmpty,
                              ),
                              GameControlButton(
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

  /// Build word display with blanks and filled letters
  Widget _buildWordDisplay(FillBlanksQuestion question) {
    return Wrap(
      spacing: AppDimensions.spacingS,
      runSpacing: AppDimensions.spacingS,
      alignment: WrapAlignment.center,
      children: List.generate(question.word.graphemeLen, (index) {
        final isBlank = question.isBlank(index);
        final letter = question.getLetterAt(index);

        return Container(
          width: 45,
          height: 60,
          decoration: BoxDecoration(
            color: isBlank
                ? (letter != null
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.surface)
                : AppColors.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            boxShadow: [
              BoxShadow(
                color: isBlank ? AppColors.primaryDark : AppColors.primaryDark.withValues(alpha: 0.5),
                blurRadius: 0,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              letter?.toUpperCase() ?? '_',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: AppTypography.headingMedium,
                fontWeight:
                    isBlank ? AppTypography.bold : AppTypography.semiBold,
                color: isBlank
                    ? (letter != null
                        ? AppColors.primary
                        : AppColors.textLight)
                    : AppColors.textPrimary,
              ),
            ),
          ),
        );
      }),
    );
  }

  /// Build dynamic keyboard with only letters from current word
  Widget _buildLetterKeyboard(FillBlanksQuestion question, FillBlanksGame gameProvider) {

    // Extract unique letters from the word (grapheme-aware for proper accent handling)
    final uniqueLetters = <String>{};
    for (final char in question.word.graphemes) {
      uniqueLetters.add(char.toUpperCase());
    }

    // Convert to sorted list for consistent display
    final letters = uniqueLetters.toList()..sort();

    // Organize letters into rows (max 10 per row for readability)
    const maxKeysPerRow = 10;
    const horizontalPadding = 2.0;

    final rows = <List<String>>[];
    for (int i = 0; i < letters.length; i += maxKeysPerRow) {
      final end = (i + maxKeysPerRow).clamp(0, letters.length);
      rows.add(letters.sublist(i, end));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final keySize = ((constraints.maxWidth - horizontalPadding * 2 * maxKeysPerRow) / maxKeysPerRow).clamp(28.0, 34.0);

        return Column(
          children: rows.map((row) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: row.map((letter) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: LetterButton.keyboard(
                      letter: letter,
                      size: keySize,
                      onTap: () => gameProvider.addLetter(letter),
                    ),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
