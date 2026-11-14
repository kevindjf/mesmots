import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/core/theme/app_palette.dart';
import 'package:mesmots/core/theme/app_theme.dart';
import 'package:mesmots/features/games/presentation/screens/crossword_game_screen.dart';
import 'package:mesmots/features/games/presentation/widgets/crossword_board.dart';
import 'package:mesmots/shared/widgets/child_keyboard.dart';

import '../../../../goldens/golden_harness.dart';

/// Words that cross into a playable grid.
final _list = goldenList(
  id: 'crossword',
  words: const ['maison', 'école', 'jardin', 'chapeau', 'bateau', 'oiseau'],
);

void main() {
  Future<(Rect, Rect)> boardAndKeyboardOn(
    WidgetTester tester,
    Size size,
  ) async {
    await pumpGoldenScreen(
      tester,
      CrosswordGameScreen(listId: _list.id),
      theme: AppTheme.of(AppPalette.light),
      overrides: goldenOverrides([_list]),
      size: size,
    );
    return (
      tester.getRect(find.byType(CrosswordBoard)),
      tester.getRect(find.byType(ChildKeyboard)),
    );
  }

  testWidgets('puts the keyboard under the grid on a phone', (tester) async {
    // Arrange
    const phone = Size(390, 844);

    // Act
    final (board, keyboard) = await boardAndKeyboardOn(tester, phone);

    // Assert
    expect(keyboard.top, greaterThanOrEqualTo(board.bottom));
  });

  testWidgets('puts the keyboard next to the grid on a tablet held sideways',
      (tester) async {
    // Arrange
    const tablet = Size(1280, 800);

    // Act
    final (board, keyboard) = await boardAndKeyboardOn(tester, tablet);

    // Assert
    expect(keyboard.left, greaterThanOrEqualTo(board.right));
    expect(keyboard.bottom, lessThanOrEqualTo(tablet.height));
  });
}
