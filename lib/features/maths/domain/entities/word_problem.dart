class WordProblem {
  final int id;
  final String title;
  final List<WordProblemStep> steps;

  const WordProblem({
    required this.id,
    required this.title,
    required this.steps,
  });
}

class WordProblemStep {
  final String question;
  final int correctAnswer;
  final List<int> options;

  const WordProblemStep({
    required this.question,
    required this.correctAnswer,
    required this.options,
  });
}
