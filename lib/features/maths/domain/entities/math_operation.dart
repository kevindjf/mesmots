import 'package:jerevise/features/maths/domain/entities/math_difficulty.dart';

/// Math operation with display info.
extension MathOperationExtension on MathOperationType {
  String get symbol {
    switch (this) {
      case MathOperationType.addition:
        return '+';
      case MathOperationType.subtraction:
        return '−';
      case MathOperationType.multiplication:
        return '×';
      case MathOperationType.division:
        return '÷';
    }
  }

  String get displayName {
    switch (this) {
      case MathOperationType.addition:
        return 'Addition';
      case MathOperationType.subtraction:
        return 'Soustraction';
      case MathOperationType.multiplication:
        return 'Multiplication';
      case MathOperationType.division:
        return 'Division';
    }
  }
}
