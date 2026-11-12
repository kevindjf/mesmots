import 'package:mesmots/core/utils/audio_service.dart';
import 'package:mesmots/core/utils/haptic_service.dart';
import 'package:mesmots/core/utils/string_utils.dart';
import 'package:mesmots/core/utils/tts_service.dart';
import 'package:mesmots/features/games/domain/entities/game_session.dart';
import 'package:mesmots/features/games/presentation/providers/progress_recorder.dart';
import 'package:mesmots/features/word_lists/data/repositories/word_list_repository_impl.dart';
import 'package:mesmots/features/word_lists/domain/entities/game_type.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'scramble_game_provider.g.dart';

/// Where the child is in the current word.
enum ScramblePhase {
  /// Placing letters.
  playing,

  /// All letters right: shown in green before the next word.
  correct,

  /// Some letters wrong: shown in red with the right spelling, then the
  /// child tries again with the right letters kept in place.
  wrong,
}

/// One word to rebuild from its shuffled letters.
class ScrambleQuestion {
  final String word;

  /// The word's letters, shuffled: the tiles.
  final List<String> tiles;

  /// For each slot of the answer, the index of the tile placed there.
  final List<int?> slots;

  /// Slots that can't be changed any more (right letters kept after a
  /// mistake, or placed by the help button).
  final Set<int> lockedSlots;

  /// Slots holding a wrong letter, while [phase] is [ScramblePhase.wrong].
  final Set<int> wrongSlots;

  final ScramblePhase phase;

  /// Mastery stars of the word (same stars as on the list screen).
  final int stars;

  const ScrambleQuestion({
    required this.word,
    required this.tiles,
    required this.slots,
    required this.stars,
    this.lockedSlots = const {},
    this.wrongSlots = const {},
    this.phase = ScramblePhase.playing,
  });

  /// The word's letters, in order, one per slot.
  List<String> get letters => word.graphemes;

  /// Letter shown in [slot], or null if empty.
  String? letterAt(int slot) {
    final tile = slots[slot];
    return tile == null ? null : tiles[tile];
  }

  /// Whether [tile] is placed in a slot (greyed out in the tray).
  bool isTileUsed(int tile) => slots.contains(tile);

  bool get isFull => !slots.contains(null);

  bool get canPlay => phase == ScramblePhase.playing;

  ScrambleQuestion copyWith({
    List<int?>? slots,
    Set<int>? lockedSlots,
    Set<int>? wrongSlots,
    ScramblePhase? phase,
    int? stars,
  }) {
    return ScrambleQuestion(
      word: word,
      tiles: tiles,
      slots: slots ?? this.slots,
      stars: stars ?? this.stars,
      lockedSlots: lockedSlots ?? this.lockedSlots,
      wrongSlots: wrongSlots ?? this.wrongSlots,
      phase: phase ?? this.phase,
    );
  }
}

/// Scramble game state with question and session info
class ScrambleGameState {
  final ScrambleQuestion? question;
  final double progress;
  final int validatedCount;
  final int totalCount;

  const ScrambleGameState({
    required this.question,
    required this.progress,
    required this.validatedCount,
    required this.totalCount,
  });
}

/// "Lettres mélangées": hear the word, put its letters back in order.
///
/// The answer is checked as soon as the last slot is filled. After a
/// mistake, the right spelling is shown and read, the right letters stay in
/// place and the child finishes the word. Each word must be found twice
/// without mistake in a game.
@riverpod
class ScrambleGame extends _$ScrambleGame {
  static const _successPause = Duration(milliseconds: 1200);
  static const _errorPause = Duration(milliseconds: 1800);

  late ProgressRecorder _recorder;

  /// Set when the game screen is closed, possibly during a pause.
  bool _disposed = false;
  late Map<String, int> _stars;
  GameSession? _session;
  ScrambleQuestion? _question;

  /// Whether the current word had a mistake (it then comes back later).
  bool _hadMistake = false;

  @override
  FutureOr<ScrambleGameState> build(String listId) async {
    final repository = ref.read(wordListRepositoryProvider);
    final wordList = await repository.getById(listId);

    if (wordList == null) {
      throw Exception('Word list not found');
    }

    _recorder = ProgressRecorder(repository, listId);
    ref.onDispose(() => _disposed = true);
    _stars = {for (final w in wordList.words) w: wordList.statusOf(w).stars};
    // Free play: every game uses all the words of the list
    _session = GameSession.initial(wordList.words);
    _nextQuestion();
    return _buildState();
  }

  ScrambleGameState _buildState() {
    return ScrambleGameState(
      question: _question,
      progress: _session?.progress ?? 0.0,
      validatedCount: _session?.validatedCount ?? 0,
      totalCount: _session?.totalWords ?? 0,
    );
  }

  void _emit() => state = AsyncData(_buildState());

  void _nextQuestion() {
    _hadMistake = false;
    final word = _session?.currentWord;
    if (word == null) {
      _question = null;
      return;
    }

    final tiles = word.graphemes;
    // Shuffle until the tiles don't already spell the word.
    for (var i = 0; i < 10; i++) {
      tiles.shuffle();
      if (tiles.join() != word) break;
    }

    _question = ScrambleQuestion(
      word: word,
      tiles: tiles,
      slots: List<int?>.filled(tiles.length, null),
      stars: _stars[word] ?? 0,
    );
    ref.read(ttsServiceProvider).speak(word).ignore();
  }

  /// Replay TTS for current word
  Future<void> replayWord() async {
    final word = _question?.word;
    if (word != null) await ref.read(ttsServiceProvider).speak(word);
  }

  /// Put [tile] in the first empty slot. Checks the word when it's full.
  void placeTile(int tile) {
    final q = _question;
    if (q == null || !q.canPlay || q.isTileUsed(tile)) return;
    final slot = q.slots.indexOf(null);
    if (slot < 0) return;

    final slots = [...q.slots]..[slot] = tile;
    _question = q.copyWith(slots: slots);
    ref.read(hapticServiceProvider).selectionClick();
    _emit();

    if (_question!.isFull) _check();
  }

  /// Send the letter in [slot] back to the tiles.
  void removeSlot(int slot) {
    final q = _question;
    if (q == null || !q.canPlay) return;
    if (q.slots[slot] == null || q.lockedSlots.contains(slot)) return;

    final slots = [...q.slots]..[slot] = null;
    _question = q.copyWith(slots: slots);
    _emit();
  }

  /// Send every letter that isn't locked back to the tiles.
  void clearAll() {
    final q = _question;
    if (q == null || !q.canPlay) return;

    final slots = [
      for (var i = 0; i < q.slots.length; i++)
        q.lockedSlots.contains(i) ? q.slots[i] : null,
    ];
    _question = q.copyWith(slots: slots);
    _emit();
  }

  /// Help: put the right letter in the first slot that doesn't have it,
  /// and lock it. No penalty.
  void hint() {
    final q = _question;
    if (q == null || !q.canPlay) return;

    final letters = q.letters;
    final slot = List.generate(letters.length, (i) => i).firstWhere(
      (i) => !q.lockedSlots.contains(i) && q.letterAt(i) != letters[i],
      orElse: () => -1,
    );
    if (slot < 0) return;

    final slots = [...q.slots];
    // Free a tile with the right letter, taking it from an unlocked slot
    // if needed, and free the slot being helped.
    var tile = _freeTileWith(q, letters[slot]);
    if (tile == null) {
      final from = List.generate(slots.length, (i) => i).firstWhere(
        (i) =>
            !q.lockedSlots.contains(i) &&
            i != slot &&
            slots[i] != null &&
            q.tiles[slots[i]!] == letters[slot],
      );
      tile = slots[from];
      slots[from] = null;
    }
    slots[slot] = tile;

    _question = q.copyWith(
      slots: slots,
      lockedSlots: {...q.lockedSlots, slot},
    );
    _emit();

    if (_question!.isFull) _check();
  }

  int? _freeTileWith(ScrambleQuestion q, String letter) {
    for (var t = 0; t < q.tiles.length; t++) {
      if (q.tiles[t] == letter && !q.isTileUsed(t)) return t;
    }
    return null;
  }

  Future<void> _check() async {
    final q = _question!;
    final letters = q.letters;
    final wrong = {
      for (var i = 0; i < letters.length; i++)
        if (q.letterAt(i) != letters[i]) i,
    };
    final audio = ref.read(audioServiceProvider);
    final haptic = ref.read(hapticServiceProvider);

    if (wrong.isEmpty) {
      await _onCorrect(q, audio, haptic);
    } else {
      await _onWrong(q, wrong, audio, haptic);
    }
  }

  Future<void> _onCorrect(
    ScrambleQuestion q,
    AudioService audio,
    HapticService haptic,
  ) async {
    final word = q.word;
    final firstTry = !_hadMistake;
    final before = _stars[word] ?? 0;
    if (firstTry) {
      _stars[word] = (before + 1).clamp(0, WordStatus.masteryThreshold);
      _recorder.recordAttempt(word, success: true);
    }
    // A word finished after a mistake comes back later in the game.
    _session = _session!.answer(firstTry);
    if (_session!.isComplete) _recorder.recordGamePlayed(GameType.scramble);

    haptic.success();
    (_stars[word] ?? 0) > before ? audio.playStar() : audio.playSuccess();
    _question = q.copyWith(phase: ScramblePhase.correct, stars: _stars[word]);
    _emit();

    await Future.delayed(_successPause);
    if (_disposed) return;
    if (_session!.isComplete) {
      audio.playLevelComplete();
    } else if (firstTry && _session!.isWordValidated(word)) {
      audio.playWordComplete();
    }
    _nextQuestion();
    _emit();
  }

  Future<void> _onWrong(
    ScrambleQuestion q,
    Set<int> wrong,
    AudioService audio,
    HapticService haptic,
  ) async {
    if (!_hadMistake) _recorder.recordAttempt(q.word, success: false);
    _hadMistake = true;

    haptic.error();
    audio.playError();
    ref.read(ttsServiceProvider).speak(q.word).ignore();
    _question = q.copyWith(phase: ScramblePhase.wrong, wrongSlots: wrong);
    _emit();

    await Future.delayed(_errorPause);
    if (_disposed) return;

    // Keep the right letters in place, send the wrong ones back.
    final right = {
      for (var i = 0; i < q.slots.length; i++)
        if (!wrong.contains(i)) i,
    };
    _question = q.copyWith(
      slots: [
        for (var i = 0; i < q.slots.length; i++)
          wrong.contains(i) ? null : q.slots[i],
      ],
      lockedSlots: {...q.lockedSlots, ...right},
      wrongSlots: const {},
      phase: ScramblePhase.playing,
    );
    _emit();
  }

  /// Get current game session
  GameSession? get session => _session;

  /// Check if game is complete
  bool get isComplete => _session?.isComplete ?? true;
}
