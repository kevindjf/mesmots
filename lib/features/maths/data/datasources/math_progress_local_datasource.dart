import 'package:hive/hive.dart';
import 'package:jerevise/core/utils/database_provider.dart';
import 'package:jerevise/features/maths/data/models/math_progress_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'math_progress_local_datasource.g.dart';

class MathProgressLocalDatasource {
  final Box<MathProgressModel> _box;

  MathProgressLocalDatasource(this._box);

  Future<MathProgressModel?> get(String key) async {
    return _box.get(key);
  }

  Future<List<MathProgressModel>> getAll() async {
    return _box.values.toList();
  }

  Future<void> save(MathProgressModel model) async {
    await _box.put(model.storageKey, model);
  }

  Future<void> delete(String key) async {
    await _box.delete(key);
  }

  Future<void> deleteAll() async {
    await _box.clear();
  }
}

@riverpod
MathProgressLocalDatasource mathProgressLocalDatasource(
  MathProgressLocalDatasourceRef ref,
) {
  final box = ref.watch(mathProgressBoxProvider).requireValue;
  return MathProgressLocalDatasource(box);
}
