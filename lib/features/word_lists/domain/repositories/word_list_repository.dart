import 'package:mesmots/features/word_lists/domain/entities/word_list.dart';

/// Repository interface for word lists
abstract class WordListRepository {
  /// Get all word lists
  Future<List<WordList>> getAll();

  /// Get a word list by ID
  Future<WordList?> getById(String id);

  /// Create a new word list
  Future<void> create(WordList wordList);

  /// Update a word list
  Future<void> update(WordList wordList);

  /// Delete a word list
  Future<void> delete(String id);

  /// Watch all word lists (stream)
  Stream<List<WordList>> watchAll();

  /// Watch a specific word list (stream)
  Stream<WordList?> watchById(String id);
}
