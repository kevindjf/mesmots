import 'package:mesmots/core/utils/audio_service.dart';
import 'package:mesmots/core/utils/haptic_service.dart';
import 'package:mesmots/core/utils/string_utils.dart';
import 'package:mesmots/core/utils/tts_service.dart';
import 'package:mesmots/features/games/domain/entities/game_session.dart';
import 'package:mesmots/features/games/domain/usecases/generate_distractors.dart';
import 'package:mesmots/features/games/presentation/providers/progress_recorder.dart';
import 'package:mesmots/features/word_lists/data/repositories/word_list_repository_impl.dart';
import 'package:mesmots/features/word_lists/domain/entities/game_type.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'qcm_game_provider.g.dart';

/// QCM answer option
class QcmOption {
  final String text;
  final bool isCorrect;

  const QcmOption({
    required this.text,
    required this.isCorrect,
  });
}

/// QCM question state
class QcmQuestion {
  final String word;
  final List<QcmOption> options;

  /// Mastery stars of the word (same stars as on the list screen).
  final int stars;

  /// Option chosen by the child, while its answer is shown.
  final String? selected;

  const QcmQuestion({
    required this.word,
    required this.options,
    required this.stars,
    this.selected,
  });

  /// True while the answer is shown: options can't be tapped.
  bool get isAnswered => selected != null;

  QcmQuestion answered(String option, {required int stars}) => QcmQuestion(
        word: word,
        options: options,
        stars: stars,
        selected: option,
      );
}

/// QCM game state with question and session info
class QcmGameState {
  final QcmQuestion? question;
  final double progress;
  final int validatedCount;
  final int totalCount;

  const QcmGameState({
    required this.question,
    required this.progress,
    required this.validatedCount,
    required this.totalCount,
  });
}

/// "Le bon mot": hear the word, pick the right spelling.
///
/// Each word must be found twice in a game (repetition helps memorizing).
/// After a mistake, the right spelling stays highlighted and is read aloud
/// before moving on.
@riverpod
class QcmGame extends _$QcmGame {
  static const _successPause = Duration(milliseconds: 900);
  static const _errorPause = Duration(milliseconds: 1800);

  late ProgressRecorder _recorder;
  late Map<String, int> _stars;
  GameSession? _session;
  QcmQuestion? _currentQuestion;
  final _distractorGenerator = GenerateDistractors();

  @override
  FutureOr<QcmGameState> build(String listId) async {
    final repository = ref.read(wordListRepositoryProvider);
    final wordList = await repository.getById(listId);

    if (wordList == null) {
      throw Exception('Word list not found');
    }

    _recorder = ProgressRecorder(repository, listId);
    _stars = {for (final w in wordList.words) w: wordList.statusOf(w).stars};
    // Free play: every game uses all the words of the list
    _session = GameSession.initial(wordList.words);
    _currentQuestion = _generateQuestion();
    _speakCurrentWord();

    return _buildState();
  }

  QcmGameState _buildState() {
    return QcmGameState(
      question: _currentQuestion,
      progress: _session?.progress ?? 0.0,
      validatedCount: _session?.validatedCount ?? 0,
      totalCount: _session?.totalWords ?? 0,
    );
  }

  QcmQuestion? _generateQuestion() {
    final word = _session?.currentWord;
    if (word == null) return null;

    final options = [
      QcmOption(text: word, isCorrect: true),
      ..._distractorGenerator(word).map(
        (d) => QcmOption(text: d, isCorrect: false),
      ),
    ]..shuffle();

    return QcmQuestion(word: word, options: options, stars: _stars[word] ?? 0);
  }

  void _speakCurrentWord() {
    final word = _currentQuestion?.word;
    // Non-blocking to avoid hanging on emulators
    if (word != null) ref.read(ttsServiceProvider).speak(word).ignore();
  }

  /// Replay TTS for current word
  Future<void> replayWord() async {
    final word = _currentQuestion?.word;
    if (word != null) await ref.read(ttsServiceProvider).speak(word);
  }

  /// Answer the current question. Ignored while an answer is shown.
  Future<void> answer(String selectedAnswer) async {
    final question = _currentQuestion;
    if (_session == null || question == null || question.isAnswered) return;

    final word = question.word;
    final isCorrect = normalizedEquals(selectedAnswer, word);
    final audio = ref.read(audioServiceProvider);
    final haptic = ref.read(hapticServiceProvider);

    if (isCorrect) {
      final before = _stars[word] ?? 0;
      _stars[word] = (before + 1).clamp(0, WordStatus.masteryThreshold);
      haptic.success();
      // A sparkle when a star lights up, the usual chime otherwise.
      _stars[word]! > before ? audio.playStar() : audio.playSuccess();
    } else {
      haptic.error();
      audio.playError();
      // Let the child hear the right word while seeing its spelling.
      ref.read(ttsServiceProvider).speak(word).ignore();
    }

    _session = _session!.answer(isCorrect);
    _currentQuestion =
        question.answered(selectedAnswer, stars: _stars[word] ?? 0);
    state = AsyncData(_buildState());

    _recorder.recordAttempt(word, success: isCorrect);
    if (_session!.isComplete) _recorder.recordGamePlayed(GameType.qcm);

    await Future.delayed(isCorrect ? _successPause : _errorPause);

    if (_session!.isComplete) {
      audio.playLevelComplete();
    } else if (isCorrect && _session!.isWordValidated(word)) {
      audio.playWordComplete();
    }

    _currentQuestion = _generateQuestion();
    _speakCurrentWord();
    state = AsyncData(_buildState());
  }

  /// Get current game session
  GameSession? get session => _session;

  /// Check if game is complete
  bool get isComplete => _session?.isComplete ?? true;
}
