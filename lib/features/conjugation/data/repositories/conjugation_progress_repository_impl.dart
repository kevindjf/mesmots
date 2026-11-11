import 'package:jerevise/features/conjugation/data/datasources/conjugation_progress_local_datasource.dart';
import 'package:jerevise/features/conjugation/data/models/conjugation_progress_model.dart';
import 'package:jerevise/features/conjugation/domain/entities/conjugation_progress.dart';
import 'package:jerevise/features/conjugation/domain/repositories/conjugation_progress_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'conjugation_progress_repository_impl.g.dart';

/// Implémentation du ConjugationProgressRepository utilisant Hive
class ConjugationProgressRepositoryImpl implements ConjugationProgressRepository {
  final ConjugationProgressLocalDatasource _datasource;

  ConjugationProgressRepositoryImpl(this._datasource);

  @override
  Future<ConjugationProgress?> getProgress(String verbInfinitive) async {
    final model = await _datasource.get(verbInfinitive);
    return model?.toEntity();
  }

  @override
  Future<void> saveProgress(ConjugationProgress progress) async {
    final model = ConjugationProgressModel.fromEntity(progress);
    await _datasource.save(model);
  }

  @override
  Future<void> resetProgress() async {
    await _datasource.deleteAll();
  }
}

@riverpod
ConjugationProgressRepository conjugationProgressRepository(
  ConjugationProgressRepositoryRef ref,
) {
  final datasource = ref.watch(conjugationProgressLocalDatasourceProvider);
  return ConjugationProgressRepositoryImpl(datasource);
}
