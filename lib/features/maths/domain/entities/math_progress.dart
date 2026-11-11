import 'package:jerevise/features/maths/domain/entities/math_difficulty.dart';

class MathProgress {
  final String gameType;
  final MathDifficulty difficulty;
  final int bestScore;
  final int totalAttempts;
  final int totalSessions;

  const MathProgress({
    required this.gameType,
    required this.difficulty,
    this.bestScore = 0,
    this.totalAttempts = 0,
    this.totalSessions = 0,
  });

  MathProgress copyWith({
    int? bestScore,
    int? totalAttempts,
    int? totalSessions,
  }) {
    return MathProgress(
      gameType: gameType,
      difficulty: difficulty,
      bestScore: bestScore ?? this.bestScore,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      totalSessions: totalSessions ?? this.totalSessions,
    );
  }
}
