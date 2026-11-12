import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/features/games/presentation/providers/word_search_game_provider.dart';
import 'package:mesmots/features/games/presentation/widgets/found_word_colors.dart';
import 'package:mesmots/features/games/presentation/widgets/game_header.dart';
import 'package:mesmots/features/games/presentation/widgets/success_overlay.dart';
import 'package:mesmots/features/games/presentation/widgets/word_search_board.dart';
import 'package:mesmots/features/games/presentation/widgets/word_to_find_chip.dart';
import 'package:mesmots/shared/widgets/circle_icon_button.dart';
import 'package:mesmots/shared/widgets/gradient_background.dart';

class WordSearchGameScreen extends ConsumerStatefulWidget {
  final String listId;

  const WordSearchGameScreen({super.key, required this.listId});

  @override
  ConsumerState<WordSearchGameScreen> createState() =>
      _WordSearchGameScreenState();
}

class _WordSearchGameScreenState extends ConsumerState<WordSearchGameScreen> {
  static const _celebrationDelay = Duration(milliseconds: 1200);

  bool _showSuccess = false;

  @override
  Widget build(BuildContext context) {
    final provider = wordSearchGameProvider(widget.listId);

    ref.listen(provider, (previous, next) {
      final wasComplete = previous?.valueOrNull?.isComplete ?? false;
      if (!wasComplete && (next.valueOrNull?.isComplete ?? false)) {
        Future.delayed(_celebrationDelay, () {
          if (mounted) setState(() => _showSuccess = true);
        });
      }
    });

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: ref.watch(provider).when(
                data: (state) => _showSuccess
                    ? SuccessOverlay(
                        onReplay: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                WordSearchGameScreen(listId: widget.listId),
                          ),
                        ),
                        onBackToList: () => Navigator.pop(context),
                      )
                    : _buildGame(state, ref.read(provider.notifier)),
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.textOnColor,
                  ),
                ),
                error: (error, _) => Center(
                  child: Text(
                    '$error',
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

  Widget _buildGame(WordSearchGameState state, WordSearchGame game) {
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
            ],
          ),
        ),
        GameHeader(
          progress: state.progress,
          validatedCount: state.foundCount,
          totalCount: state.totalCount,
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final boardSize = (constraints.maxWidth -
                      2 * AppDimensions.paddingL)
                  .clamp(0.0, constraints.maxHeight * 0.68);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Column(
                  children: [
                    SizedBox(
                      width: boardSize,
                      child: WordSearchBoard(
                        state: state,
                        onSelectionStart: game.startSelection,
                        onSelectionUpdate: game.updateSelection,
                        onSelectionEnd: game.endSelection,
                        onCellTap: game.tapCell,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXl),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: AppDimensions.spacingS,
                      runSpacing: AppDimensions.spacingM,
                      children: [
                        for (var i = 0; i < state.grid.words.length; i++)
                          WordToFindChip(
                            word: state.grid.words[i].word,
                            letterCount: state.grid.words[i].length,
                            foundColor: state.found.containsKey(i)
                                ? i.foundWordColor
                                : null,
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
