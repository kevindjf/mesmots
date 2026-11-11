import 'dart:math';

import 'package:jerevise/features/maths/domain/entities/balance_question.dart';
import 'package:jerevise/features/maths/domain/entities/math_difficulty.dart';
import 'package:jerevise/features/maths/domain/entities/math_question.dart';
import 'package:jerevise/features/maths/domain/entities/word_problem.dart';

class MathGenerator {
  static final _random = Random();

  // -----------------------------------------------------------------
  // Duel Express — arithmetic questions
  // -----------------------------------------------------------------

  static List<MathQuestion> generateDuelQuestions({
    required List<MathOperationType> operations,
    required MathDifficulty difficulty,
    required int count,
  }) {
    final questions = <MathQuestion>[];
    for (var i = 0; i < count; i++) {
      final op = operations[_random.nextInt(operations.length)];
      final q = _generateOneQuestion(i, op, difficulty);
      questions.add(q);
    }
    return questions;
  }

  static MathQuestion _generateOneQuestion(
    int id,
    MathOperationType op,
    MathDifficulty difficulty,
  ) {
    final max = difficulty.maxOperand;

    switch (op) {
      case MathOperationType.addition:
        final a = _rand(1, max ~/ 2);
        final b = _rand(1, max ~/ 2);
        return MathQuestion(
          id: id,
          operand1: a,
          operand2: b,
          operation: op,
          correctAnswer: a + b,
        );

      case MathOperationType.subtraction:
        // Ensure positive result
        final a = _rand(2, max);
        final b = _rand(1, a);
        return MathQuestion(
          id: id,
          operand1: a,
          operand2: b,
          operation: op,
          correctAnswer: a - b,
        );

      case MathOperationType.multiplication:
        final limit = difficulty == MathDifficulty.ce2 ? 10 : 12;
        final a = _rand(2, limit);
        final b = _rand(2, limit);
        return MathQuestion(
          id: id,
          operand1: a,
          operand2: b,
          operation: op,
          correctAnswer: a * b,
        );

      case MathOperationType.division:
        // Ensure exact division
        final limit = difficulty == MathDifficulty.cm1 ? 10 : 12;
        final b = _rand(2, limit);
        final quotient = _rand(2, limit);
        final a = b * quotient;
        return MathQuestion(
          id: id,
          operand1: a,
          operand2: b,
          operation: op,
          correctAnswer: quotient,
        );
    }
  }

  // -----------------------------------------------------------------
  // Balance — subset-sum puzzle
  // -----------------------------------------------------------------

  static List<BalanceQuestion> generateBalanceQuestions({
    required MathDifficulty difficulty,
    required int count,
  }) {
    final questions = <BalanceQuestion>[];
    for (var i = 0; i < count; i++) {
      questions.add(_generateOneBalance(i, difficulty));
    }
    return questions;
  }

  static BalanceQuestion _generateOneBalance(int id, MathDifficulty difficulty) {
    final tileCount = difficulty == MathDifficulty.ce1 ? 4 : 6;
    final maxVal = difficulty == MathDifficulty.ce1
        ? 10
        : difficulty == MathDifficulty.ce2
            ? 20
            : 50;

    // Build solution subset first, then add distractors
    final solutionSize = _rand(2, min(4, tileCount));
    final solution = List.generate(solutionSize, (_) => _rand(1, maxVal));
    final target = solution.fold(0, (a, b) => a + b);

    // Add distractor tiles that don't accidentally form the target
    final tiles = [...solution];
    while (tiles.length < tileCount) {
      final d = _rand(1, maxVal);
      tiles.add(d);
    }
    tiles.shuffle(_random);

    return BalanceQuestion(
      id: id,
      targetValue: target,
      availableTiles: tiles,
    );
  }

  // -----------------------------------------------------------------
  // Cascade — ordering numbers
  // -----------------------------------------------------------------

  static List<int> generateCascadeNumbers({
    required MathDifficulty difficulty,
    required int count,
    required bool ascending,
  }) {
    final max = difficulty.maxOperand;
    final numbers = <int>{};
    while (numbers.length < count) {
      numbers.add(_rand(1, max));
    }
    final list = numbers.toList()..shuffle(_random);
    return list;
  }

  // -----------------------------------------------------------------
  // Chantier — word problems
  // -----------------------------------------------------------------

  static List<WordProblem> generateWordProblems({
    required MathDifficulty difficulty,
    required int count,
  }) {
    final problems = <WordProblem>[];
    for (var i = 0; i < count; i++) {
      problems.add(_generateOneWordProblem(i, difficulty));
    }
    return problems;
  }

  static WordProblem _generateOneWordProblem(int id, MathDifficulty difficulty) {
    final names = ['Emma', 'Lucas', 'Léa', 'Hugo', 'Chloé', 'Nathan', 'Jade', 'Louis'];
    final objects = ['pommes', 'billes', 'bonbons', 'livres', 'crayons', 'étoiles', 'gâteaux'];

    final name = names[_random.nextInt(names.length)];
    final obj = objects[_random.nextInt(objects.length)];
    final max = difficulty.maxOperand;
    final small = max <= 20;

    // Generate a 2-step problem
    final a = _rand(small ? 3 : 10, small ? 15 : max ~/ 4);
    final b = _rand(small ? 1 : 5, small ? 8 : max ~/ 6);
    final step1Answer = a + b;

    final c = _rand(1, step1Answer - 1);
    final step2Answer = step1Answer - c;

    final steps = [
      WordProblemStep(
        question: '$name a $a $obj et en reçoit $b de plus.\nCombien en a-t-il maintenant ?',
        correctAnswer: step1Answer,
        options: _generateOptions(step1Answer, difficulty),
      ),
      WordProblemStep(
        question: 'Il en donne $c à un ami.\nCombien lui en reste-t-il ?',
        correctAnswer: step2Answer,
        options: _generateOptions(step2Answer, difficulty),
      ),
    ];

    return WordProblem(
      id: id,
      title: 'Les $obj de $name',
      steps: steps,
    );
  }

  static List<int> _generateOptions(int correct, MathDifficulty difficulty) {
    final opts = <int>{correct};
    while (opts.length < 4) {
      final offset = _rand(1, 5) * (difficulty == MathDifficulty.ce1 ? 1 : _rand(1, 3));
      final distractor = _random.nextBool() ? correct + offset : correct - offset;
      if (distractor > 0) opts.add(distractor);
    }
    final list = opts.toList()..shuffle(_random);
    return list;
  }

  // -----------------------------------------------------------------
  // Helper
  // -----------------------------------------------------------------

  static int _rand(int minInclusive, int maxInclusive) {
    if (maxInclusive <= minInclusive) return minInclusive;
    return minInclusive + _random.nextInt(maxInclusive - minInclusive + 1);
  }
}
