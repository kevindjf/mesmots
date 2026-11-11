import 'package:jerevise/features/conjugation/domain/entities/verb.dart';

class PhraseQuestion {
  final int id;
  final Verb verb;
  final String subject;
  final String correct; // conjugated form
  final List<String> options; // 4 choices
  final String displaySentence; // sentence with "________" placeholder

  const PhraseQuestion({
    required this.id,
    required this.verb,
    required this.subject,
    required this.correct,
    required this.options,
    required this.displaySentence,
  });
}
