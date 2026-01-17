import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mesmots/features/games/domain/entities/game_session.dart';
import 'package:mesmots/features/games/domain/usecases/generate_distractors.dart';
import 'package:mesmots/features/word_lists/data/repositories/word_list_repository_impl.dart';
import 'package:mesmots/features/word_lists/domain/entities/game_level.dart';
import 'package:mesmots/core/utils/tts_service.dart';
import 'package:mesmots/core/utils/audio_service.dart';
import 'package:mesmots/core/utils/haptic_service.dart';

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
  final int successCount;

  const QcmQuestion({
    required this.word,
    required this.options,
    required this.successCount,
  });
}

/// QCM game provider
@riverpod
class QcmGame extends _$QcmGame {
  GameSession? _session;
  QcmQuestion? _currentQuestion;
  final _distractorGenerator = GenerateDistractors();

  @override
  FutureOr<QcmQuestion?> build(String listId) async {
    // Load word list and initialize session
    final repository = ref.read(wordListRepositoryProvider);
    final wordList = await repository.getById(listId);

    if (wordList == null) {
      throw Exception('Word list not found');
    }

    // Get words that are not fully validated in QCM level
    final progress = wordList.progress[GameLevel.qcm]!;
    final wordsToPlay = wordList.words.where((word) {
      final status = progress.wordStatuses[word];
      return status == null || !status.isValidated;
    }).toList();

    if (wordsToPlay.isEmpty) {
      // All words validated, use all words
      _session = GameSession.initial(wordList.words);
    } else {
      _session = GameSession.initial(wordsToPlay);
    }

    // Generate first question
    _currentQuestion = _generateQuestion();

    // Auto-play TTS
    if (_currentQuestion != null) {
      final tts = ref.read(ttsServiceProvider);
      await tts.speak(_currentQuestion!.word);
    }

    return _currentQuestion;
  }

  /// Generate a question for current word
  QcmQuestion? _generateQuestion() {
    if (_session == null || _session!.currentWord == null) {
      return null;
    }

    final word = _session!.currentWord!;
    final successCount = _session!.getSuccessCount(word);

    // Generate 3 distractors
    final distractors = _distractorGenerator.call(word);

    // Create options: correct word + 3 distractors
    final options = [
      QcmOption(text: word, isCorrect: true),
      ...distractors.map((d) => QcmOption(text: d, isCorrect: false)),
    ]..shuffle();

    return QcmQuestion(
      word: word,
      options: options,
      successCount: successCount,
    );
  }

  /// Replay TTS for current word
  Future<void> replayWord() async {
    if (_currentQuestion != null) {
      final tts = ref.read(ttsServiceProvider);
      await tts.speak(_currentQuestion!.word);
    }
  }

  /// Answer the current question
  Future<void> answer(String selectedAnswer) async {
    if (_session == null || _currentQuestion == null) return;

    final isCorrect = selectedAnswer == _currentQuestion!.word;

    // Play feedback
    final audio = ref.read(audioServiceProvider);
    final haptic = ref.read(hapticServiceProvider);

    if (isCorrect) {
      await haptic.success();
      await audio.playSuccess();
    } else {
      await haptic.error();
      await audio.playError();
    }

    // Update session
    _session = _session!.answer(isCorrect);

    // Check if word is now validated
    if (isCorrect && _session!.isWordValidated(_currentQuestion!.word)) {
      // Word validated! Play celebration
      await Future.delayed(const Duration(milliseconds: 300));
      await audio.playWordComplete();
      await haptic.success();
    }

    // Update word list progress in database
    await _saveProgress(isCorrect);

    // Wait a bit before showing next question
    await Future.delayed(const Duration(milliseconds: 1200));

    // Generate next question
    _currentQuestion = _generateQuestion();

    // Auto-play TTS for next word
    if (_currentQuestion != null) {
      final tts = ref.read(ttsServiceProvider);
      await tts.speak(_currentQuestion!.word);
    }

    // Update state
    state = AsyncData(_currentQuestion);
  }

  /// Save progress to database
  Future<void> _saveProgress(bool success) async {
    if (_currentQuestion == null) return;

    final repository = ref.read(wordListRepositoryProvider);
    final wordList = await repository.getById(listId);

    if (wordList == null) return;

    final updated = wordList.updateProgress(
      GameLevel.qcm,
      _currentQuestion!.word,
      success,
    );

    await repository.update(updated);
  }

  /// Get current game session
  GameSession? get session => _session;

  /// Check if game is complete
  bool get isComplete => _session?.isComplete ?? true;
}
