import 'package:mesmots/features/word_lists/domain/entities/word_status.dart';

/// Progress for a specific game level
class LevelProgress {
  /// Progress status for each word (key: word, value: status)
  final Map<String, WordStatus> wordStatuses;

  /// Whether this level is fully completed (100%)
  final bool isCompleted;

  /// Timestamp when the level was completed
  final DateTime? completedAt;

  const LevelProgress({
    required this.wordStatuses,
    required this.isCompleted,
    this.completedAt,
  });

  /// Create initial progress for a list of words
  factory LevelProgress.initial(List<String> words) {
    return LevelProgress(
      wordStatuses: {
        for (final word in words) word: WordStatus.initial(),
      },
      isCompleted: false,
      completedAt: null,
    );
  }

  /// Get completion percentage (0.0 to 1.0)
  double get percentage {
    if (wordStatuses.isEmpty) return 0.0;

    final validatedCount =
        wordStatuses.values.where((status) => status.isValidated).length;

    return validatedCount / wordStatuses.length;
  }

  /// Get completion percentage as integer (0 to 100)
  int get percentageInt => (percentage * 100).round();

  /// Check if level is unlocked (>= 75% completion or already played)
  bool get isUnlocked => percentage >= 0.75 || hasStarted;

  /// Check if level has been started (any word has progress)
  bool get hasStarted {
    return wordStatuses.values.any(
      (status) => status.successCount > 0 || status.consecutiveErrors > 0,
    );
  }

  /// Get number of validated words
  int get validatedCount =>
      wordStatuses.values.where((status) => status.isValidated).length;

  /// Get total number of words
  int get totalWords => wordStatuses.length;

  /// Update word status after an attempt
  LevelProgress updateWordStatus(String word, bool success) {
    if (!wordStatuses.containsKey(word)) {
      return this;
    }

    final currentStatus = wordStatuses[word]!;
    final newStatus =
        success ? currentStatus.recordSuccess() : currentStatus.recordError();

    final newWordStatuses = Map<String, WordStatus>.from(wordStatuses);
    newWordStatuses[word] = newStatus;

    final allValidated =
        newWordStatuses.values.every((status) => status.isValidated);

    return LevelProgress(
      wordStatuses: newWordStatuses,
      isCompleted: allValidated,
      completedAt: allValidated && !isCompleted ? DateTime.now() : completedAt,
    );
  }

  /// Add new words to the level
  LevelProgress addWords(List<String> newWords) {
    final updatedStatuses = Map<String, WordStatus>.from(wordStatuses);

    for (final word in newWords) {
      if (!updatedStatuses.containsKey(word)) {
        updatedStatuses[word] = WordStatus.initial();
      }
    }

    return LevelProgress(
      wordStatuses: updatedStatuses,
      isCompleted: false, // Reset completion when adding words
      completedAt: null,
    );
  }

  /// Remove words from the level
  LevelProgress removeWords(List<String> wordsToRemove) {
    final updatedStatuses = Map<String, WordStatus>.from(wordStatuses);

    for (final word in wordsToRemove) {
      updatedStatuses.remove(word);
    }

    final allValidated =
        updatedStatuses.values.every((status) => status.isValidated);

    return LevelProgress(
      wordStatuses: updatedStatuses,
      isCompleted: allValidated,
      completedAt: allValidated ? DateTime.now() : null,
    );
  }

  /// Reset all progress
  LevelProgress reset() {
    return LevelProgress(
      wordStatuses: {
        for (final word in wordStatuses.keys) word: WordStatus.initial(),
      },
      isCompleted: false,
      completedAt: null,
    );
  }

  LevelProgress copyWith({
    Map<String, WordStatus>? wordStatuses,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return LevelProgress(
      wordStatuses: wordStatuses ?? this.wordStatuses,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LevelProgress &&
          runtimeType == other.runtimeType &&
          wordStatuses == other.wordStatuses &&
          isCompleted == other.isCompleted &&
          completedAt == other.completedAt;

  @override
  int get hashCode =>
      wordStatuses.hashCode ^ isCompleted.hashCode ^ completedAt.hashCode;

  @override
  String toString() =>
      'LevelProgress(validated: $validatedCount/$totalWords, ${percentageInt}%, completed: $isCompleted)';
}
