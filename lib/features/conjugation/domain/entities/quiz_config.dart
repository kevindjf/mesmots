import 'package:flutter/foundation.dart';

/// Configuration du quiz avec les verbes sélectionnés et les paramètres
class QuizConfig {
  final Set<String> selectedVerbs; // Infinitifs des verbes sélectionnés
  final int timeLimit;
  final int numberQuestions;

  const QuizConfig({
    required this.selectedVerbs,
    required this.timeLimit,
    required this.numberQuestions,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizConfig &&
          runtimeType == other.runtimeType &&
          setEquals(selectedVerbs, other.selectedVerbs) &&
          timeLimit == other.timeLimit &&
          numberQuestions == other.numberQuestions;

  @override
  int get hashCode =>
      Object.hashAll([...selectedVerbs.toList()..sort(), timeLimit, numberQuestions]);
}
