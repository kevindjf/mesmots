import 'package:jerevise/features/conjugation/data/datasources/verb_builder_json_datasource.dart';
import 'package:jerevise/features/conjugation/domain/entities/verb_builder_data.dart';
import 'package:jerevise/features/conjugation/domain/repositories/verb_builder_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'verb_builder_repository_impl.g.dart';

/// Implémentation du VerbBuilderRepository utilisant la datasource JSON
class VerbBuilderRepositoryImpl implements VerbBuilderRepository {
  final VerbBuilderJsonDatasource _datasource;

  VerbBuilderRepositoryImpl(this._datasource);

  @override
  Future<List<VerbBuilderData>> getAll() => _datasource.getAll();

  @override
  Future<List<VerbBuilderData>> getByGroup(String groupe) =>
      _datasource.getByGroup(groupe);

  @override
  Future<List<VerbBuilderData>> getByInfinitives(Set<String> infinitives) =>
      _datasource.getByInfinitives(infinitives);
}

@riverpod
VerbBuilderRepository verbBuilderRepository(VerbBuilderRepositoryRef ref) {
  final datasource = ref.watch(verbBuilderJsonDatasourceProvider);
  return VerbBuilderRepositoryImpl(datasource);
}
