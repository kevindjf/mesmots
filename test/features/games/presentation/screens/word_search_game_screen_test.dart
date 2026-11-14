import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/theme/app_palette.dart';
import 'package:mesmots/core/theme/app_theme.dart';
import 'package:mesmots/features/games/domain/entities/grid_point.dart';
import 'package:mesmots/features/games/presentation/providers/word_search_game_provider.dart';
import 'package:mesmots/features/games/presentation/screens/word_search_game_screen.dart';
import 'package:mesmots/features/games/presentation/widgets/word_search_board.dart';

import '../../../../goldens/golden_harness.dart';

/// A long weekly list: the words to find no longer fit under the grid.
final _longList = goldenList(
  id: 'long',
  words: const [
    'maison', 'école', 'jardin', 'chapeau', 'bateau', 'oiseau', 'gâteau',
    'crayon', 'cartable', 'cahier', 'trousse', 'règle', 'gomme', 'stylo',
  ],
);

void main() {
  Future<WordSearchGameState Function()> pumpGame(WidgetTester tester) async {
    await pumpGoldenScreen(
      tester,
      WordSearchGameScreen(listId: _longList.id),
      theme: AppTheme.of(AppPalette.light),
      overrides: goldenOverrides([_longList]),
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(WordSearchGameScreen)),
    );
    return () =>
        container.read(wordSearchGameProvider(_longList.id)).requireValue;
  }

  testWidgets('keeps the board out of any scroll view', (tester) async {
    // Arrange
    await pumpGame(tester);

    // Act
    final scrollableAncestors = find.ancestor(
      of: find.byType(WordSearchBoard),
      matching: find.byType(Scrollable),
    );

    // Assert
    expect(scrollableAncestors, findsNothing);
  });

  testWidgets('selects a vertical word by dragging, without scrolling',
      (tester) async {
    // Arrange
    final state = await pumpGame(tester);
    final grid = state().grid;
    final index =
        grid.words.indexWhere((w) => w.direction == WordDirection.vertical);
    expect(index, isNot(-1), reason: 'the grid should hold a vertical word');
    final word = grid.words[index];
    final board = tester.getRect(find.byType(WordSearchBoard));
    final cellSize = (board.width - 2 * AppDimensions.paddingS) / grid.size;
    Offset centerOf(GridPoint point) =>
        board.topLeft +
        Offset(
          AppDimensions.paddingS + (point.col + 0.5) * cellSize,
          AppDimensions.paddingS + (point.row + 0.5) * cellSize,
        );

    // Act
    final gesture = await tester.startGesture(centerOf(word.cells.first));
    for (final cell in word.cells.skip(1)) {
      await gesture.moveTo(centerOf(cell));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 300));

    // Assert
    expect(state().found.containsKey(index), isTrue);
    expect(tester.getRect(find.byType(WordSearchBoard)), board);
  });

  testWidgets('tapping the first then the last letter finds nothing',
      (tester) async {
    // Arrange
    final state = await pumpGame(tester);
    final word = state().grid.words.first;
    final board = tester.getRect(find.byType(WordSearchBoard));
    final cellSize =
        (board.width - 2 * AppDimensions.paddingS) / state().grid.size;
    Offset centerOf(GridPoint point) =>
        board.topLeft +
        Offset(
          AppDimensions.paddingS + (point.col + 0.5) * cellSize,
          AppDimensions.paddingS + (point.row + 0.5) * cellSize,
        );

    // Act
    await tester.tapAt(centerOf(word.cells.first));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tapAt(centerOf(word.cells.last));
    await tester.pump(const Duration(milliseconds: 300));

    // Assert
    expect(state().found, isEmpty);
  });
}
