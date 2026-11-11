/// Entité représentant la progression d'un utilisateur sur un verbe
class ConjugationProgress {
  final String verbInfinitive;
  final int quizScore; // Meilleur score au quiz (nombre de bonnes réponses)
  final int quizAttempts; // Nombre de parties de quiz jouées
  final int builderScore; // Meilleur score au bâtisseur (nombre de bonnes réponses)
  final int builderAttempts; // Nombre de parties bâtisseur jouées
  final int totalSessions; // Nombre total de sessions

  const ConjugationProgress({
    required this.verbInfinitive,
    this.quizScore = 0,
    this.quizAttempts = 0,
    this.builderScore = 0,
    this.builderAttempts = 0,
    this.totalSessions = 0,
  });

  /// Pourcentage de réussite au quiz
  double get quizSuccessRate {
    if (quizAttempts == 0) return 0.0;
    return quizScore / quizAttempts;
  }

  /// Pourcentage de réussite au bâtisseur
  double get builderSuccessRate {
    if (builderAttempts == 0) return 0.0;
    return builderScore / builderAttempts;
  }

  ConjugationProgress copyWith({
    String? verbInfinitive,
    int? quizScore,
    int? quizAttempts,
    int? builderScore,
    int? builderAttempts,
    int? totalSessions,
  }) {
    return ConjugationProgress(
      verbInfinitive: verbInfinitive ?? this.verbInfinitive,
      quizScore: quizScore ?? this.quizScore,
      quizAttempts: quizAttempts ?? this.quizAttempts,
      builderScore: builderScore ?? this.builderScore,
      builderAttempts: builderAttempts ?? this.builderAttempts,
      totalSessions: totalSessions ?? this.totalSessions,
    );
  }

  @override
  String toString() =>
      'ConjugationProgress($verbInfinitive: quiz=$quizScore/$quizAttempts, builder=$builderScore/$builderAttempts)';
}
