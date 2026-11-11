import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/features/games/domain/entities/crossword.dart';
import 'package:mesmots/features/games/domain/entities/grid_point.dart';
import 'package:mesmots/features/games/domain/usecases/generate_crossword.dart';

void main() {
  const weekWords = [
    'maison',
    'école',
    'chat',
    'jardin',
    'fenêtre',
    'cœur',
    'garçon',
    'matin',
  ];

  /// Every placed word reads back from the solution, words never touch
  /// side by side, and crossings share the same letter.
  void expectConsistent(Crossword crossword) {
    final owners = <GridPoint, int>{};
    for (final entry in crossword.entries) {
      final cells = entry.cells;
      for (var i = 0; i < cells.length; i++) {
        expect(crossword.solution[cells[i]], entry.letters[i]);
        owners[cells[i]] = (owners[cells[i]] ?? 0) + 1;
      }
      // Cells right before and after a word stay empty
      final dir = entry.direction;
      final before = GridPoint(
        cells.first.row - dir.rowStep,
        cells.first.col - dir.colStep,
      );
      final after = GridPoint(
        cells.last.row + dir.rowStep,
        cells.last.col + dir.colStep,
      );
      expect(crossword.isCell(before), isFalse, reason: entry.word);
      expect(crossword.isCell(after), isFalse, reason: entry.word);
    }
    expect(owners.values.every((count) => count <= 2), isTrue);
    for (final point in crossword.solution.keys) {
      expect(point.row, inInclusiveRange(0, crossword.rows - 1));
      expect(point.col, inInclusiveRange(0, crossword.cols - 1));
    }
  }

  group('GenerateCrossword', () {
    test('builds a consistent, playable grid for a typical week', () {
      for (var seed = 0; seed < 30; seed++) {
        // Arrange
        final generate = GenerateCrossword(random: Random(seed));

        // Act
        final crossword = generate(weekWords);

        // Assert
        expect(crossword.isPlayable, isTrue, reason: 'seed $seed');
        expect(crossword.entries.length, greaterThanOrEqualTo(6));
        expect(crossword.rows, lessThanOrEqualTo(GenerateCrossword.maxDimension));
        expect(crossword.cols, lessThanOrEqualTo(GenerateCrossword.maxDimension));
        expectConsistent(crossword);
      }
    });

    test('every word gets its first letter, and Œ is always given', () {
      // Arrange
      final generate = GenerateCrossword(random: Random(4));

      // Act
      final crossword = generate(weekWords);

      // Assert
      for (final entry in crossword.entries) {
        expect(crossword.prefilled, contains(entry.cells.first));
        expect(
          entry.cells.every(crossword.prefilled.contains),
          isFalse,
          reason: '${entry.word} must keep letters to find',
        );
      }
      final heart = crossword.entries.where((e) => e.word == 'cœur');
      if (heart.isNotEmpty) {
        expect(crossword.prefilled, contains(heart.first.cells[1]));
      }
    });

    test('numbers follow reading order and are shared by a common start', () {
      // Arrange
      final crossword = GenerateCrossword(random: Random(9))(weekWords);

      // Act
      final byNumber = <int, GridPoint>{
        for (final e in crossword.entries) e.number: e.cells.first,
      };
      final numbers = byNumber.keys.toList()..sort();

      // Assert
      expect(numbers.first, 1);
      for (var i = 1; i < numbers.length; i++) {
        final a = byNumber[numbers[i - 1]]!;
        final b = byNumber[numbers[i]]!;
        expect(a.row < b.row || (a.row == b.row && a.col < b.col), isTrue);
      }
    });

    test('words without common letters make the grid unplayable', () {
      // Arrange
      final generate = GenerateCrossword(random: Random(1));

      // Act
      final crossword = generate(['bus', 'chat', 'pot']);

      // Assert
      expect(crossword.isPlayable, isFalse);
    });

    test('empty or too short lists give an empty crossword', () {
      // Act
      final crossword = GenerateCrossword()(['a']);

      // Assert
      expect(crossword.entries, isEmpty);
      expect(crossword.isPlayable, isFalse);
    });
  });
}
