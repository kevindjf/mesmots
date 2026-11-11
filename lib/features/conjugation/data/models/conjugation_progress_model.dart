import 'package:hive/hive.dart';
import 'package:jerevise/features/conjugation/domain/entities/conjugation_progress.dart';

part 'conjugation_progress_model.g.dart';

@HiveType(typeId: 2)
class ConjugationProgressModel extends HiveObject {
  @HiveField(0)
  late String verbInfinitive;

  @HiveField(1)
  late int quizScore;

  @HiveField(2)
  late int quizAttempts;

  @HiveField(3)
  late int builderScore;

  @HiveField(4)
  late int builderAttempts;

  @HiveField(5)
  late int totalSessions;

  ConjugationProgressModel();

  ConjugationProgressModel.fromEntity(ConjugationProgress entity) {
    verbInfinitive = entity.verbInfinitive;
    quizScore = entity.quizScore;
    quizAttempts = entity.quizAttempts;
    builderScore = entity.builderScore;
    builderAttempts = entity.builderAttempts;
    totalSessions = entity.totalSessions;
  }

  ConjugationProgress toEntity() {
    return ConjugationProgress(
      verbInfinitive: verbInfinitive,
      quizScore: quizScore,
      quizAttempts: quizAttempts,
      builderScore: builderScore,
      builderAttempts: builderAttempts,
      totalSessions: totalSessions,
    );
  }
}
