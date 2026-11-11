import 'package:jerevise/features/conjugation/domain/entities/terminaison_question.dart';

class TerminaisonState {
  final List<TerminaisonQuestion> questions;
  final int index;
  final int score;
  final int timeRemaining;
  final bool showFeedback;
  final bool lastCorrect;

  const TerminaisonState({
    this.questions = const [],
    this.index = 0,
    this.score = 0,
    this.timeRemaining = 15,
    this.showFeedback = false,
    this.lastCorrect = false,
  });

  TerminaisonState copyWith({
    List<TerminaisonQuestion>? questions,
    int? index,
    int? score,
    int? timeRemaining,
    bool? showFeedback,
    bool? lastCorrect,
  }) {
    return TerminaisonState(
      questions: questions ?? this.questions,
      index: index ?? this.index,
      score: score ?? this.score,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      showFeedback: showFeedback ?? this.showFeedback,
      lastCorrect: lastCorrect ?? this.lastCorrect,
    );
  }
}
