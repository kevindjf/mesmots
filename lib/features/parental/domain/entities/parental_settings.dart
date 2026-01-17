/// Parental control settings
class ParentalSettings {
  /// Hashed PIN code (SHA-256)
  final String? pinHash;

  /// Recovery question
  final String? recoveryQuestion;

  /// Hashed recovery answer (SHA-256)
  final String? recoveryAnswerHash;

  /// Whether PIN is configured
  final bool isPinConfigured;

  const ParentalSettings({
    this.pinHash,
    this.recoveryQuestion,
    this.recoveryAnswerHash,
    required this.isPinConfigured,
  });

  /// Create initial settings (no PIN configured)
  factory ParentalSettings.initial() {
    return const ParentalSettings(
      pinHash: null,
      recoveryQuestion: null,
      recoveryAnswerHash: null,
      isPinConfigured: false,
    );
  }

  /// Configure PIN with optional recovery
  ParentalSettings configure({
    required String pinHash,
    String? recoveryQuestion,
    String? recoveryAnswerHash,
  }) {
    return ParentalSettings(
      pinHash: pinHash,
      recoveryQuestion: recoveryQuestion,
      recoveryAnswerHash: recoveryAnswerHash,
      isPinConfigured: true,
    );
  }

  /// Update PIN
  ParentalSettings updatePin(String newPinHash) {
    return copyWith(pinHash: newPinHash);
  }

  /// Update recovery question and answer
  ParentalSettings updateRecovery({
    required String newRecoveryQuestion,
    required String newRecoveryAnswerHash,
  }) {
    return copyWith(
      recoveryQuestion: newRecoveryQuestion,
      recoveryAnswerHash: newRecoveryAnswerHash,
    );
  }

  /// Reset PIN (clear all settings)
  ParentalSettings reset() {
    return ParentalSettings.initial();
  }

  ParentalSettings copyWith({
    String? pinHash,
    String? recoveryQuestion,
    String? recoveryAnswerHash,
    bool? isPinConfigured,
  }) {
    return ParentalSettings(
      pinHash: pinHash ?? this.pinHash,
      recoveryQuestion: recoveryQuestion ?? this.recoveryQuestion,
      recoveryAnswerHash: recoveryAnswerHash ?? this.recoveryAnswerHash,
      isPinConfigured: isPinConfigured ?? this.isPinConfigured,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParentalSettings &&
          runtimeType == other.runtimeType &&
          pinHash == other.pinHash &&
          recoveryQuestion == other.recoveryQuestion &&
          recoveryAnswerHash == other.recoveryAnswerHash &&
          isPinConfigured == other.isPinConfigured;

  @override
  int get hashCode =>
      pinHash.hashCode ^
      recoveryQuestion.hashCode ^
      recoveryAnswerHash.hashCode ^
      isPinConfigured.hashCode;

  @override
  String toString() =>
      'ParentalSettings(configured: $isPinConfigured, hasRecovery: ${recoveryQuestion != null})';
}
