import 'dart:async';

import 'package:jerevise/core/utils/audio_service.dart';
import 'package:jerevise/features/maths/domain/entities/math_config.dart';
import 'package:jerevise/features/maths/domain/entities/math_question.dart';
import 'package:jerevise/features/maths/domain/utils/math_generator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'duel_express_provider.g.dart';

class DuelExpressState {
  final List<MathQuestion> questions;
  final int index;
  final int score;
  final int timeRemaining;
  final bool showFeedback;
  final bool lastCorrect;
  final String currentInput;
  final int? lastCorrectAnswer;

  const DuelExpressState({
    this.questions = const [],
    this.index = 0,
    this.score = 0,
    this.timeRemaining = 10,
    this.showFeedback = false,
    this.lastCorrect = false,
    this.currentInput = '',
    this.lastCorrectAnswer,
  });

  DuelExpressState copyWith({
    List<MathQuestion>? questions,
    int? index,
    int? score,
    int? timeRemaining,
    bool? showFeedback,
    bool? lastCorrect,
    String? currentInput,
    int? lastCorrectAnswer,
  }) {
    return DuelExpressState(
      questions: questions ?? this.questions,
      index: index ?? this.index,
      score: score ?? this.score,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      showFeedback: showFeedback ?? this.showFeedback,
      lastCorrect: lastCorrect ?? this.lastCorrect,
      currentInput: currentInput ?? this.currentInput,
      lastCorrectAnswer: lastCorrectAnswer ?? this.lastCorrectAnswer,
    );
  }
}

@riverpod
class DuelExpress extends _$DuelExpress {
  Timer? _timer;
  bool _disposed = false;

  @override
  DuelExpressState build(DuelExpressConfig config) {
    _disposed = false;
    ref.onDispose(() {
      _timer?.cancel();
      _disposed = true;
    });

    final questions = MathGenerator.generateDuelQuestions(
      operations: config.operations,
      difficulty: config.difficulty,
      count: config.questionCount,
    );

    Future.microtask(() {
      if (!_disposed) _startTimer();
    });

    return DuelExpressState(
      questions: questions,
      timeRemaining: config.timePerQuestion,
    );
  }

  void _startTimer() {
    _timer?.cancel();
    state = state.copyWith(timeRemaining: config.timePerQuestion);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_disposed) {
        _timer?.cancel();
        return;
      }
      if (state.timeRemaining <= 1) {
        submitAnswer(null);
      } else {
        state = state.copyWith(timeRemaining: state.timeRemaining - 1);
      }
    });
  }

  void appendDigit(int digit) {
    if (state.showFeedback) return;
    if (state.currentInput.length >= 6) return;
    state = state.copyWith(currentInput: state.currentInput + digit.toString());
  }

  void deleteDigit() {
    if (state.showFeedback) return;
    if (state.currentInput.isEmpty) return;
    state = state.copyWith(
      currentInput: state.currentInput.substring(0, state.currentInput.length - 1),
    );
  }

  void submitAnswer(int? answer) {
    _timer?.cancel();
    if (state.questions.isEmpty) return;

    final q = state.questions[state.index];
    final userAnswer = answer ?? int.tryParse(state.currentInput);
    final ok = userAnswer != null && userAnswer == q.correctAnswer;

    final audio = ref.read(audioServiceProvider);
    if (ok) {
      audio.playSuccess();
    } else {
      audio.playError();
    }

    state = state.copyWith(
      score: state.score + (ok ? 1 : 0),
      showFeedback: true,
      lastCorrect: ok,
      lastCorrectAnswer: q.correctAnswer,
    );
  }

  void next() {
    if (state.questions.isEmpty) return;
    if (state.index >= state.questions.length - 1) {
      _timer?.cancel();
      return;
    }

    state = state.copyWith(
      index: state.index + 1,
      showFeedback: false,
      lastCorrect: false,
      currentInput: '',
      lastCorrectAnswer: null,
    );

    _startTimer();
  }

  bool get isFinished =>
      state.questions.isNotEmpty &&
      state.index >= state.questions.length - 1 &&
      state.showFeedback;

  MathQuestion? get currentQuestion =>
      state.questions.isEmpty ? null : state.questions[state.index];
}
