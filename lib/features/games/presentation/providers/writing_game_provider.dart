import 'package:mesmots/core/utils/audio_service.dart';
import 'package:mesmots/core/utils/haptic_service.dart';
import 'package:mesmots/core/utils/string_utils.dart';
import 'package:mesmots/core/utils/tts_service.dart';
import 'package:mesmots/features/games/domain/entities/game_session.dart';
import 'package:mesmots/features/games/domain/usecases/compare_spelling.dart';
import 'package:mesmots/features/games/domain/usecases/keyboard_for_words.dart';
import 'package:mesmots/features/games/presentation/providers/progress_recorder.dart';
import 'package:mesmots/features/word_lists/data/repositories/word_list_repository_impl.dart';
import 'package:mesmots/features/word_lists/domain/entities/game_type.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'writing_game_provider.g.dart';

/// Where the child is in the current word.
enum WritingPhase {
  /// Typing the word (or copying it after a mistake).
  typing,

  /// Word right: shown in green before the next one.
  correct,

  /// Word wrong: letters marked green/red, right spelling shown.
  wrong,
}

class WritingQuestion {
  final String word;
  final String input;
  final WritingPhase phase;

  /// After a mistake, the child copies the word with the model shown.
  final bool isCopying;

  /// For each typed letter, whether it's right (shown when [phase] is
  /// [WritingPhase.wrong]).
  final List<bool> marks;

  /// Where the next letter goes, as a letter (grapheme) index in [input];
  /// null at the end.
  final int? cursor;

  const WritingQuestion({
    required this.word,
    this.input = '',
    this.phase = WritingPhase.typing,
    this.isCopying = false,
    this.marks = const [],
    this.cursor,
  });

  bool get canType => phase == WritingPhase.typing;

  /// Letter index of the cursor, the end of [input] included.
  int get cursorIndex => cursor ?? input.graphemeLen;

  WritingQuestion copyWith({
    String? input,
    WritingPhase? phase,
    bool? isCopying,
    List<bool>? marks,
    int? cursor,
    bool cursorAtEnd = false,
  }) {
    return WritingQuestion(
      word: word,
      input: input ?? this.input,
      phase: phase ?? this.phase,
      isCopying: isCopying ?? this.isCopying,
      marks: marks ?? this.marks,
      cursor: cursorAtEnd ? null : cursor ?? this.cursor,
    );
  }
}

class WritingGameState {
  final WritingQuestion? question;

  /// Mastery stars of the current word (same stars as on the list screen).
  final int stars;
  final KeyboardKeys keys;
  final double progress;
  final int validatedCount;
  final int totalCount;

  const WritingGameState({
    required this.question,
    required this.stars,
    required this.keys,
    required this.progress,
    required this.validatedCount,
    required this.totalCount,
  });
}

/// "Écriture": hear the word and type it entirely.
///
/// After a mistake, the typed word is shown letter by letter (right letters
/// green, wrong ones red) with the right spelling, then the child copies
/// the word with the model shown. A copied word gives no star and comes
/// back later. Each word must be written twice without mistake in a game.
@riverpod
class WritingGame extends _$WritingGame {
  static const successPause = Duration(milliseconds: 1200);
  static const errorPause = Duration(milliseconds: 2500);

  late ProgressRecorder _recorder;
  late Map<String, int> _stars;
  late KeyboardKeys _keys;
  late GameSession _session;
  WritingQuestion? _question;
  bool _disposed = false;

  @override
  Future<WritingGameState> build(String listId) async {
    final repository = ref.read(wordListRepositoryProvider);
    final wordList = await repository.getById(listId);
    if (wordList == null) throw Exception('Word list not found');

    _recorder = ProgressRecorder(repository, listId);
    final tts = ref.read(ttsServiceProvider);
    ref.onDispose(() {
      _disposed = true;
      // Leaving the game cuts a word still being read.
      tts.stop().ignore();
    });
    _stars = {for (final w in wordList.words) w: wordList.statusOf(w).stars};
    _keys = keyboardForWords(wordList.words);
    // Free play: every game uses all the words of the list
    _session = GameSession.initial(wordList.words);
    _nextQuestion();
    return _buildState();
  }

  WritingGameState _buildState() {
    final word = _question?.word;
    return WritingGameState(
      question: _question,
      stars: word == null ? 0 : _stars[word] ?? 0,
      keys: _keys,
      progress: _session.progress,
      validatedCount: _session.validatedCount,
      totalCount: _session.totalWords,
    );
  }

  void _publish() {
    if (!_disposed) state = AsyncData(_buildState());
  }

  void _nextQuestion() {
    final word = _session.currentWord;
    _question = word == null ? null : WritingQuestion(word: word);
    if (word != null) ref.read(ttsServiceProvider).speak(word).ignore();
  }

  Future<void> replayWord() async {
    final word = _question?.word;
    if (word != null) await ref.read(ttsServiceProvider).speak(word);
  }

  void type(String letter) {
    final q = _question;
    if (q == null || !q.canType) return;
    // Room for a few extra letters, not for endless typing.
    if (q.input.graphemeLen >= q.word.graphemeLen + 5) return;
    final letters = q.input.graphemes..insert(q.cursorIndex, letter);
    _question = _withCursor(q, letters, q.cursorIndex + 1);
    ref.read(hapticServiceProvider).selectionClick();
    _publish();
  }

  void backspace() {
    final q = _question;
    if (q == null || !q.canType || q.cursorIndex == 0) return;
    final letters = q.input.graphemes..removeAt(q.cursorIndex - 1);
    _question = _withCursor(q, letters, q.cursorIndex - 1);
    _publish();
  }

  /// Put the cursor before the letter at [position] (the end past the
  /// last letter), to insert or erase a letter there.
  void moveCursor(int position) {
    final q = _question;
    if (q == null || !q.canType) return;
    _question = _withCursor(q, q.input.graphemes, position);
    _publish();
  }

  /// [q] with [letters] typed and the cursor at [position], kept at the
  /// end when it is there.
  WritingQuestion _withCursor(
    WritingQuestion q,
    List<String> letters,
    int position,
  ) {
    final at = position.clamp(0, letters.length);
    return q.copyWith(
      input: letters.join(),
      cursor: at,
      cursorAtEnd: at == letters.length,
    );
  }

  /// Help: keep the right beginning of the input and add the next right
  /// letter. No penalty.
  void hint() {
    final q = _question;
    if (q == null || !q.canType) return;
    final typed = q.input.nfc.graphemes;
    final word = q.word.graphemes;
    var right = 0;
    while (right < typed.length &&
        right < word.length &&
        typed[right].toLowerCase() == word[right].toLowerCase()) {
      right++;
    }
    if (right >= word.length) return;
    _question = q.copyWith(
      input: word.take(right + 1).join(),
      cursorAtEnd: true,
    );
    _publish();
  }

  Future<void> submit() async {
    final q = _question;
    if (q == null || !q.canType || q.input.trim().isEmpty) return;
    // A word checked while still read cuts the voice.
    ref.read(ttsServiceProvider).stop().ignore();

    final word = q.word;
    final isRight = normalizedEquals(q.input.trim(), word);
    final audio = ref.read(audioServiceProvider);
    final haptic = ref.read(hapticServiceProvider);

    if (isRight) {
      final firstTry = !q.isCopying;
      final before = _stars[word] ?? 0;
      if (firstTry) {
        _stars[word] = (before + 1).clamp(0, WordStatus.masteryThreshold);
        _recorder.recordAttempt(word, success: true);
      }
      _session = _session.answer(firstTry);
      if (_session.isComplete) _recorder.recordGamePlayed(GameType.writing);

      haptic.success();
      (_stars[word] ?? 0) > before ? audio.playStar() : audio.playSuccess();
      _question = q.copyWith(phase: WritingPhase.correct);
      _publish();

      await Future.delayed(successPause);
      if (_disposed) return;
      if (_session.isComplete) {
        audio.playLevelComplete();
      } else if (firstTry && _session.isWordValidated(word)) {
        audio.playWordComplete();
      }
      _nextQuestion();
      _publish();
    } else {
      if (!q.isCopying) _recorder.recordAttempt(word, success: false);
      haptic.error();
      audio.playError();
      ref.read(ttsServiceProvider).speak(word).ignore();
      _question = q.copyWith(
        phase: WritingPhase.wrong,
        marks: markTypedLetters(q.input, word),
      );
      _publish();

      await Future.delayed(errorPause);
      if (_disposed) return;
      _question = q.copyWith(
        input: '',
        phase: WritingPhase.typing,
        isCopying: true,
        marks: const [],
        cursorAtEnd: true,
      );
      _publish();
    }
  }
}
