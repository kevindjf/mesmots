import 'package:jerevise/core/utils/audio_service.dart';
import 'package:jerevise/features/maths/domain/entities/math_config.dart';
import 'package:jerevise/features/maths/domain/utils/math_generator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cascade_provider.g.dart';

class CascadeNombresState {
  final List<List<int>> rounds;
  final int roundIndex;
  final int score;
  final List<int?> placedNumbers;
  final int? selectedNumber;
  final bool showFeedback;
  final bool lastCorrect;
  final bool ascending;

  const CascadeNombresState({
    this.rounds = const [],
    this.roundIndex = 0,
    this.score = 0,
    this.placedNumbers = const [],
    this.selectedNumber,
    this.showFeedback = false,
    this.lastCorrect = false,
    this.ascending = true,
  });

  CascadeNombresState copyWith({
    List<List<int>>? rounds,
    int? roundIndex,
    int? score,
    List<int?>? placedNumbers,
    int? Function()? selectedNumber,
    bool? showFeedback,
    bool? lastCorrect,
    bool? ascending,
  }) {
    return CascadeNombresState(
      rounds: rounds ?? this.rounds,
      roundIndex: roundIndex ?? this.roundIndex,
      score: score ?? this.score,
      placedNumbers: placedNumbers ?? this.placedNumbers,
      selectedNumber: selectedNumber != null ? selectedNumber() : this.selectedNumber,
      showFeedback: showFeedback ?? this.showFeedback,
      lastCorrect: lastCorrect ?? this.lastCorrect,
      ascending: ascending ?? this.ascending,
    );
  }

  List<int> get currentNumbers =>
      rounds.isEmpty ? [] : rounds[roundIndex];

  List<int> get availableNumbers {
    final placed = placedNumbers.whereType<int>().toSet();
    return currentNumbers.where((n) => !placed.contains(n)).toList();
  }
}

@riverpod
class CascadeNombres extends _$CascadeNombres {
  @override
  CascadeNombresState build(CascadeConfig config) {
    const numbersPerRound = 5;
    final rounds = <List<int>>[];
    for (var i = 0; i < config.questionCount; i++) {
      rounds.add(MathGenerator.generateCascadeNumbers(
        difficulty: config.difficulty,
        count: numbersPerRound,
        ascending: config.ascending,
      ),);
    }

    return CascadeNombresState(
      rounds: rounds,
      placedNumbers: List.filled(numbersPerRound, null),
      ascending: config.ascending,
    );
  }

  void selectNumber(int number) {
    if (state.showFeedback) return;
    state = state.copyWith(selectedNumber: () => number);
  }

  void placeAtPosition(int position) {
    if (state.showFeedback) return;
    if (state.selectedNumber == null) return;
    if (state.placedNumbers[position] != null) return;

    final newPlaced = List<int?>.from(state.placedNumbers);
    newPlaced[position] = state.selectedNumber;
    state = state.copyWith(
      placedNumbers: newPlaced,
      selectedNumber: () => null,
    );
  }

  void removeFromPosition(int position) {
    if (state.showFeedback) return;
    if (state.placedNumbers[position] == null) return;

    final newPlaced = List<int?>.from(state.placedNumbers);
    newPlaced[position] = null;
    state = state.copyWith(placedNumbers: newPlaced);
  }

  void validate() {
    final placed = state.placedNumbers;
    if (placed.any((n) => n == null)) return;

    final sorted = List<int>.from(state.currentNumbers);
    if (state.ascending) {
      sorted.sort();
    } else {
      sorted.sort((a, b) => b.compareTo(a));
    }

    final ok = List.generate(placed.length, (i) => placed[i] == sorted[i])
        .every((e) => e);

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
    if (state.roundIndex >= state.rounds.length - 1) return;
    final numbersPerRound = state.rounds[state.roundIndex + 1].length;
    state = state.copyWith(
      roundIndex: state.roundIndex + 1,
      placedNumbers: List.filled(numbersPerRound, null),
      selectedNumber: () => null,
      showFeedback: false,
      lastCorrect: false,
    );
  }

  bool get isFinished =>
      state.rounds.isNotEmpty &&
      state.roundIndex >= state.rounds.length - 1 &&
      state.showFeedback;
}
