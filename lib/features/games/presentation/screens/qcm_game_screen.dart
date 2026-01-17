import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/features/games/presentation/providers/qcm_game_provider.dart';
import 'package:mesmots/shared/widgets/app_card.dart';
import 'package:mesmots/shared/widgets/speaker_button.dart';
import 'package:mesmots/shared/widgets/progress_stars.dart';
import 'package:mesmots/features/games/presentation/widgets/game_header.dart';
import 'package:mesmots/features/games/presentation/widgets/success_overlay.dart';

class QcmGameScreen extends ConsumerStatefulWidget {
  final String listId;

  const QcmGameScreen({
    super.key,
    required this.listId,
  });

  @override
  ConsumerState<QcmGameScreen> createState() => _QcmGameScreenState();
}

class _QcmGameScreenState extends ConsumerState<QcmGameScreen> {
  String? _selectedAnswer;
  bool _showFeedback = false;

  @override
  Widget build(BuildContext context) {
    final gameStateAsync = ref.watch(qcmGameProvider(widget.listId));

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
                // TODO: Navigate to next level
                Navigator.pop(context);
              },
              onBackToList: () {
                Navigator.pop(context);
              },
            );
          }

          final gameProvider = ref.read(qcmGameProvider(widget.listId).notifier);
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

                      // Options (2x2 grid)
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: AppDimensions.spacingL,
                          mainAxisSpacing: AppDimensions.spacingL,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: question.options.map((option) {
                            return _buildOptionCard(
                              option.text,
                              option.isCorrect,
                              gameProvider,
                            );
                          }).toList(),
                        ),
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

  Widget _buildOptionCard(
    String text,
    bool isCorrect,
    QcmGame gameProvider,
  ) {
    final isSelected = _selectedAnswer == text;
    final showCorrect = _showFeedback && isCorrect;
    final showIncorrect = _showFeedback && isSelected && !isCorrect;

    return GameCard(
      isSelected: isSelected && !_showFeedback,
      isCorrect: showCorrect,
      isIncorrect: showIncorrect,
      onTap: _showFeedback
          ? null
          : () async {
              setState(() {
                _selectedAnswer = text;
                _showFeedback = true;
              });

              // Submit answer
              await gameProvider.answer(text);

              // Reset for next question
              if (mounted) {
                setState(() {
                  _selectedAnswer = null;
                  _showFeedback = false;
                });
              }
            },
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: AppTypography.headingSmall,
            fontWeight: AppTypography.semiBold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
