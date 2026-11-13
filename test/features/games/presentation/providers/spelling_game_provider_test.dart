import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/features/games/presentation/providers/spelling_game_provider.dart';

void main() {
  test('every letter is to place, with a few decoys among the tiles', () {
    // Act
    final puzzle = spellingPuzzle('sept');

    // Assert
    expect(puzzle.blanks, [0, 1, 2, 3]);
    expect(puzzle.tiles, containsAll(['s', 'e', 'p', 't']));
    expect(puzzle.tiles.length, greaterThan(4));
  });

  test('spaces and hyphens of compound words stay given', () {
    // Act
    final puzzle = spellingPuzzle('arc-en-ciel');

    // Assert
    expect(puzzle.blanks, isNot(contains(3)));
    expect(puzzle.tiles, isNot(contains('-')));
  });
}
