import 'package:jerevise/core/utils/audio_service.dart';
import 'package:jerevise/features/maths/domain/entities/balance_question.dart';
import 'package:jerevise/features/maths/domain/entities/math_config.dart';
import 'package:jerevise/features/maths/domain/utils/math_generator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'balance_provider.g.dart';

class BalanceMagiqueState {
  final List<BalanceQuestion> questions;
  final int index;
  final int score;
  final Set<int> selectedIndices;
  final bool showFeedback;
  final bool lastCorrect;

  const BalanceMagiqueState({
    this.questions = const [],
    this.index = 0,
    this.score = 0,
    this.selectedIndices = const {},
    this.showFeedback = false,
    this.lastCorrect = false,
  });

  BalanceMagiqueState copyWith({
    List<BalanceQuestion>? questions,
    int? index,
    int? score,
    Set<int>? selectedIndices,
    bool? showFeedback,
    bool? lastCorrect,
  }) {
    return BalanceMagiqueState(
      questions: questions ?? this.questions,
      index: index ?? this.index,
      score: score ?? this.score,
      selectedIndices: selectedIndices ?? this.selectedIndices,
      showFeedback: showFeedback ?? this.showFeedback,
      lastCorrect: lastCorrect ?? this.lastCorrect,
    );
  }

  int get selectedSum {
    if (questions.isEmpty) return 0;
    final tiles = questions[index].availableTiles;
    return selectedIndices.fold(0, (sum, i) => sum + tiles[i]);
  }
}

@riverpod
class BalanceMagique extends _$BalanceMagique {
  @override
  BalanceMagiqueState build(BalanceConfig config) {
    final questions = MathGenerator.generateBalanceQuestions(
      difficulty: config.difficulty,
      count: config.questionCount,
    );
    return BalanceMagiqueState(questions: questions);
  }

  void toggleTile(int tileIndex) {
    if (state.showFeedback) return;
    final selected = Set<int>.from(state.selectedIndices);
    if (selected.contains(tileIndex)) {
      selected.remove(tileIndex);
    } else {
      selected.add(tileIndex);
    }
    state = state.copyWith(selectedIndices: selected);
  }

  void validate() {
    if (state.questions.isEmpty || state.selectedIndices.isEmpty) return;

    final q = state.questions[state.index];
    final selectedTiles = state.selectedIndices
        .map((i) => q.availableTiles[i])
        .toList();
    final ok = q.isValidSolution(selectedTiles);

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
    );
  }

  void next() {
    if (state.index >= state.questions.length - 1) return;
    state = state.copyWith(
      index: state.index + 1,
      selectedIndices: {},
      showFeedback: false,
      lastCorrect: false,
    );
  }

  bool get isFinished =>
      state.questions.isNotEmpty &&
      state.index >= state.questions.length - 1 &&
      state.showFeedback;
}
