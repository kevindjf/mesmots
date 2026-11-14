import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmots/core/extensions/palette_context.dart';
import 'package:mesmots/core/constants/app_breakpoints.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/extensions/responsive_context.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/features/games/presentation/providers/word_search_game_provider.dart';
import 'package:mesmots/features/games/presentation/widgets/found_word_colors.dart';
import 'package:mesmots/features/games/presentation/widgets/game_header.dart';
import 'package:mesmots/features/games/presentation/widgets/success_overlay.dart';
import 'package:mesmots/features/games/presentation/widgets/word_search_board.dart';
import 'package:mesmots/features/games/presentation/widgets/word_to_find_chip.dart';
import 'package:mesmots/shared/widgets/circle_icon_button.dart';
import 'package:mesmots/shared/widgets/gradient_background.dart';
import 'package:mesmots/shared/widgets/bounded_content.dart';

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
          child: BoundedContent.sideBySide(
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
                  loading: () => Center(
                    child: CircularProgressIndicator(
                      color: context.palette.onBackground,
                    ),
                  ),
                  error: (error, _) => Center(
                    child: Text(
                      '$error',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        color: context.palette.onBackground,
                      ),
                    ),
                  ),
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildGame(WordSearchGameState state, WordSearchGame game) {
    final board = WordSearchBoard(
      state: state,
      onSelectionStart: game.startSelection,
      onSelectionUpdate: game.updateSelection,
      onSelectionEnd: game.endSelection,
    );
    final words = Wrap(
      alignment: WrapAlignment.center,
      spacing: AppDimensions.spacingS,
      runSpacing: AppDimensions.spacingM,
      children: [
        for (var i = 0; i < state.grid.words.length; i++)
          WordToFindChip(
            word: state.grid.words[i].word,
            letterCount: state.grid.words[i].length,
            foundColor: state.found.containsKey(i) ? i.foundWordColor : null,
          ),
      ],
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
            ],
          ),
        ),
        GameHeader(
          progress: state.progress,
          validatedCount: state.foundCount,
          totalCount: state.totalCount,
        ),
        // The board stays out of any scroll view: a vertical drag on it must
        // select letters, not scroll. Only the words to find scroll, when
        // the list is long.
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => context.isTabletLandscape
                ? _buildSideBySide(constraints, board, words)
                : _buildStacked(constraints, board, words),
          ),
        ),
      ],
    );
  }

  /// The board, then the words to find below it.
  Widget _buildStacked(
    BoxConstraints constraints,
    Widget board,
    Widget words,
  ) {
    final boardSize = (constraints.maxWidth - 2 * AppDimensions.paddingL)
        .clamp(0.0, constraints.maxHeight * 0.68);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: AppDimensions.paddingL),
          child: SizedBox(width: boardSize, child: board),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.paddingL,
              AppDimensions.spacingXl,
              AppDimensions.paddingL,
              AppDimensions.paddingL,
            ),
            child: words,
          ),
        ),
      ],
    );
  }

  /// Tablet held sideways: the board as tall as the screen allows, the words
  /// to find next to it.
  Widget _buildSideBySide(
    BoxConstraints constraints,
    Widget board,
    Widget words,
  ) {
    final boardSize =
        (constraints.maxHeight - 2 * AppDimensions.paddingL).clamp(
      0.0,
      constraints.maxWidth -
          AppBreakpoints.sidePanelWidth -
          2 * AppDimensions.paddingL,
    );
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: SizedBox(width: boardSize, child: board),
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: words,
            ),
          ),
        ),
      ],
    );
  }
}
