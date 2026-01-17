import 'package:mesmots/features/word_lists/data/datasources/word_list_local_datasource.dart';
import 'package:mesmots/features/word_lists/data/models/word_list_model.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_list.dart';
import 'package:mesmots/features/word_lists/domain/repositories/word_list_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'word_list_repository_impl.g.dart';

/// Implementation of WordListRepository using local data source
class WordListRepositoryImpl implements WordListRepository {
  final WordListLocalDataSource _dataSource;

  WordListRepositoryImpl(this._dataSource);

  @override
  Future<List<WordList>> getAll() async {
    final models = await _dataSource.getAll();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<WordList?> getById(String id) async {
    final model = await _dataSource.getByUuid(id);
    return model?.toEntity();
  }

  @override
  Future<void> create(WordList wordList) async {
    final model = WordListModel.fromEntity(wordList);
    await _dataSource.save(model);
  }

  @override
  Future<void> update(WordList wordList) async {
    final model = WordListModel.fromEntity(wordList);
    await _dataSource.save(model);
  }

  @override
  Future<void> delete(String id) async {
    await _dataSource.delete(id);
  }

  @override
  Stream<List<WordList>> watchAll() {
    return _dataSource.watchAll().map(
          (models) => models.map((model) => model.toEntity()).toList(),
        );
  }

  @override
  Stream<WordList?> watchById(String id) {
    return _dataSource.watchByUuid(id).map(
          (model) => model?.toEntity(),
        );
  }
}

@riverpod
WordListRepository wordListRepository(WordListRepositoryRef ref) {
  final dataSource = ref.watch(wordListLocalDataSourceProvider);
  return WordListRepositoryImpl(dataSource);
}
