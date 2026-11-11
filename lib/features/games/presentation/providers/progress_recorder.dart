import 'package:mesmots/features/word_lists/domain/entities/game_type.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_list.dart';
import 'package:mesmots/features/word_lists/domain/repositories/word_list_repository.dart';

/// Saves word mastery and completed games for one word list.
///
/// Writes are chained so quick successive answers never overwrite each other.
class ProgressRecorder {
  final WordListRepository _repository;
  final String _listId;
  Future<void> _pending = Future.value();

  ProgressRecorder(this._repository, this._listId);

  void recordAttempt(String word, {required bool success}) {
    _enqueue((list) => list.recordAttempt(word, success: success));
  }

  void recordGamePlayed(GameType type) {
    _enqueue((list) => list.recordGamePlayed(type));
  }

  void _enqueue(WordList Function(WordList list) change) {
    _pending = _pending.then((_) async {
      final list = await _repository.getById(_listId);
      if (list == null) return;
      await _repository.update(change(list));
    }).catchError((_) {});
  }
}
