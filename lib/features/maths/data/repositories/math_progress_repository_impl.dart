import 'package:jerevise/features/maths/data/datasources/math_progress_local_datasource.dart';
import 'package:jerevise/features/maths/data/models/math_progress_model.dart';
import 'package:jerevise/features/maths/domain/entities/math_difficulty.dart';
import 'package:jerevise/features/maths/domain/entities/math_progress.dart';
import 'package:jerevise/features/maths/domain/repositories/math_progress_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'math_progress_repository_impl.g.dart';

class MathProgressRepositoryImpl implements MathProgressRepository {
  final MathProgressLocalDatasource _datasource;

  MathProgressRepositoryImpl(this._datasource);

  @override
  Future<MathProgress?> getProgress(
    String gameType,
    MathDifficulty difficulty,
  ) async {
    final key = '${gameType}_${difficulty.name}';
    final model = await _datasource.get(key);
    return model?.toEntity();
  }

  @override
  Future<void> saveProgress(MathProgress progress) async {
    final model = MathProgressModel.fromEntity(progress);
    await _datasource.save(model);
  }

  @override
  Future<void> resetProgress() async {
    await _datasource.deleteAll();
  }
}

@riverpod
MathProgressRepository mathProgressRepository(
  MathProgressRepositoryRef ref,
) {
  final datasource = ref.watch(mathProgressLocalDatasourceProvider);
  return MathProgressRepositoryImpl(datasource);
}
