import 'package:mesmots/core/utils/audio_service.dart';
import 'package:mesmots/core/utils/haptic_service.dart';
import 'package:mesmots/core/utils/tts_service.dart';
import 'package:mesmots/features/games/domain/entities/grid_point.dart';
import 'package:mesmots/features/games/domain/entities/word_search_grid.dart';
import 'package:mesmots/features/games/domain/usecases/generate_word_search.dart';
import 'package:mesmots/features/games/presentation/providers/progress_recorder.dart';
import 'package:mesmots/features/word_lists/data/repositories/word_list_repository_impl.dart';
import 'package:mesmots/features/word_lists/domain/entities/game_type.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'word_search_game_provider.g.dart';

/// State of a word search game
class WordSearchGameState {
  final WordSearchGrid grid;

  /// Cells of each found word (key: word index)
  final Map<int, List<GridPoint>> found;

  /// Cells currently selected by the child
  final List<GridPoint> selection;

  /// First cell picked with a tap (tap-tap selection), if any
  final GridPoint? anchor;

  const WordSearchGameState({
    required this.grid,
    this.found = const {},
    this.selection = const [],
    this.anchor,
  });

  int get foundCount => found.length;
  int get totalCount => grid.words.length;
  bool get isComplete => totalCount > 0 && foundCount == totalCount;
  double get progress => totalCount == 0 ? 0 : foundCount / totalCount;

  /// Index of the found word covering [point], if any (last found wins)
  int? foundWordAt(GridPoint point) {
    int? result;
    for (final entry in found.entries) {
      if (entry.value.contains(point)) result = entry.key;
    }
    return result;
  }

  WordSearchGameState copyWith({
    Map<int, List<GridPoint>>? found,
    List<GridPoint>? selection,
    GridPoint? anchor,
    bool clearAnchor = false,
  }) {
    return WordSearchGameState(
      grid: grid,
      found: found ?? this.found,
      selection: selection ?? this.selection,
      anchor: clearAnchor ? null : anchor ?? this.anchor,
    );
  }
}

@riverpod
class WordSearchGame extends _$WordSearchGame {
  late ProgressRecorder _recorder;

  @override
  Future<WordSearchGameState> build(String listId) async {
    final repository = ref.read(wordListRepositoryProvider);
    final wordList = await repository.getById(listId);
    if (wordList == null) {
      throw Exception('Word list not found');
    }

    _recorder = ProgressRecorder(repository, listId);
    return WordSearchGameState(grid: GenerateWordSearch()(wordList.words));
  }

  WordSearchGameState? get _current => state.valueOrNull;

  /// Start a drag selection
  void startSelection(GridPoint point) {
    final current = _current;
    if (current == null || current.isComplete) return;
    state = AsyncData(
      current.copyWith(selection: [point], clearAnchor: true),
    );
  }

  /// Extend the drag selection towards [point]
  void updateSelection(GridPoint point) {
    final current = _current;
    if (current == null || current.selection.isEmpty) return;
    state = AsyncData(
      current.copyWith(selection: _straightLine(current.selection.first, point)),
    );
  }

  /// Validate the drag selection
  void endSelection() {
    final current = _current;
    if (current == null) return;
    _validate(current.selection);
  }

  /// Tap-tap selection: first tap sets the start, second tap the end
  void tapCell(GridPoint point) {
    final current = _current;
    if (current == null || current.isComplete) return;

    final anchor = current.anchor;
    if (anchor == null) {
      ref.read(hapticServiceProvider).selectionClick();
      state = AsyncData(current.copyWith(selection: [point], anchor: point));
      return;
    }
    _validate(_straightLine(anchor, point));
  }

  void _validate(List<GridPoint> selection) {
    final current = _current;
    if (current == null) return;

    final index = _matchingWord(current, selection);
    if (index == null) {
      if (selection.length > 1) ref.read(hapticServiceProvider).light();
      state = AsyncData(
        current.copyWith(selection: const [], clearAnchor: true),
      );
      return;
    }

    final word = current.grid.words[index].word;
    final updated = current.copyWith(
      found: {...current.found, index: selection},
      selection: const [],
      clearAnchor: true,
    );
    state = AsyncData(updated);

    ref.read(hapticServiceProvider).success();
    ref.read(audioServiceProvider).playSuccess();
    ref.read(ttsServiceProvider).speak(word).ignore();
    _recorder.recordAttempt(word, success: true);

    if (updated.isComplete) {
      ref.read(audioServiceProvider).playLevelComplete();
      _recorder.recordGamePlayed(GameType.wordSearch);
    }
  }

  /// Word not found yet whose letters match the selection, in either
  /// reading direction (handles accidental duplicates in filler letters).
  int? _matchingWord(WordSearchGameState current, List<GridPoint> selection) {
    if (selection.length < 2) return null;
    final letters = selection.map(current.grid.letterAt).join();
    final reversed = selection.reversed.map(current.grid.letterAt).join();

    for (var i = 0; i < current.grid.words.length; i++) {
      if (current.found.containsKey(i)) continue;
      final target = current.grid.words[i].letters.join();
      if (target == letters || target == reversed) return i;
    }
    return null;
  }

  /// Cells from [start] towards [end], constrained to a row or a column
  static List<GridPoint> _straightLine(GridPoint start, GridPoint end) {
    final dRow = end.row - start.row;
    final dCol = end.col - start.col;

    if (dRow.abs() >= dCol.abs()) {
      final step = dRow >= 0 ? 1 : -1;
      return [
        for (var i = 0; i <= dRow.abs(); i++)
          GridPoint(start.row + i * step, start.col),
      ];
    }
    final step = dCol >= 0 ? 1 : -1;
    return [
      for (var i = 0; i <= dCol.abs(); i++)
        GridPoint(start.row, start.col + i * step),
    ];
  }
}
