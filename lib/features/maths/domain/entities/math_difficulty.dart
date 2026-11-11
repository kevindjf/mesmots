/// Difficulty levels for math games, mapped to French school grades.
enum MathDifficulty {
  ce1(
    displayName: 'CE1',
    maxOperand: 20,
    allowedOperations: [MathOperationType.addition, MathOperationType.subtraction],
  ),
  ce2(
    displayName: 'CE2',
    maxOperand: 100,
    allowedOperations: [MathOperationType.addition, MathOperationType.subtraction, MathOperationType.multiplication],
  ),
  cm1(
    displayName: 'CM1',
    maxOperand: 500,
    allowedOperations: [MathOperationType.addition, MathOperationType.subtraction, MathOperationType.multiplication, MathOperationType.division],
  ),
  cm2(
    displayName: 'CM2',
    maxOperand: 1000,
    allowedOperations: [MathOperationType.addition, MathOperationType.subtraction, MathOperationType.multiplication, MathOperationType.division],
  );

  final String displayName;
  final int maxOperand;
  final List<MathOperationType> allowedOperations;

  const MathDifficulty({
    required this.displayName,
    required this.maxOperand,
    required this.allowedOperations,
  });
}

/// Needed here to avoid circular import with math_operation.dart
enum MathOperationType { addition, subtraction, multiplication, division }
