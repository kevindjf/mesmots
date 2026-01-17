import 'package:isar/isar.dart';
import 'package:mesmots/features/word_lists/data/models/word_list_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mesmots/core/utils/database_provider.dart';

part 'word_list_local_datasource.g.dart';

/// Local data source for word lists using Isar
class WordListLocalDataSource {
  final Isar _isar;

  WordListLocalDataSource(this._isar);

  /// Get all word lists
  Future<List<WordListModel>> getAll() async {
    return await _isar.wordListModels.where().findAll();
  }

  /// Get a word list by UUID
  Future<WordListModel?> getByUuid(String uuid) async {
    return await _isar.wordListModels.filter().uuidEqualTo(uuid).findFirst();
  }

  /// Save a word list (insert or update)
  Future<void> save(WordListModel model) async {
    await _isar.writeTxn(() async {
      await _isar.wordListModels.put(model);
    });
  }

  /// Delete a word list
  Future<void> delete(String uuid) async {
    await _isar.writeTxn(() async {
      await _isar.wordListModels.filter().uuidEqualTo(uuid).deleteFirst();
    });
  }

  /// Delete all word lists
  Future<void> deleteAll() async {
    await _isar.writeTxn(() async {
      await _isar.wordListModels.clear();
    });
  }

  /// Watch all word lists (stream)
  Stream<List<WordListModel>> watchAll() {
    return _isar.wordListModels.where().watch(fireImmediately: true);
  }

  /// Watch a specific word list (stream)
  Stream<WordListModel?> watchByUuid(String uuid) {
    return _isar.wordListModels
        .filter()
        .uuidEqualTo(uuid)
        .watch(fireImmediately: true)
        .map((list) => list.isEmpty ? null : list.first);
  }
}

@riverpod
WordListLocalDataSource wordListLocalDataSource(
  WordListLocalDataSourceRef ref,
) {
  final isar = ref.watch(isarProvider).requireValue;
  return WordListLocalDataSource(isar);
}
