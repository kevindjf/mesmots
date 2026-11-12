import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/features/games/domain/entities/letter_puzzle.dart';

void main() {
  // "chat" with blanks on h and t; tiles: h, t, d (decoy)
  LetterPuzzle puzzle() => LetterPuzzle(
      word: 'chat', blanks: const [1, 3], tiles: const ['t', 'h', 'd']);

  test('places tiles in order and takes them back', () {
    // Act
    final p = puzzle().place(1).place(2).remove(0);

    // Assert
    expect(p.letterAt(0), isNull);
    expect(p.letterAt(1), 'd');
    expect(p.isTileUsed(1), isFalse);
  });

  test('a full puzzle is checked as correct or wrong', () {
    // Act
    final right = puzzle().place(1).place(0).checked();
    final wrong = puzzle().place(1).place(2).checked();

    // Assert
    expect(right.phase, PuzzlePhase.correct);
    expect(wrong.phase, PuzzlePhase.wrong);
    expect(wrong.wrongSlots, {1});
  });

  test('retry keeps and locks the right letters', () {
    // Act
    final p = puzzle().place(1).place(2).checked().retry();

    // Assert
    expect(p.phase, PuzzlePhase.playing);
    expect(p.letterAt(0), 'h');
    expect(p.letterAt(1), isNull);
    expect(p.lockedSlots, {0});
    expect(p.remove(0).letterAt(0), 'h', reason: 'locked letters stay');
  });

  test('ignores actions while the result is shown', () {
    // Arrange
    final shown = puzzle().place(1).place(2).checked();

    // Act / Assert
    expect(shown.remove(0).letterAt(0), 'h');
    expect(shown.clear().letterAt(0), 'h');
  });

  test('help places the right letter, taking it back from a wrong slot', () {
    // Arrange: "t" placed in the slot expecting "h"
    final p = puzzle().place(0);

    // Act
    final helped = p.hint();

    // Assert
    expect(helped.letterAt(0), 'h');
    expect(helped.lockedSlots, {0});
  });

  test('removeLast skips locked letters', () {
    // Arrange
    final p = puzzle().hint().place(0);

    // Act
    final once = p.removeLast();
    final twice = once.removeLast();

    // Assert
    expect(once.letterAt(1), isNull);
    expect(twice.letterAt(0), 'h');
  });

  test('spaces and hyphens are never blanks', () {
    // Assert
    expect(LetterPuzzle.isFillable(' '), isFalse);
    expect(LetterPuzzle.isFillable('-'), isFalse);
    expect(LetterPuzzle.isFillable('é'), isTrue);
  });
}
