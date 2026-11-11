import 'package:jerevise/features/maths/domain/entities/math_difficulty.dart';
import 'package:jerevise/features/maths/domain/entities/math_operation.dart';

class MathQuestion {
  final int id;
  final int operand1;
  final int operand2;
  final MathOperationType operation;
  final int correctAnswer;

  const MathQuestion({
    required this.id,
    required this.operand1,
    required this.operand2,
    required this.operation,
    required this.correctAnswer,
  });

  String get displayString =>
      '$operand1 ${operation.symbol} $operand2 = ?';
}
