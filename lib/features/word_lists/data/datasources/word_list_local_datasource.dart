import 'package:hive/hive.dart';
import 'package:mesmots/features/word_lists/data/models/word_list_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mesmots/core/utils/database_provider.dart';

part 'word_list_local_datasource.g.dart';

/// Local data source for word lists using Hive
class WordListLocalDataSource {
  final Box<WordListModel> _box;

  WordListLocalDataSource(this._box);

  /// Get all word lists
  Future<List<WordListModel>> getAll() async {
    return _box.values.toList();
  }

  /// Get a word list by UUID
  Future<WordListModel?> getByUuid(String uuid) async {
    try {
      return _box.values.firstWhere((model) => model.uuid == uuid);
    } catch (e) {
      return null;
    }
  }

  /// Save a word list (insert or update)
  Future<void> save(WordListModel model) async {
    // Use UUID as the key for Hive
    await _box.put(model.uuid, model);
  }

  /// Delete a word list
  Future<void> delete(String uuid) async {
    await _box.delete(uuid);
  }

  /// Delete all word lists
  Future<void> deleteAll() async {
    await _box.clear();
  }

  /// Watch all word lists (stream)
  Stream<List<WordListModel>> watchAll() {
    // Hive's watch() emits on any change to the box
    return _box.watch().map((_) => _box.values.toList());
  }

  /// Watch a specific word list (stream)
  Stream<WordListModel?> watchByUuid(String uuid) {
    return _box.watch(key: uuid).map((_) {
      try {
        return _box.values.firstWhere((model) => model.uuid == uuid);
      } catch (e) {
        return null;
      }
    });
  }
}

@riverpod
WordListLocalDataSource wordListLocalDataSource(
  WordListLocalDataSourceRef ref,
) {
  final box = ref.watch(wordListBoxProvider).requireValue;
  return WordListLocalDataSource(box);
}
