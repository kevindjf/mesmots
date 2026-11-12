import 'package:mesmots/core/utils/audio_service.dart';
import 'package:mesmots/core/utils/haptic_service.dart';
import 'package:mesmots/core/utils/string_utils.dart';
import 'package:mesmots/core/utils/tts_service.dart';
import 'package:mesmots/features/games/domain/entities/crossword.dart';
import 'package:mesmots/features/games/domain/entities/grid_point.dart';
import 'package:mesmots/features/games/domain/usecases/generate_crossword.dart';
import 'package:mesmots/features/games/domain/usecases/keyboard_for_words.dart';
import 'package:mesmots/features/games/presentation/providers/progress_recorder.dart';
import 'package:mesmots/features/word_lists/data/repositories/word_list_repository_impl.dart';
import 'package:mesmots/features/word_lists/domain/entities/game_type.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'crossword_game_provider.g.dart';

/// State of a crossword game
class CrosswordGameState {
  final Crossword crossword;

  /// Letters currently in the grid (given + typed + revealed)
  final Map<GridPoint, String> inputs;

  /// Cells the child cannot change (given or revealed)
  final Set<GridPoint> locked;

  /// Indexes of solved entries
  final Set<int> solved;

  /// Selected entry index
  final int selectedEntry;

  /// Cell receiving the next letter
  final GridPoint? cursor;

  /// Wrong letters of the word just checked, shown in red before being
  /// erased. Typing waits meanwhile.
  final Set<GridPoint> wrongCells;

  /// Extra keys the keyboard needs for the words (accents, space…).
  final KeyboardKeys keys;

  const CrosswordGameState({
    required this.crossword,
    required this.inputs,
    required this.locked,
    required this.solved,
    required this.selectedEntry,
    required this.cursor,
    required this.keys,
    this.wrongCells = const {},
  });

  int get totalCount => crossword.entries.length;
  int get solvedCount => solved.length;
  bool get isComplete => totalCount > 0 && solvedCount == totalCount;
  double get progress => totalCount == 0 ? 0 : solvedCount / totalCount;

  CrosswordEntry get selected => crossword.entries[selectedEntry];

  bool isSolvedCell(GridPoint point) =>
      crossword.entriesAt(point).any(solved.contains);

  /// Whether a mistake is being shown.
  bool get isShowingMistake => wrongCells.isNotEmpty;

  bool isEditable(GridPoint point) =>
      !locked.contains(point) && !isSolvedCell(point);

  CrosswordGameState copyWith({
    Map<GridPoint, String>? inputs,
    Set<GridPoint>? locked,
    Set<int>? solved,
    int? selectedEntry,
    GridPoint? cursor,
    bool clearCursor = false,
    Set<GridPoint>? wrongCells,
    bool clearWrong = false,
  }) {
    return CrosswordGameState(
      crossword: crossword,
      inputs: inputs ?? this.inputs,
      locked: locked ?? this.locked,
      solved: solved ?? this.solved,
      selectedEntry: selectedEntry ?? this.selectedEntry,
      cursor: clearCursor ? null : cursor ?? this.cursor,
      keys: keys,
      wrongCells: clearWrong ? const {} : wrongCells ?? this.wrongCells,
    );
  }
}

@riverpod
class CrosswordGame extends _$CrosswordGame {
  static const errorPause = Duration(milliseconds: 1500);

  late ProgressRecorder _recorder;
  late Map<String, int> _stars;

  /// Entries that had a mistake: no star when finally found.
  final _mistakes = <int>{};
  bool _disposed = false;

  @override
  Future<CrosswordGameState> build(String listId) async {
    final repository = ref.read(wordListRepositoryProvider);
    final wordList = await repository.getById(listId);
    if (wordList == null) {
      throw Exception('Word list not found');
    }
    _recorder = ProgressRecorder(repository, listId);
    ref.onDispose(() => _disposed = true);
    _stars = {for (final w in wordList.words) w: wordList.statusOf(w).stars};

    final crossword = GenerateCrossword()(wordList.words);
    if (!crossword.isPlayable) {
      throw const CrosswordUnavailableException();
    }

    final inputs = {
      for (final point in crossword.prefilled)
        point: crossword.solution[point]!,
    };
    final initial = CrosswordGameState(
      crossword: crossword,
      inputs: inputs,
      locked: Set.of(crossword.prefilled),
      // Entries fully given from the start are already solved
      solved: {
        for (var i = 0; i < crossword.entries.length; i++)
          if (crossword.entries[i].cells.every(crossword.prefilled.contains)) i,
      },
      selectedEntry: 0,
      cursor: null,
      keys: keyboardForWords([for (final e in crossword.entries) e.word]),
    );
    final first = _firstUnsolved(initial) ?? 0;
    final state = _select(initial, first);
    _speakSelected(state);
    return state;
  }

  CrosswordGameState? get _current => state.valueOrNull;

  /// Select the entry at [index] (from the clue list)
  void selectEntry(int index) {
    final current = _current;
    if (current == null) return;
    final updated = _select(current, index);
    state = AsyncData(updated);
    _speakSelected(updated);
  }

  /// Tap on a grid cell: selects a word going through it. Tapping the
  /// selected cell again switches between horizontal and vertical.
  void tapCell(GridPoint point) {
    final current = _current;
    if (current == null || !current.crossword.isCell(point)) return;

    final candidates = current.crossword.entriesAt(point);
    var index = candidates.first;
    if (candidates.length > 1) {
      final isSelected = candidates.contains(current.selectedEntry);
      index = isSelected && current.cursor == point
          ? candidates.firstWhere((i) => i != current.selectedEntry)
          : isSelected
              ? current.selectedEntry
              : candidates.firstWhere(
                  (i) => !current.solved.contains(i),
                  orElse: () => candidates.first,
                );
    }

    final changedEntry = index != current.selectedEntry;
    final updated = current.copyWith(
      selectedEntry: index,
      cursor: current.isEditable(point)
          ? point
          : _nextEditable(current, index, point),
      clearWrong: true,
    );
    state = AsyncData(updated);
    if (changedEntry) _speakSelected(updated);
  }

  /// Read the selected word aloud
  void speakSelected() {
    final current = _current;
    if (current != null) _speakSelected(current);
  }

  /// Type a letter in the cursor cell, then move forward
  void typeLetter(String letter) {
    final current = _current;
    final cursor = current?.cursor;
    if (current == null || cursor == null || current.isShowingMistake) return;

    ref.read(hapticServiceProvider).selectionClick();
    final typed = current.copyWith(
      inputs: {...current.inputs, cursor: letter.nfc.toLowerCase()},
      clearWrong: true,
    );
    final checked = _checkEntries(typed, cursor);
    state = AsyncData(
      checked.copyWith(
        cursor: _nextEditable(checked, checked.selectedEntry, cursor),
        clearCursor:
            _nextEditable(checked, checked.selectedEntry, cursor) == null,
      ),
    );
    if (checked.solved.contains(checked.selectedEntry)) _moveToNextWord();
  }

  /// Erase the letter under the cursor, or the previous one
  void deleteLetter() {
    final current = _current;
    if (current == null || current.isShowingMistake) return;

    final cells = current.selected.cells;
    var index = current.cursor == null
        ? cells.length - 1
        : cells.indexOf(current.cursor!);
    if (index < 0) return;

    final cursorCell = cells[index];
    if (!current.inputs.containsKey(cursorCell) ||
        !current.isEditable(cursorCell)) {
      index--;
      while (index >= 0 && !current.isEditable(cells[index])) {
        index--;
      }
      if (index < 0) return;
    }

    final target = cells[index];
    state = AsyncData(
      current.copyWith(
        inputs: Map.of(current.inputs)..remove(target),
        cursor: target,
        clearWrong: true,
      ),
    );
  }

  /// Reveal the right letter in the cursor cell (or the first wrong one)
  void revealLetter() {
    final current = _current;
    if (current == null || current.isShowingMistake) return;

    final cells = current.selected.cells;
    final solution = current.crossword.solution;
    final target =
        current.cursor ?? cells.where(current.isEditable).firstOrNull;
    if (target == null) return;

    final revealed = current.copyWith(
      inputs: {...current.inputs, target: solution[target]!},
      locked: {...current.locked, target},
      clearWrong: true,
    );
    final checked = _checkEntries(revealed, target);
    state = AsyncData(
      checked.copyWith(
        cursor: _nextEditable(checked, checked.selectedEntry, target),
        clearCursor:
            _nextEditable(checked, checked.selectedEntry, target) == null,
      ),
    );
    if (checked.solved.contains(checked.selectedEntry)) _moveToNextWord();
  }

  /// Check every entry crossing [point] once it is fully filled
  CrosswordGameState _checkEntries(
      CrosswordGameState current, GridPoint point) {
    var result = current;
    for (final index in current.crossword.entriesAt(point)) {
      if (result.solved.contains(index)) continue;
      final entry = current.crossword.entries[index];
      if (!entry.cells.every(result.inputs.containsKey)) continue;

      final isRight = entry.cells.every(
        (c) => result.inputs[c] == current.crossword.solution[c],
      );
      if (isRight) {
        result = result.copyWith(solved: {...result.solved, index});
        _onSolved(entry, result);
      } else {
        final wrong = {
          for (final c in entry.cells)
            if (result.inputs[c] != current.crossword.solution[c]) c,
        };
        result = result.copyWith(wrongCells: {...result.wrongCells, ...wrong});
        _onWrong(index, entry, wrong);
      }
    }
    return result;
  }

  void _onSolved(CrosswordEntry entry, CrosswordGameState result) {
    final index = result.crossword.entries.indexOf(entry);
    final audio = ref.read(audioServiceProvider);
    ref.read(hapticServiceProvider).success();
    if (_mistakes.contains(index)) {
      audio.playSuccess();
    } else {
      // Found without mistake: a mastery star, with a sparkle if it lights.
      final before = _stars[entry.word] ?? 0;
      _stars[entry.word] = (before + 1).clamp(0, WordStatus.masteryThreshold);
      _stars[entry.word]! > before ? audio.playStar() : audio.playSuccess();
      _recorder.recordAttempt(entry.word, success: true);
    }

    if (result.isComplete) {
      ref.read(audioServiceProvider).playLevelComplete();
      _recorder.recordGamePlayed(GameType.crossword);
    }
  }

  /// A filled word is wrong: red letters, error sound, the word read
  /// again; after a pause the wrong letters are erased, the right ones stay.
  void _onWrong(int index, CrosswordEntry entry, Set<GridPoint> wrong) {
    if (_mistakes.add(index)) {
      _recorder.recordAttempt(entry.word, success: false);
    }
    ref.read(hapticServiceProvider).error();
    ref.read(audioServiceProvider).playError();
    ref.read(ttsServiceProvider).speak(entry.word).ignore();
    Future.delayed(errorPause, () => _eraseMistakes(wrong));
  }

  /// Erase the [wrong] letters (still editable) and put the cursor on the
  /// first one of the selected word.
  void _eraseMistakes(Set<GridPoint> wrong) {
    final current = _current;
    if (_disposed || current == null) return;
    final toErase = wrong.where(current.isEditable).toSet();
    final firstWrong =
        current.selected.cells.where(toErase.contains).firstOrNull;
    state = AsyncData(
      current.copyWith(
        inputs: Map.of(current.inputs)
          ..removeWhere((point, _) => toErase.contains(point)),
        cursor: firstWrong ?? current.cursor,
        clearWrong: true,
      ),
    );
  }

  void _moveToNextWord() {
    final current = _current;
    if (current == null || current.isComplete) return;
    final next = _firstUnsolved(current, after: current.selectedEntry);
    if (next != null) selectEntry(next);
  }

  CrosswordGameState _select(CrosswordGameState current, int index) {
    final cells = current.crossword.entries[index].cells;
    final firstEmpty = cells.where(
      (c) => current.isEditable(c) && !current.inputs.containsKey(c),
    );
    final firstEditable = cells.where(current.isEditable);
    return current.copyWith(
      selectedEntry: index,
      cursor: firstEmpty.firstOrNull ?? firstEditable.firstOrNull,
      clearCursor: firstEditable.isEmpty,
      clearWrong: true,
    );
  }

  /// Next editable cell after [from] in the entry, or null
  GridPoint? _nextEditable(
    CrosswordGameState current,
    int entryIndex,
    GridPoint from,
  ) {
    final cells = current.crossword.entries[entryIndex].cells;
    final start = cells.indexOf(from);
    for (var i = start + 1; i < cells.length; i++) {
      if (current.isEditable(cells[i])) return cells[i];
    }
    return null;
  }

  int? _firstUnsolved(CrosswordGameState current, {int after = -1}) {
    final count = current.crossword.entries.length;
    for (var step = 1; step <= count; step++) {
      final index = (after + step) % count;
      if (!current.solved.contains(index)) return index;
    }
    return null;
  }

  void _speakSelected(CrosswordGameState current) {
    ref.read(ttsServiceProvider).speak(current.selected.word).ignore();
  }
}

/// Thrown when the words cannot be crossed into a playable grid.
class CrosswordUnavailableException implements Exception {
  const CrosswordUnavailableException();
}
