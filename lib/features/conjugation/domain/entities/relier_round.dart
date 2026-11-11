import 'package:jerevise/features/conjugation/domain/entities/verb.dart';

class RelierRound {
  final Verb verb;
  final List<String> subjects; // 4 subjects
  final List<String> forms; // 4 forms (shuffled)
  final Map<String, String> correctPairs; // subject → correct form

  const RelierRound({
    required this.verb,
    required this.subjects,
    required this.forms,
    required this.correctPairs,
  });
}
