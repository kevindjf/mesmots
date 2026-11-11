import 'package:jerevise/features/conjugation/data/datasources/verb_json_datasource.dart';
import 'package:jerevise/features/conjugation/domain/entities/verb.dart';
import 'package:jerevise/features/conjugation/domain/repositories/verb_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'verb_repository_impl.g.dart';

/// Implémentation du VerbRepository utilisant la datasource JSON
class VerbRepositoryImpl implements VerbRepository {
  final VerbJsonDatasource _datasource;

  VerbRepositoryImpl(this._datasource);

  @override
  Future<List<Verb>> getAll() => _datasource.getAll();

  @override
  Future<List<Verb>> getByGroup(String groupTag) =>
      _datasource.getByGroup(groupTag);

  @override
  Future<List<Verb>> getByInfinitives(Set<String> infinitives) =>
      _datasource.getByInfinitives(infinitives);
}

@riverpod
VerbRepository verbRepository(VerbRepositoryRef ref) {
  final datasource = ref.watch(verbJsonDatasourceProvider);
  return VerbRepositoryImpl(datasource);
}
