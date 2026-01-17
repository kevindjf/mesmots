/// Status of a word within a specific game level
class WordStatus {
  /// Number of successful attempts (0, 1, or 2+)
  final int successCount;

  /// Number of consecutive errors (resets on success)
  final int consecutiveErrors;

  /// Whether the word is validated (successCount >= 2)
  final bool isValidated;

  const WordStatus({
    required this.successCount,
    required this.consecutiveErrors,
    required this.isValidated,
  });

  /// Create initial word status
  factory WordStatus.initial() {
    return const WordStatus(
      successCount: 0,
      consecutiveErrors: 0,
      isValidated: false,
    );
  }

  /// Record a successful attempt
  WordStatus recordSuccess() {
    final newSuccessCount = successCount + 1;
    return WordStatus(
      successCount: newSuccessCount,
      consecutiveErrors: 0, // Reset consecutive errors on success
      isValidated: newSuccessCount >= 2,
    );
  }

  /// Record a failed attempt
  WordStatus recordError() {
    final newConsecutiveErrors = consecutiveErrors + 1;

    // Reset success count after 2 consecutive errors
    final newSuccessCount = newConsecutiveErrors >= 2 ? 0 : successCount;

    return WordStatus(
      successCount: newSuccessCount,
      consecutiveErrors: newConsecutiveErrors,
      isValidated: false,
    );
  }

  /// Get progress stars (0, 1, or 2)
  int get stars => successCount.clamp(0, 2);

  WordStatus copyWith({
    int? successCount,
    int? consecutiveErrors,
    bool? isValidated,
  }) {
    return WordStatus(
      successCount: successCount ?? this.successCount,
      consecutiveErrors: consecutiveErrors ?? this.consecutiveErrors,
      isValidated: isValidated ?? this.isValidated,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WordStatus &&
          runtimeType == other.runtimeType &&
          successCount == other.successCount &&
          consecutiveErrors == other.consecutiveErrors &&
          isValidated == other.isValidated;

  @override
  int get hashCode =>
      successCount.hashCode ^
      consecutiveErrors.hashCode ^
      isValidated.hashCode;

  @override
  String toString() =>
      'WordStatus(success: $successCount, errors: $consecutiveErrors, validated: $isValidated)';
}
