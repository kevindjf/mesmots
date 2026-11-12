import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/features/games/domain/usecases/generate_blanks.dart';

void main() {
  late GenerateBlanks generate;

  setUp(() => generate = GenerateBlanks(Random(7)));

  const sample = [
    'maison',
    'école',
    'poisson',
    'chat',
    'gâteau',
    'jardin',
    'garçon',
    'chapeau',
    'vélo',
    'bonjour',
    'ami',
    'pomme de terre',
    'arc-en-ciel',
  ];

  test('never hides the first letter, spaces or hyphens', () {
    for (final word in sample) {
      // Act
      final puzzle = generate(word);

      // Assert
      expect(puzzle.blanks, isNotEmpty, reason: word);
      expect(puzzle.blanks, isNot(contains(0)), reason: word);
      for (final b in puzzle.blanks) {
        expect(puzzle.letters[b], isNot(anyOf(' ', '-')), reason: word);
      }
    }
  });

  test('hides the spelling difficulties', () {
    // Act / Assert: the only difficulty of each word is hidden
    expect(generate.blankPositions('vélo'), [1]); // é
    expect(generate.blankPositions('chat'), [3]); // silent t
    expect(generate.blankPositions('hibou'), [3, 4]); // ou
  });

  test('hides whole groups of letters', () {
    // Act
    final maison = generate.blankPositions('maison');

    // Assert: "ai" and "on" are the difficulties
    expect(maison, [1, 2, 4, 5]);
  });

  test('tiles hold the right letters plus decoys children confuse', () {
    // Act
    final puzzle = generate('vélo');

    // Assert
    expect(puzzle.tiles, contains('é'));
    expect(puzzle.tiles.length, 4);
    expect(
      puzzle.tiles.where((t) => t != 'é'),
      everyElement(isIn(['e', 'è', 'ê'])),
    );
  });

  test('every puzzle can be solved with its tiles', () {
    for (final word in sample) {
      // Arrange
      var puzzle = generate(word);

      // Act: help until full
      for (var i = 0; i < puzzle.blanks.length; i++) {
        puzzle = puzzle.hint();
      }

      // Assert
      expect(puzzle.checked().mistakes, isEmpty, reason: word);
    }
  });
}
