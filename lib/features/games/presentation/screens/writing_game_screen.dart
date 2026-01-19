import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/features/games/presentation/providers/writing_game_provider.dart';
import 'package:mesmots/features/games/presentation/widgets/game_header.dart';
import 'package:mesmots/features/games/presentation/widgets/success_overlay.dart';
import 'package:mesmots/shared/widgets/progress_stars.dart';
import 'package:mesmots/shared/widgets/speaker_button.dart';

class WritingGameScreen extends ConsumerStatefulWidget {
  final String listId;

  const WritingGameScreen({
    super.key,
    required this.listId,
  });

  @override
  ConsumerState<WritingGameScreen> createState() => _WritingGameScreenState();
}

class _WritingGameScreenState extends ConsumerState<WritingGameScreen> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameStateAsync = ref.watch(writingGameProvider(widget.listId));

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
                // All levels completed, return to list
                Navigator.pop(context);
              },
              onBackToList: () {
                Navigator.pop(context);
              },
            );
          }

          final gameProvider = ref.read(writingGameProvider(widget.listId).notifier);
          final question = gameState.question!;

          // Update text controller when question changes
          if (_textController.text != question.userInput) {
            _textController.text = question.userInput;
            _textController.selection = TextSelection.fromPosition(
              TextPosition(offset: _textController.text.length),
            );
          }

          return GestureDetector(
            onTap: () {
              // Dismiss keyboard when tapping outside
              FocusScope.of(context).unfocus();
            },
            child: Column(
              children: [
                // Progress header
                GameHeader(
                  progress: gameState.progress,
                  validatedCount: gameState.validatedCount,
                  totalCount: gameState.totalCount,
                ),

                // Main content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppDimensions.paddingXl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: AppDimensions.spacingXxl),

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

                        // Instruction
                        const Text(
                          'Écris le mot que tu entends',
                          style: TextStyle(
                            fontSize: AppTypography.headingSmall,
                            fontWeight: AppTypography.semiBold,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingXl),

                        // Text input field
                        TextField(
                          controller: _textController,
                          focusNode: _focusNode,
                          autofocus: true,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: AppTypography.headingLarge,
                            fontWeight: AppTypography.semiBold,
                            letterSpacing: 2,
                          ),
                          decoration: InputDecoration(
                            hintText: '...',
                            hintStyle: TextStyle(
                              color: AppColors.textSecondary.withOpacity(0.5),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusL,
                              ),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusL,
                              ),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 3,
                              ),
                            ),
                            filled: true,
                            fillColor: AppColors.cardBackground,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingL,
                              vertical: AppDimensions.paddingL,
                            ),
                          ),
                          onChanged: (value) {
                            gameProvider.updateInput(value);
                          },
                          textCapitalization: TextCapitalization.none,
                          autocorrect: false,
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
                              onTap: () {
                                gameProvider.clearInput();
                                _textController.clear();
                              },
                              isEnabled: question.userInput.isNotEmpty,
                            ),

                            // Submit button
                            _buildControlButton(
                              icon: Icons.check,
                              label: 'Valider',
                              onTap: gameProvider.submitAnswer,
                              isEnabled: question.userInput.trim().isNotEmpty,
                              isPrimary: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Erreur: $error'),
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
