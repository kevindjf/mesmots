import 'package:jerevise/features/conjugation/domain/entities/relier_round.dart';

class RelierState {
  final List<RelierRound> rounds;
  final int roundIndex;
  final int score; // rounds completed without error
  final String? selectedSubject;
  final Set<String> matchedSubjects;
  final bool hadErrorThisRound;
  final String? flashError; // form that flashed red (brief)

  const RelierState({
    this.rounds = const [],
    this.roundIndex = 0,
    this.score = 0,
    this.selectedSubject,
    this.matchedSubjects = const {},
    this.hadErrorThisRound = false,
    this.flashError,
  });

  RelierState copyWith({
    List<RelierRound>? rounds,
    int? roundIndex,
    int? score,
    String? selectedSubject,
    bool clearSelectedSubject = false,
    Set<String>? matchedSubjects,
    bool? hadErrorThisRound,
    String? flashError,
    bool clearFlashError = false,
  }) {
    return RelierState(
      rounds: rounds ?? this.rounds,
      roundIndex: roundIndex ?? this.roundIndex,
      score: score ?? this.score,
      selectedSubject: clearSelectedSubject
          ? null
          : (selectedSubject ?? this.selectedSubject),
      matchedSubjects: matchedSubjects ?? this.matchedSubjects,
      hadErrorThisRound: hadErrorThisRound ?? this.hadErrorThisRound,
      flashError:
          clearFlashError ? null : (flashError ?? this.flashError),
    );
  }

  bool get isFinished =>
      rounds.isNotEmpty && roundIndex >= rounds.length - 1 && matchedSubjects.length >= 4;

  RelierRound? get currentRound =>
      rounds.isEmpty ? null : rounds[roundIndex];
}
