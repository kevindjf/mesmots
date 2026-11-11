import 'package:jerevise/core/utils/audio_service.dart';
import 'package:jerevise/features/maths/domain/entities/math_config.dart';
import 'package:jerevise/features/maths/domain/entities/word_problem.dart';
import 'package:jerevise/features/maths/domain/utils/math_generator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chantier_provider.g.dart';

class ChantierState {
  final List<WordProblem> problems;
  final int problemIndex;
  final int stepIndex;
  final int score;
  final int totalSteps;
  final int completedSteps;
  final bool showFeedback;
  final bool lastCorrect;
  final double buildingProgress;

  const ChantierState({
    this.problems = const [],
    this.problemIndex = 0,
    this.stepIndex = 0,
    this.score = 0,
    this.totalSteps = 0,
    this.completedSteps = 0,
    this.showFeedback = false,
    this.lastCorrect = false,
    this.buildingProgress = 0.0,
  });

  ChantierState copyWith({
    List<WordProblem>? problems,
    int? problemIndex,
    int? stepIndex,
    int? score,
    int? totalSteps,
    int? completedSteps,
    bool? showFeedback,
    bool? lastCorrect,
    double? buildingProgress,
  }) {
    return ChantierState(
      problems: problems ?? this.problems,
      problemIndex: problemIndex ?? this.problemIndex,
      stepIndex: stepIndex ?? this.stepIndex,
      score: score ?? this.score,
      totalSteps: totalSteps ?? this.totalSteps,
      completedSteps: completedSteps ?? this.completedSteps,
      showFeedback: showFeedback ?? this.showFeedback,
      lastCorrect: lastCorrect ?? this.lastCorrect,
      buildingProgress: buildingProgress ?? this.buildingProgress,
    );
  }

  WordProblem? get currentProblem =>
      problems.isEmpty ? null : problems[problemIndex];

  WordProblemStep? get currentStep {
    final p = currentProblem;
    if (p == null || stepIndex >= p.steps.length) return null;
    return p.steps[stepIndex];
  }
}

@riverpod
class Chantier extends _$Chantier {
  @override
  ChantierState build(ChantierConfig config) {
    final problems = MathGenerator.generateWordProblems(
      difficulty: config.difficulty,
      count: config.problemCount,
    );

    final totalSteps = problems.fold(0, (sum, p) => sum + p.steps.length);

    return ChantierState(
      problems: problems,
      totalSteps: totalSteps,
    );
  }

  void answer(int choice) {
    final step = state.currentStep;
    if (step == null || state.showFeedback) return;

    final ok = choice == step.correctAnswer;

    final audio = ref.read(audioServiceProvider);
    if (ok) {
      audio.playSuccess();
    } else {
      audio.playError();
    }

    final newCompleted = state.completedSteps + 1;
    final newProgress = state.totalSteps > 0
        ? newCompleted / state.totalSteps
        : 0.0;

    state = state.copyWith(
      score: state.score + (ok ? 1 : 0),
      completedSteps: newCompleted,
      showFeedback: true,
      lastCorrect: ok,
      buildingProgress: newProgress,
    );
  }

  void nextStep() {
    final problem = state.currentProblem;
    if (problem == null) return;

    if (state.stepIndex < problem.steps.length - 1) {
      state = state.copyWith(
        stepIndex: state.stepIndex + 1,
        showFeedback: false,
        lastCorrect: false,
      );
    }
  }

  void nextProblem() {
    if (state.problemIndex >= state.problems.length - 1) return;
    state = state.copyWith(
      problemIndex: state.problemIndex + 1,
      stepIndex: 0,
      showFeedback: false,
      lastCorrect: false,
    );
  }

  bool get isLastStep {
    final problem = state.currentProblem;
    if (problem == null) return true;
    return state.stepIndex >= problem.steps.length - 1;
  }

  bool get isFinished =>
      state.problems.isNotEmpty &&
      state.problemIndex >= state.problems.length - 1 &&
      isLastStep &&
      state.showFeedback;
}
