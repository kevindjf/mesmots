/// Global mastery of a word, fed by every game.
///
/// Mastery only grows: errors never remove stars, to avoid frustration.
class WordStatus {
  /// Successes needed to consider a word mastered
  static const int masteryThreshold = 3;

  /// Total number of successful attempts across all games
  final int successCount;

  /// Number of consecutive errors (resets on success)
  final int consecutiveErrors;

  const WordStatus({
    required this.successCount,
    required this.consecutiveErrors,
  });

  /// Create initial word status
  factory WordStatus.initial() {
    return const WordStatus(successCount: 0, consecutiveErrors: 0);
  }

  /// Whether the word is mastered
  bool get isMastered => successCount >= masteryThreshold;

  /// Whether the word deserves extra practice
  bool get needsPractice => consecutiveErrors >= 2;

  /// Stars to display (0 to [masteryThreshold])
  int get stars => successCount.clamp(0, masteryThreshold);

  /// Record a successful attempt
  WordStatus recordSuccess() {
    return WordStatus(successCount: successCount + 1, consecutiveErrors: 0);
  }

  /// Record a failed attempt
  WordStatus recordError() {
    return WordStatus(
      successCount: successCount,
      consecutiveErrors: consecutiveErrors + 1,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WordStatus &&
          successCount == other.successCount &&
          consecutiveErrors == other.consecutiveErrors;

  @override
  int get hashCode => Object.hash(successCount, consecutiveErrors);

  @override
  String toString() =>
      'WordStatus(success: $successCount, errors: $consecutiveErrors)';
}
