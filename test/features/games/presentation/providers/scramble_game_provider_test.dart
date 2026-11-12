import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/features/games/presentation/providers/scramble_game_provider.dart';

void main() {
  test('every letter is to place, tiles are the letters shuffled', () {
    // Act
    final puzzle = scramblePuzzle('maison');

    // Assert
    expect(puzzle.blanks, [0, 1, 2, 3, 4, 5]);
    expect([...puzzle.tiles]..sort(), ['a', 'i', 'm', 'n', 'o', 's']);
    expect(puzzle.tiles.join(), isNot('maison'));
  });

  test('spaces and hyphens of compound words stay given', () {
    // Act
    final puzzle = scramblePuzzle('arc-en-ciel');

    // Assert
    expect(puzzle.blanks, isNot(contains(3)));
    expect(puzzle.tiles, isNot(contains('-')));
    expect(puzzle.tiles.length, 9);
  });
}
