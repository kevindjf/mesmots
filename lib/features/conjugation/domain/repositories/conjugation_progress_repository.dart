import 'package:jerevise/features/conjugation/domain/entities/conjugation_progress.dart';

/// Interface du repository pour la progression en conjugaison
abstract class ConjugationProgressRepository {
  /// Récupère la progression pour un verbe donné
  Future<ConjugationProgress?> getProgress(String verbInfinitive);

  /// Sauvegarde la progression pour un verbe
  Future<void> saveProgress(ConjugationProgress progress);

  /// Remet à zéro toute la progression
  Future<void> resetProgress();
}
