import 'package:mesmots/core/utils/audio_service.dart';
import 'package:mesmots/core/utils/haptic_service.dart';
import 'package:mesmots/core/utils/tts_service.dart';
import 'package:mesmots/features/games/domain/entities/game_session.dart';
import 'package:mesmots/features/games/domain/entities/letter_puzzle.dart';
import 'package:mesmots/features/games/presentation/providers/progress_recorder.dart';
import 'package:mesmots/features/word_lists/domain/entities/game_type.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_list.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_status.dart';

/// What a letter puzzle game shows.
class PuzzleGameState {
  /// Current word, null when the game is over.
  final LetterPuzzle? puzzle;

  /// Mastery stars of the current word (same stars as on the list screen).
  final int stars;
  final double progress;
  final int validatedCount;
  final int totalCount;

  /// Position (grapheme index) of the letter being spelled aloud, when the
  /// game spells the words.
  final int? spokenPosition;

  const PuzzleGameState({
    required this.puzzle,
    required this.stars,
    required this.progress,
    required this.validatedCount,
    required this.totalCount,
    this.spokenPosition,
  });
}

/// Plays a letter puzzle game ("Lettres mélangées", "Mots à trous").
///
/// - The word is read aloud; the puzzle is checked when its last slot is
///   filled.
/// - Right: green, a star, the next word.
/// - Wrong: red letters, the word read again and shown, then the right
///   letters stay and the child finishes the word. A word finished after a
///   mistake gives no star and comes back later.
/// - Each word must be found twice without mistake in a game.
/// - Sounds only for results (right, wrong, word done, game done).
/// - With [spellAloud] ("Écoute et épelle"), each word is said then spelled
///   letter by letter, at the start and after a mistake.
class PuzzleGameEngine {
  static const successPause = Duration(milliseconds: 1200);
  static const errorPause = Duration(milliseconds: 1800);

  final GameType type;
  final bool spellAloud;
  final LetterPuzzle Function(String word) _makePuzzle;
  final TtsService _tts;
  final AudioService _audio;
  final HapticService _haptic;
  final ProgressRecorder _recorder;
  final void Function(PuzzleGameState state) _onChange;
  final Map<String, int> _stars;

  GameSession _session;
  LetterPuzzle? _puzzle;
  bool _hadMistake = false;
  bool _disposed = false;
  int? _spokenPosition;

  /// Identifies the current spelling: a spelling replaced by a newer one
  /// no longer moves the highlighted letter.
  int _spelling = 0;

  PuzzleGameEngine({
    required WordList wordList,
    required this.type,
    this.spellAloud = false,
    required LetterPuzzle Function(String word) makePuzzle,
    required TtsService tts,
    required AudioService audio,
    required HapticService haptic,
    required ProgressRecorder recorder,
    required void Function(PuzzleGameState state) onChange,
  })  : _makePuzzle = makePuzzle,
        _tts = tts,
        _audio = audio,
        _haptic = haptic,
        _recorder = recorder,
        _onChange = onChange,
        _stars = {
          for (final w in wordList.words) w: wordList.statusOf(w).stars
        },
        // Free play: every game uses all the words of the list
        _session = GameSession.initial(wordList.words) {
    _nextPuzzle();
  }

  PuzzleGameState get state {
    final word = _puzzle?.word;
    return PuzzleGameState(
      puzzle: _puzzle,
      stars: word == null ? 0 : _stars[word] ?? 0,
      progress: _session.progress,
      validatedCount: _session.validatedCount,
      totalCount: _session.totalWords,
      spokenPosition: _spokenPosition,
    );
  }

  /// Stop: the game screen was closed, possibly during a pause.
  void dispose() {
    _disposed = true;
    if (spellAloud) _tts.stop().ignore();
  }

  void _publish() {
    if (!_disposed) _onChange(state);
  }

  void _nextPuzzle() {
    _hadMistake = false;
    final word = _session.currentWord;
    _puzzle = word == null ? null : _makePuzzle(word);
    if (word != null) _say(word);
  }

  /// Say the word, and spell it in "Écoute et épelle".
  void _say(String word) {
    if (!spellAloud) {
      _tts.speak(word).ignore();
      return;
    }
    final spelling = ++_spelling;
    _spokenPosition = null;
    _tts.spell(
      word,
      onLetter: (position) {
        if (spelling != _spelling) return;
        _spokenPosition = position;
        _publish();
      },
    ).ignore();
  }

  Future<void> replayWord() async {
    final word = _puzzle?.word;
    if (word != null) await _tts.speak(word);
  }

  /// Say and spell the current word again.
  void replaySpelling() {
    final word = _puzzle?.word;
    if (word != null) _say(word);
  }

  /// Put [tile] in the first empty slot; checks the word when it's full.
  void place(int tile) {
    if (_update((p) => p.place(tile))) {
      _haptic.selectionClick();
      if (_puzzle!.isFull) _check();
    }
  }

  void remove(int slot) => _update((p) => p.remove(slot));

  void removeLast() => _update((p) => p.removeLast());

  void clear() => _update((p) => p.clear());

  /// Place the next right letter, without penalty.
  void hint() {
    if (_update((p) => p.hint()) && _puzzle!.isFull) _check();
  }

  /// Applies [change] to the puzzle; returns whether something changed.
  bool _update(LetterPuzzle Function(LetterPuzzle puzzle) change) {
    final puzzle = _puzzle;
    if (puzzle == null || !puzzle.canPlay) return false;
    final changed = change(puzzle);
    if (identical(changed, puzzle)) return false;
    _puzzle = changed;
    _publish();
    return true;
  }

  Future<void> _check() async {
    final checked = _puzzle!.checked();
    _puzzle = checked;
    if (checked.phase == PuzzlePhase.correct) {
      await _onCorrect(checked.word);
    } else {
      await _onWrong(checked.word);
    }
  }

  Future<void> _onCorrect(String word) async {
    final firstTry = !_hadMistake;
    final before = _stars[word] ?? 0;
    if (firstTry) {
      _stars[word] = (before + 1).clamp(0, WordStatus.masteryThreshold);
      _recorder.recordAttempt(word, success: true);
    }
    _session = _session.answer(firstTry);
    if (_session.isComplete) _recorder.recordGamePlayed(type);

    _haptic.success();
    (_stars[word] ?? 0) > before ? _audio.playStar() : _audio.playSuccess();
    _publish();

    await Future.delayed(successPause);
    if (_disposed) return;
    if (_session.isComplete) {
      _audio.playLevelComplete();
    } else if (firstTry && _session.isWordValidated(word)) {
      _audio.playWordComplete();
    }
    _nextPuzzle();
    _publish();
  }

  Future<void> _onWrong(String word) async {
    if (!_hadMistake) _recorder.recordAttempt(word, success: false);
    _hadMistake = true;

    _haptic.error();
    _audio.playError();
    _say(word);
    _publish();

    await Future.delayed(errorPause);
    if (_disposed) return;
    _puzzle = _puzzle!.retry();
    _publish();
  }
}
