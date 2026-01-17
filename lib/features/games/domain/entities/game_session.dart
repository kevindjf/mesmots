/// Game session state (temporary state during gameplay)
class GameSession {
  /// Remaining words in the pool
  final List<String> pool;

  /// Success count per word (key: word, value: count)
  final Map<String, int> successCount;

  /// Consecutive errors per word (key: word, value: count)
  final Map<String, int> consecutiveErrors;

  /// Validated words (2 successes achieved)
  final Set<String> validated;

  /// Total number of words at start
  final int totalWords;

  /// Total number of cards presented (tracks all attempts)
  final int cardsPresented;

  /// Total cards to present (totalWords * 2, since each needs 2 successes)
  final int totalCards;

  const GameSession({
    required this.pool,
    required this.successCount,
    required this.consecutiveErrors,
    required this.validated,
    required this.totalWords,
    required this.cardsPresented,
    required this.totalCards,
  });

  /// Create initial game session from word list
  factory GameSession.initial(List<String> words) {
    return GameSession(
      pool: List.from(words)..shuffle(),
      successCount: {},
      consecutiveErrors: {},
      validated: {},
      totalWords: words.length,
      cardsPresented: 0,
      totalCards: words.length * 2, // Each word needs 2 successes
    );
  }

  /// Get current word to play
  String? get currentWord => pool.isNotEmpty ? pool.first : null;

  /// Check if session is complete
  bool get isComplete => pool.isEmpty;

  /// Get progress as percentage (0.0 to 1.0) based on cards presented
  double get progress {
    if (totalCards == 0) return 0.0;
    return (cardsPresented / totalCards).clamp(0.0, 1.0);
  }

  /// Get progress as integer percentage (0-100)
  int get progressInt => (progress * 100).round();

  /// Get remaining words count
  int get remainingCount => pool.length;

  /// Get validated words count
  int get validatedCount => validated.length;

  /// Record answer for current word
  GameSession answer(bool correct) {
    final word = currentWord;
    if (word == null) return this;

    final newSuccessCount = Map<String, int>.from(successCount);
    final newConsecutiveErrors = Map<String, int>.from(consecutiveErrors);
    final newValidated = Set<String>.from(validated);
    final newPool = List<String>.from(pool);

    // Increment cards presented counter (for progress bar)
    final newCardsPresented = cardsPresented + 1;

    if (correct) {
      // Increment success count
      newSuccessCount[word] = (newSuccessCount[word] ?? 0) + 1;

      // Reset consecutive errors
      newConsecutiveErrors[word] = 0;

      // Check if word is validated (2 successes)
      if (newSuccessCount[word]! >= 2) {
        newValidated.add(word);
        // Remove from pool permanently
        newPool.remove(word);
      } else {
        // Move to end of pool for later retry
        newPool.remove(word);
        newPool.add(word);
      }
    } else {
      // Increment consecutive errors
      newConsecutiveErrors[word] = (newConsecutiveErrors[word] ?? 0) + 1;

      // Check if need to reset success count (2 consecutive errors)
      if (newConsecutiveErrors[word]! >= 2) {
        newSuccessCount[word] = 0;
      }

      // Move to end of pool for retry
      newPool.remove(word);
      newPool.add(word);
    }

    return GameSession(
      pool: newPool,
      successCount: newSuccessCount,
      consecutiveErrors: newConsecutiveErrors,
      validated: newValidated,
      totalWords: totalWords,
      cardsPresented: newCardsPresented,
      totalCards: totalCards,
    );
  }

  /// Get success count for a word
  int getSuccessCount(String word) => successCount[word] ?? 0;

  /// Get consecutive errors for a word
  int getConsecutiveErrors(String word) => consecutiveErrors[word] ?? 0;

  /// Check if a word is validated
  bool isWordValidated(String word) => validated.contains(word);

  /// Get stars for current word (0, 1, or 2)
  int get currentWordStars {
    final word = currentWord;
    if (word == null) return 0;
    return (successCount[word] ?? 0).clamp(0, 2);
  }

  GameSession copyWith({
    List<String>? pool,
    Map<String, int>? successCount,
    Map<String, int>? consecutiveErrors,
    Set<String>? validated,
    int? totalWords,
    int? cardsPresented,
    int? totalCards,
  }) {
    return GameSession(
      pool: pool ?? this.pool,
      successCount: successCount ?? this.successCount,
      consecutiveErrors: consecutiveErrors ?? this.consecutiveErrors,
      validated: validated ?? this.validated,
      totalWords: totalWords ?? this.totalWords,
      cardsPresented: cardsPresented ?? this.cardsPresented,
      totalCards: totalCards ?? this.totalCards,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameSession &&
          runtimeType == other.runtimeType &&
          pool == other.pool &&
          successCount == other.successCount &&
          consecutiveErrors == other.consecutiveErrors &&
          validated == other.validated &&
          totalWords == other.totalWords &&
          cardsPresented == other.cardsPresented &&
          totalCards == other.totalCards;

  @override
  int get hashCode =>
      pool.hashCode ^
      successCount.hashCode ^
      consecutiveErrors.hashCode ^
      validated.hashCode ^
      totalWords.hashCode ^
      cardsPresented.hashCode ^
      totalCards.hashCode;

  @override
  String toString() =>
      'GameSession(validated: $validatedCount/$totalWords, remaining: $remainingCount)';
}
