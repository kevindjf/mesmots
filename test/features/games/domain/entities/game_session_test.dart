import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/features/games/domain/entities/game_session.dart';

void main() {
  test('never asks the same word twice in a row', () {
    for (var run = 0; run < 200; run++) {
      // Arrange
      var session = GameSession.initial(const ['a', 'b', 'c']);
      final word = session.currentWord;

      // Act
      session = session.answer(run.isEven);

      // Assert
      expect(session.currentWord, isNot(word));
    }
  });

  test('a word needs two successes to leave the game', () {
    // Arrange
    var session = GameSession.initial(const ['a']);

    // Act
    session = session.answer(true);
    final afterOne = session.isComplete;
    session = session.answer(true);

    // Assert
    expect(afterOne, isFalse);
    expect(session.isComplete, isTrue);
  });
}
