import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/features/word_lists/domain/entities/game_type.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_list.dart';

void main() {
  WordList buildList() =>
      WordList.create(id: '1', name: 'Semaine 1', words: ['chat', 'été']);

  group('WordList.recordAttempt', () {
    test('success increases word mastery', () {
      // Arrange
      final list = buildList();

      // Act
      final updated = list.recordAttempt('chat', success: true);

      // Assert
      expect(updated.statusOf('chat').successCount, 1);
      expect(updated.statusOf('été').successCount, 0);
    });

    test('errors never remove stars', () {
      // Arrange
      final list = buildList()
          .recordAttempt('chat', success: true)
          .recordAttempt('chat', success: true);

      // Act
      final updated = list
          .recordAttempt('chat', success: false)
          .recordAttempt('chat', success: false);

      // Assert
      expect(updated.statusOf('chat').stars, 2);
      expect(updated.statusOf('chat').needsPractice, isTrue);
    });

    test('word is mastered after 3 successes from any game', () {
      // Arrange
      var list = buildList();

      // Act
      for (var i = 0; i < 3; i++) {
        list = list.recordAttempt('été', success: true);
      }

      // Assert
      expect(list.statusOf('été').isMastered, isTrue);
      expect(list.masteredCount, 1);
      expect(list.masteryRatio, 0.5);
    });

    test('unknown word is ignored', () {
      // Arrange
      final list = buildList();

      // Act
      final updated = list.recordAttempt('chien', success: true);

      // Assert
      expect(updated.mastery.containsKey('chien'), isFalse);
    });
  });

  group('WordList.recordGamePlayed', () {
    test('increments play count of the game only', () {
      // Arrange
      final list = buildList();

      // Act
      final updated = list
          .recordGamePlayed(GameType.writing)
          .recordGamePlayed(GameType.writing);

      // Assert
      expect(updated.playCountOf(GameType.writing), 2);
      expect(updated.playCountOf(GameType.qcm), 0);
    });
  });

  group('WordList.updateWords', () {
    test('keeps mastery of remaining words and drops removed ones', () {
      // Arrange
      final list = buildList().recordAttempt('chat', success: true);

      // Act
      final updated = list.updateWords(['chat', 'maison']);

      // Assert
      expect(updated.statusOf('chat').successCount, 1);
      expect(updated.statusOf('maison').successCount, 0);
      expect(updated.mastery.containsKey('été'), isFalse);
    });
  });

  group('enabled games', () {
    test('a new list allows every game', () {
      // Arrange & Act
      final list = WordList.create(id: '1', name: 'S1', words: ['chat']);

      // Assert
      expect(list.availableGames, GameType.values);
    });

    test('updateEnabledGames keeps display order', () {
      // Arrange
      final list = WordList.create(id: '1', name: 'S1', words: ['chat']);

      // Act
      final updated =
          list.updateEnabledGames({GameType.crossword, GameType.qcm});

      // Assert
      expect(updated.availableGames, [GameType.qcm, GameType.crossword]);
      expect(updated.isGameEnabled(GameType.writing), isFalse);
    });

    test('updateEnabledGames refuses an empty selection', () {
      // Arrange
      final list = WordList.create(id: '1', name: 'S1', words: ['chat']);

      // Act & Assert
      expect(() => list.updateEnabledGames({}), throwsArgumentError);
    });
  });

  group('WordList.lastPlayedAt', () {
    test('a new list has never been played', () {
      // Act
      final list = WordList.create(id: '1', name: 'S1', words: const ['chat']);

      // Assert
      expect(list.lastPlayedAt, isNull);
    });

    test('an attempt or a finished game marks the list as played', () {
      // Arrange
      final list = WordList.create(id: '1', name: 'S1', words: const ['chat']);

      // Act & Assert
      expect(list.recordAttempt('chat', success: true).lastPlayedAt, isNotNull);
      expect(list.recordGamePlayed(GameType.qcm).lastPlayedAt, isNotNull);
    });

    test('editing the list does not count as playing', () {
      // Arrange
      final list = WordList.create(id: '1', name: 'S1', words: const ['chat']);

      // Act
      final edited = list.updateName('S2').updateWords(
          const ['chat', 'chien']).updateEnabledGames({GameType.qcm});

      // Assert
      expect(edited.lastPlayedAt, isNull);
    });
  });
}
