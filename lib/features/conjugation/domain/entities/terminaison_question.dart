import 'package:jerevise/features/conjugation/domain/entities/verb_builder_data.dart';

class TerminaisonQuestion {
  final int id;
  final VerbBuilderData verb;
  final String subject;
  final String radical;
  final String correctTerminaison;
  final List<String> options; // 4 terminaison choices

  const TerminaisonQuestion({
    required this.id,
    required this.verb,
    required this.subject,
    required this.radical,
    required this.correctTerminaison,
    required this.options,
  });
}
