import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/features/games/presentation/providers/qcm_game_provider.dart';
import 'package:mesmots/features/games/presentation/screens/scramble_game_screen.dart';
import 'package:mesmots/shared/widgets/app_card.dart';
import 'package:mesmots/shared/widgets/circle_icon_button.dart';
import 'package:mesmots/shared/widgets/speaker_button.dart';
import 'package:mesmots/shared/widgets/progress_stars.dart';
import 'package:mesmots/shared/widgets/gradient_background.dart';
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
                        builder: (context) => ScrambleGameScreen(listId: widget.listId),
                      ),
                    );
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
          : () {
              setState(() {
                _selectedAnswer = text;
                _showFeedback = true;
              });

              gameProvider.answer(text);

              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) {
                  setState(() {
                    _selectedAnswer = null;
                    _showFeedback = false;
                  });
                }
              });
            },
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: AppTypography.headingSmall,
            fontWeight: AppTypography.semiBold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
