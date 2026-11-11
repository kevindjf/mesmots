import 'package:hive/hive.dart';
import 'package:jerevise/core/utils/database_provider.dart';
import 'package:jerevise/features/conjugation/data/models/conjugation_progress_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'conjugation_progress_local_datasource.g.dart';

/// Datasource local pour la progression en conjugaison (Hive)
class ConjugationProgressLocalDatasource {
  final Box<ConjugationProgressModel> _box;

  ConjugationProgressLocalDatasource(this._box);

  /// Récupère la progression pour un verbe donné
  Future<ConjugationProgressModel?> get(String verbInfinitive) async {
    return _box.get(verbInfinitive);
  }

  /// Récupère toute la progression
  Future<List<ConjugationProgressModel>> getAll() async {
    return _box.values.toList();
  }

  /// Sauvegarde la progression d'un verbe (utilise l'infinitif comme clé)
  Future<void> save(ConjugationProgressModel model) async {
    await _box.put(model.verbInfinitive, model);
  }

  /// Supprime la progression d'un verbe
  Future<void> delete(String verbInfinitive) async {
    await _box.delete(verbInfinitive);
  }

  /// Supprime toute la progression
  Future<void> deleteAll() async {
    await _box.clear();
  }
}

@riverpod
ConjugationProgressLocalDatasource conjugationProgressLocalDatasource(
  ConjugationProgressLocalDatasourceRef ref,
) {
  final box = ref.watch(conjugationProgressBoxProvider).requireValue;
  return ConjugationProgressLocalDatasource(box);
}
