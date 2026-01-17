import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:mesmots/features/word_lists/data/repositories/word_list_repository_impl.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_list.dart';
import 'package:mesmots/features/word_lists/domain/entities/game_level.dart';

part 'word_list_providers.g.dart';

/// Provider for all word lists (stream)
@riverpod
Stream<List<WordList>> wordLists(WordListsRef ref) {
  final repository = ref.watch(wordListRepositoryProvider);
  return repository.watchAll();
}

/// Provider for a specific word list by ID (stream)
@riverpod
Stream<WordList?> wordList(WordListRef ref, String id) {
  final repository = ref.watch(wordListRepositoryProvider);
  return repository.watchById(id);
}

/// Provider for word list operations
@riverpod
class WordListOperations extends _$WordListOperations {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  /// Create a new word list
  Future<String> createList({
    required String name,
    required List<String> words,
  }) async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      final repository = ref.read(wordListRepositoryProvider);
      final uuid = const Uuid().v4();

      final wordList = WordList.create(
        id: uuid,
        name: name,
        words: words,
      );

      await repository.create(wordList);
      return uuid;
    });

    state = result;

    if (result.hasError) {
      throw result.error!;
    }
    return result.requireValue;
  }

  /// Update word list name and words
  Future<void> updateList({
    required String id,
    String? name,
    List<String>? words,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(wordListRepositoryProvider);
      final current = await repository.getById(id);

      if (current == null) {
        throw Exception('Word list not found');
      }

      var updated = current;

      if (name != null) {
        updated = updated.updateName(name);
      }

      if (words != null) {
        updated = updated.updateWords(words);
      }

      await repository.update(updated);
    });
  }

  /// Delete a word list
  Future<void> deleteList(String id) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(wordListRepositoryProvider);
      await repository.delete(id);
    });
  }

  /// Update progress for a word in a specific level
  Future<void> updateProgress({
    required String listId,
    required GameLevel level,
    required String word,
    required bool success,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(wordListRepositoryProvider);
      final current = await repository.getById(listId);

      if (current == null) {
        throw Exception('Word list not found');
      }

      final updated = current.updateProgress(level, word, success);
      await repository.update(updated);
    });
  }

  /// Reset progress for a specific level
  Future<void> resetLevel({
    required String listId,
    required GameLevel level,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(wordListRepositoryProvider);
      final current = await repository.getById(listId);

      if (current == null) {
        throw Exception('Word list not found');
      }

      final updated = current.resetLevel(level);
      await repository.update(updated);
    });
  }

  /// Reset all progress for a word list
  Future<void> resetAllProgress(String listId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(wordListRepositoryProvider);
      final current = await repository.getById(listId);

      if (current == null) {
        throw Exception('Word list not found');
      }

      final updated = current.resetAllProgress();
      await repository.update(updated);
    });
  }
}
