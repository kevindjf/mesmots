import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mesmots/core/extensions/palette_context.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/features/games/domain/entities/grid_point.dart';
import 'package:mesmots/features/games/presentation/providers/word_search_game_provider.dart';
import 'package:mesmots/features/games/presentation/widgets/found_word_colors.dart';

/// Word search letter grid. Words are selected by dragging a finger along
/// a row or a column, or by tapping the first then the last letter.
class WordSearchBoard extends StatelessWidget {
  final WordSearchGameState state;
  final ValueChanged<GridPoint> onSelectionStart;
  final ValueChanged<GridPoint> onSelectionUpdate;
  final VoidCallback onSelectionEnd;
  final ValueChanged<GridPoint> onCellTap;

  const WordSearchBoard({
    super.key,
    required this.state,
    required this.onSelectionStart,
    required this.onSelectionUpdate,
    required this.onSelectionEnd,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = state.grid.size;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingS),
      decoration: BoxDecoration(
        color: context.palette.panel,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: context.palette.panelOutline,
        boxShadow: [
          BoxShadow(
            color: context.palette.panelShadow,
            blurRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cellSize = constraints.maxWidth / size;

            GridPoint toPoint(Offset position) => GridPoint(
                  (position.dy / cellSize).floor().clamp(0, size - 1),
                  (position.dx / cellSize).floor().clamp(0, size - 1),
                );

            return GestureDetector(
              dragStartBehavior: DragStartBehavior.down,
              onTapUp: (d) => onCellTap(toPoint(d.localPosition)),
              onPanStart: (d) => onSelectionStart(toPoint(d.localPosition)),
              onPanUpdate: (d) => onSelectionUpdate(toPoint(d.localPosition)),
              onPanEnd: (_) => onSelectionEnd(),
              child: Column(
                children: [
                  for (var row = 0; row < size; row++)
                    Row(
                      children: [
                        for (var col = 0; col < size; col++)
                          _LetterCell(
                            letter: state.grid.letters[row][col],
                            size: cellSize,
                            background: _backgroundOf(GridPoint(row, col)),
                          ),
                      ],
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Color? _backgroundOf(GridPoint point) {
    if (state.selection.contains(point)) return AppColors.buttonBlue;
    return state.foundWordAt(point)?.foundWordColor;
  }
}

class _LetterCell extends StatelessWidget {
  final String letter;
  final double size;
  final Color? background;

  const _LetterCell({
    required this.letter,
    required this.size,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    final highlighted = background != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: size,
      height: size,
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: size * 0.55,
          fontWeight: AppTypography.bold,
          color: highlighted
              ? context.palette.onBlock(background!)
              : context.palette.panelText,
        ),
      ),
    );
  }
}
