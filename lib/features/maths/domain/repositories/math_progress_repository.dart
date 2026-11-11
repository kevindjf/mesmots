import 'package:jerevise/features/maths/domain/entities/math_difficulty.dart';
import 'package:jerevise/features/maths/domain/entities/math_progress.dart';

abstract class MathProgressRepository {
  Future<MathProgress?> getProgress(String gameType, MathDifficulty difficulty);
  Future<void> saveProgress(MathProgress progress);
  Future<void> resetProgress();
}
