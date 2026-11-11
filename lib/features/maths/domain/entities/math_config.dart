import 'package:jerevise/features/maths/domain/entities/math_difficulty.dart';

class DuelExpressConfig {
  final MathDifficulty difficulty;
  final List<MathOperationType> operations;
  final int timePerQuestion;
  final int questionCount;

  const DuelExpressConfig({
    required this.difficulty,
    required this.operations,
    this.timePerQuestion = 10,
    this.questionCount = 10,
  });
}

class BalanceConfig {
  final MathDifficulty difficulty;
  final int questionCount;

  const BalanceConfig({
    required this.difficulty,
    this.questionCount = 8,
  });
}

class CascadeConfig {
  final MathDifficulty difficulty;
  final int questionCount;
  final bool ascending;

  const CascadeConfig({
    required this.difficulty,
    this.questionCount = 8,
    this.ascending = true,
  });
}

class ChantierConfig {
  final MathDifficulty difficulty;
  final int problemCount;

  const ChantierConfig({
    required this.difficulty,
    this.problemCount = 5,
  });
}
