import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/features/games/domain/entities/word_search_grid.dart';
import 'package:mesmots/features/games/domain/usecases/generate_word_search.dart';

void main() {
  String readWord(WordSearchGrid grid, int index) =>
      grid.words[index].cells.map(grid.letterAt).join();

  group('GenerateWordSearch', () {
    const words = [
      'chat',
      'école',
      'maison',
      'été',
      'garçon',
      'aujourd\'hui',
      'grand-mère',
      'fenêtre',
    ];

    test('places every word and each one reads back from the grid', () {
      for (var seed = 0; seed < 50; seed++) {
        // Arrange
        final generate = GenerateWordSearch(random: Random(seed));

        // Act
        final grid = generate(words);

        // Assert
        expect(grid.words.length, words.length, reason: 'seed $seed');
        for (var i = 0; i < grid.words.length; i++) {
          expect(readWord(grid, i), grid.words[i].letters.join());
        }
      }
    });

    test('keeps accents and drops separators', () {
      // Arrange
      final generate = GenerateWordSearch(random: Random(1));

      // Act
      final grid = generate(['garçon', 'grand-mère', 'aujourd\'hui']);

      // Assert
      final letters = {for (final w in grid.words) w.word: w.letters.join()};
      expect(letters['garçon'], 'GARÇON');
      expect(letters['grand-mère'], 'GRANDMÈRE');
      expect(letters['aujourd\'hui'], 'AUJOURDHUI');
    });

    test('grid is square and stays within bounds', () {
      // Arrange
      final generate = GenerateWordSearch(random: Random(7));

      // Act
      final grid = generate(words);

      // Assert
      expect(grid.size, inInclusiveRange(
        GenerateWordSearch.minSize,
        GenerateWordSearch.maxSize,
      ));
      expect(grid.letters.length, grid.size);
      expect(grid.letters.every((row) => row.length == grid.size), isTrue);
      expect(grid.letters.expand((r) => r).every((c) => c.isNotEmpty), isTrue);
    });

    test('a word longer than the max size enlarges the grid', () {
      // Arrange
      final generate = GenerateWordSearch(random: Random(3));

      // Act
      final grid = generate(['anticonstitutionnel']);

      // Assert
      expect(grid.size, 'anticonstitutionnel'.length);
      expect(grid.words, hasLength(1));
    });

    test('finds a word from a reversed selection', () {
      // Arrange
      final grid = GenerateWordSearch(random: Random(5))(['chat', 'école']);
      final cells = grid.words.first.cells;

      // Act
      final forward = grid.wordIndexFor(cells);
      final backward = grid.wordIndexFor(cells.reversed.toList());
      final partial = grid.wordIndexFor(cells.sublist(1));

      // Assert
      expect(forward, 0);
      expect(backward, 0);
      expect(partial, isNull);
    });

    test('ignores duplicates and one-letter words', () {
      // Arrange
      final generate = GenerateWordSearch(random: Random(2));

      // Act
      final grid = generate(['chat', 'chat', 'a']);

      // Assert
      expect(grid.words.map((w) => w.word), ['chat']);
    });
  });
}
