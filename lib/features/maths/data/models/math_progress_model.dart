import 'package:hive/hive.dart';
import 'package:jerevise/features/maths/domain/entities/math_difficulty.dart';
import 'package:jerevise/features/maths/domain/entities/math_progress.dart';

part 'math_progress_model.g.dart';

@HiveType(typeId: 3)
class MathProgressModel extends HiveObject {
  @HiveField(0)
  late String gameType;

  @HiveField(1)
  late String difficultyName;

  @HiveField(2)
  late int bestScore;

  @HiveField(3)
  late int totalAttempts;

  @HiveField(4)
  late int totalSessions;

  MathProgressModel();

  MathProgressModel.fromEntity(MathProgress entity) {
    gameType = entity.gameType;
    difficultyName = entity.difficulty.name;
    bestScore = entity.bestScore;
    totalAttempts = entity.totalAttempts;
    totalSessions = entity.totalSessions;
  }

  MathProgress toEntity() {
    return MathProgress(
      gameType: gameType,
      difficulty: MathDifficulty.values.firstWhere(
        (d) => d.name == difficultyName,
        orElse: () => MathDifficulty.ce1,
      ),
      bestScore: bestScore,
      totalAttempts: totalAttempts,
      totalSessions: totalSessions,
    );
  }

  /// Key used for Hive storage
  String get storageKey => '${gameType}_$difficultyName';
}
