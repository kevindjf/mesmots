import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/features/word_lists/data/models/word_list_model.dart';
import 'package:mesmots/features/word_lists/domain/entities/game_type.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_list.dart';

void main() {
  test('entity survives a round trip through the Hive model', () {
    // Arrange
    final entity = WordList.create(id: '1', name: 'S1', words: ['chat', 'été'])
        .recordAttempt('été', success: true)
        .recordAttempt('chat', success: false)
        .recordGamePlayed(GameType.scramble);

    // Act
    final restored = WordListModel.fromEntity(entity).toEntity();

    // Assert
    expect(restored.words, entity.words);
    expect(restored.statusOf('été').successCount, 1);
    expect(restored.statusOf('chat').consecutiveErrors, 1);
    expect(restored.playCountOf(GameType.scramble), 1);
  });

  test('legacy record without mastery fields starts fresh', () {
    // Arrange
    final model = WordListModel()
      ..uuid = 'old'
      ..name = 'Ancienne liste'
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026)
      ..words = ['chat'];

    // Act
    final entity = model.toEntity();

    // Assert
    expect(entity.statusOf('chat').successCount, 0);
    expect(entity.playCount, isEmpty);
  });

  test('enabled games survive a round trip', () {
    // Arrange
    final entity = WordList.create(id: '1', name: 'S1', words: ['chat'])
        .updateEnabledGames({GameType.qcm, GameType.wordSearch});

    // Act
    final restored = WordListModel.fromEntity(entity).toEntity();

    // Assert
    expect(restored.enabledGames, {GameType.qcm, GameType.wordSearch});
  });

  test('record without enabled games allows every game', () {
    // Arrange
    final model = WordListModel()
      ..uuid = 'old'
      ..name = 'Ancienne liste'
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026)
      ..words = ['chat'];

    // Act
    final entity = model.toEntity();

    // Assert
    expect(entity.enabledGames, WordList.allGames);
  });
}
