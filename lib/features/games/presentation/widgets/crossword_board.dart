import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/features/games/domain/entities/grid_point.dart';
import 'package:mesmots/features/games/presentation/providers/crossword_game_provider.dart';

/// Crossword grid. Empty squares are transparent so the grid shape shows.
class CrosswordBoard extends StatelessWidget {
  final CrosswordGameState state;
  final ValueChanged<GridPoint> onCellTap;

  const CrosswordBoard({
    super.key,
    required this.state,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    final crossword = state.crossword;

    return AspectRatio(
      aspectRatio: crossword.cols / crossword.rows,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellSize = constraints.maxWidth / crossword.cols;
          final selectedCells = state.selected.cells.toSet();
          final wrongCells = state.wrongCells;

          return Column(
            children: [
              for (var row = 0; row < crossword.rows; row++)
                Row(
                  children: [
                    for (var col = 0; col < crossword.cols; col++)
                      _buildCell(
                        GridPoint(row, col),
                        cellSize,
                        selectedCells,
                        wrongCells,
                      ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCell(
    GridPoint point,
    double size,
    Set<GridPoint> selectedCells,
    Set<GridPoint> wrongCells,
  ) {
    if (!state.crossword.isCell(point)) {
      return SizedBox(width: size, height: size);
    }

    final Color background;
    final Color textColor;
    if (state.isSolvedCell(point)) {
      background = AppColors.success;
      textColor = AppColors.textOnColor;
    } else if (wrongCells.contains(point)) {
      background = AppColors.error;
      textColor = AppColors.textOnColor;
    } else if (point == state.cursor) {
      background = AppColors.buttonOrange;
      textColor = AppColors.textOnColor;
    } else if (selectedCells.contains(point)) {
      background = AppColors.iconBackground;
      textColor = AppColors.textPrimary;
    } else {
      background = AppColors.surface;
      textColor = AppColors.textPrimary;
    }

    final number = state.crossword.numberAt(point);
    final letter = state.inputs[point];
    final isGiven = state.locked.contains(point);

    return GestureDetector(
      onTap: () => onCellTap(point),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: size,
        height: size,
        margin: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: background,
          border: Border.all(color: AppColors.primaryDark, width: 1),
          borderRadius: BorderRadius.circular(size * 0.15),
        ),
        child: Stack(
          children: [
            if (number != null)
              Positioned(
                left: 2,
                top: 1,
                child: Text(
                  '$number',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: size * 0.26,
                    fontWeight: AppTypography.bold,
                    color: textColor,
                  ),
                ),
              ),
            if (letter != null)
              Center(
                child: Text(
                  letter,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: size * 0.55,
                    fontWeight:
                        isGiven ? AppTypography.semiBold : AppTypography.bold,
                    color: textColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
