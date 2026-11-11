import 'package:mesmots/features/word_lists/domain/entities/game_level.dart';
import 'package:mesmots/features/word_lists/domain/entities/level_progress.dart';

/// Word list entity
class WordList {
  /// Unique identifier
  final String id;

  /// List name
  final String name;

  /// Creation timestamp
  final DateTime createdAt;

  /// Last update timestamp
  final DateTime updatedAt;

  /// List of words
  final List<String> words;

  /// Progress for each game level
  final Map<GameLevel, LevelProgress> progress;

  const WordList({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.words,
    required this.progress,
  });

  /// Create a new word list
  factory WordList.create({
    required String id,
    required String name,
    required List<String> words,
  }) {
    final now = DateTime.now();
    return WordList(
      id: id,
      name: name,
      createdAt: now,
      updatedAt: now,
      words: words,
      progress: {
        for (final level in GameLevel.values)
          level: LevelProgress.initial(words),
      },
    );
  }

  /// Get overall completion percentage across all levels
  double get overallPercentage {
    if (progress.isEmpty) return 0.0;

    final total =
        progress.values.map((p) => p.percentage).reduce((a, b) => a + b);

    return total / progress.length;
  }

  /// Get overall completion percentage as integer (0-100)
  int get overallPercentageInt => (overallPercentage * 100).round();

  /// Check if all levels are completed
  bool get isFullyCompleted {
    return progress.values.every((p) => p.isCompleted);
  }

  /// Get the current/next level to play
  GameLevel get currentLevel {
    // Find the first level that is not completed
    for (final level in GameLevel.values) {
      final levelProgress = progress[level];
      if (levelProgress == null || !levelProgress.isCompleted) {
        return level;
      }
    }

    // If all completed, return the last level
    return GameLevel.writing;
  }

  /// Check if a level is unlocked
  bool isLevelUnlocked(GameLevel level) {
    // Level 1 is always unlocked
    if (level == GameLevel.qcm) return true;

    // Check if previous level has >= 75% completion
    final previousLevel = level.previous;
    if (previousLevel == null) return true;

    final previousProgress = progress[previousLevel];
    if (previousProgress == null) return false;

    return previousProgress.isUnlocked;
  }

  /// Update word list name
  WordList updateName(String newName) {
    return copyWith(
      name: newName,
      updatedAt: DateTime.now(),
    );
  }

  /// Update words in the list
  WordList updateWords(List<String> newWords) {
    final now = DateTime.now();

    // Update progress for all levels with new words
    final updatedProgress = <GameLevel, LevelProgress>{};
    for (final entry in progress.entries) {
      updatedProgress[entry.key] = _updateLevelProgressWithWords(
        entry.value,
        words,
        newWords,
      );
    }

    return copyWith(
      words: newWords,
      updatedAt: now,
      progress: updatedProgress,
    );
  }

  /// Helper to update level progress when words change
  LevelProgress _updateLevelProgressWithWords(
    LevelProgress current,
    List<String> oldWords,
    List<String> newWords,
  ) {
    // Find added and removed words
    final addedWords = newWords.where((w) => !oldWords.contains(w)).toList();
    final removedWords = oldWords.where((w) => !newWords.contains(w)).toList();

    var updated = current;

    // Add new words
    if (addedWords.isNotEmpty) {
      updated = updated.addWords(addedWords);
    }

    // Remove old words
    if (removedWords.isNotEmpty) {
      updated = updated.removeWords(removedWords);
    }

    return updated;
  }

  /// Update progress for a specific level and word
  WordList updateProgress(GameLevel level, String word, bool success) {
    final levelProgress = progress[level];
    if (levelProgress == null) return this;

    final updatedLevelProgress = levelProgress.updateWordStatus(word, success);

    final updatedProgress = Map<GameLevel, LevelProgress>.from(progress);
    updatedProgress[level] = updatedLevelProgress;

    return copyWith(
      progress: updatedProgress,
      updatedAt: DateTime.now(),
    );
  }

  /// Reset progress for a specific level
  WordList resetLevel(GameLevel level) {
    final levelProgress = progress[level];
    if (levelProgress == null) return this;

    final updatedProgress = Map<GameLevel, LevelProgress>.from(progress);
    updatedProgress[level] = levelProgress.reset();

    return copyWith(
      progress: updatedProgress,
      updatedAt: DateTime.now(),
    );
  }

  /// Reset all progress
  WordList resetAllProgress() {
    final updatedProgress = <GameLevel, LevelProgress>{};
    for (final level in GameLevel.values) {
      updatedProgress[level] = LevelProgress.initial(words);
    }

    return copyWith(
      progress: updatedProgress,
      updatedAt: DateTime.now(),
    );
  }

  WordList copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? words,
    Map<GameLevel, LevelProgress>? progress,
  }) {
    return WordList(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      words: words ?? this.words,
      progress: progress ?? this.progress,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WordList &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          words == other.words &&
          progress == other.progress;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      words.hashCode ^
      progress.hashCode;

  @override
  String toString() => 'WordList(id: $id, name: $name, words: ${words.length})';
}
