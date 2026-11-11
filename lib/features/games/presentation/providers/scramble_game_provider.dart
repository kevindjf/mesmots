import 'package:mesmots/core/utils/audio_service.dart';
import 'package:mesmots/core/utils/haptic_service.dart';
import 'package:mesmots/core/utils/string_utils.dart';
import 'package:mesmots/core/utils/tts_service.dart';
import 'package:mesmots/features/games/domain/entities/game_session.dart';
import 'package:mesmots/features/word_lists/data/repositories/word_list_repository_impl.dart';
import 'package:mesmots/features/word_lists/domain/entities/game_type.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'scramble_game_provider.g.dart';

/// Scramble question state
class ScrambleQuestion {
  final String word;
  final List<String> scrambledLetters;
  final int successCount;

  const ScrambleQuestion({
    required this.word,
    required this.scrambledLetters,
    required this.successCount,
  });
}

/// Scramble game state with question and session info
class ScrambleGameState {
  final ScrambleQuestion? question;
  final double progress;
  final int validatedCount;
  final int totalCount;
  final String userInput;

  const ScrambleGameState({
    required this.question,
    required this.progress,
    required this.validatedCount,
    required this.totalCount,
    required this.userInput,
  });
}

/// Scramble game provider
@riverpod
class ScrambleGame extends _$ScrambleGame {
  GameSession? _session;
  ScrambleQuestion? _currentQuestion;
  String _userInput = '';

  @override
  FutureOr<ScrambleGameState> build(String listId) async {
    // Load word list and initialize session
    final repository = ref.read(wordListRepositoryProvider);
    final wordList = await repository.getById(listId);

    if (wordList == null) {
      throw Exception('Word list not found');
    }

    // Get words that are not fully validated in Scramble level
    // Free play: every game uses all the words of the list
    _session = GameSession.initial(wordList.words);

    // Generate first question
    _currentQuestion = _generateQuestion();

    // Auto-play TTS (non-blocking to avoid hanging on emulators)
    if (_currentQuestion != null) {
      final tts = ref.read(ttsServiceProvider);
      tts.speak(_currentQuestion!.word).ignore();
    }

    return _buildState();
  }

  /// Build current game state
  ScrambleGameState _buildState() {
    return ScrambleGameState(
      question: _currentQuestion,
      progress: _session?.progress ?? 0.0,
      validatedCount: _session?.validatedCount ?? 0,
      totalCount: _session?.totalWords ?? 0,
      userInput: _userInput,
    );
  }

  /// Generate a question for current word
  ScrambleQuestion? _generateQuestion() {
    if (_session == null || _session!.currentWord == null) {
      return null;
    }

    final word = _session!.currentWord!;
    final successCount = _session!.getSuccessCount(word);

    // Scramble letters (use grapheme clusters for proper accent handling)
    final letters = word.graphemes;
    letters.shuffle();

    // Make sure it's actually scrambled (not the same as original)
    int attempts = 0;
    while (letters.join() == word && attempts < 10) {
      letters.shuffle();
      attempts++;
    }

    return ScrambleQuestion(
      word: word,
      scrambledLetters: letters,
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

  /// Add a letter to user input
  void addLetter(String letter) {
    if (_currentQuestion == null) return;

    // Don't allow more letters than the word length (use grapheme length)
    if (_userInput.graphemeLen >= _currentQuestion!.word.graphemeLen) return;

    _userInput += letter;
    state = AsyncData(_buildState());
  }

  /// Remove last letter from user input
  void removeLetter() {
    if (_userInput.isEmpty) return;

    final chars = _userInput.graphemes;
    chars.removeLast();
    _userInput = chars.join();
    state = AsyncData(_buildState());
  }

  /// Clear all user input
  void clearInput() {
    _userInput = '';
    state = AsyncData(_buildState());
  }

  /// Submit answer
  Future<void> submitAnswer() async {
    if (_session == null || _currentQuestion == null) return;
    if (_userInput.isEmpty) return;

    final currentWord = _currentQuestion!.word;
    final isCorrect = normalizedEquals(_userInput, currentWord);

    // Play feedback immediately (non-blocking)
    final audio = ref.read(audioServiceProvider);
    final haptic = ref.read(hapticServiceProvider);

    if (isCorrect) {
      haptic.success();
      audio.playSuccess();
    } else {
      haptic.error();
      audio.playError();
    }

    // Update session immediately
    _session = _session!.answer(isCorrect);

    // Clear input
    _userInput = '';

    // Update state immediately so UI refreshes (progress bar updates)
    state = AsyncData(_buildState());

    // Save progress to database asynchronously (non-blocking)
    _saveProgress(currentWord, isCorrect).ignore();

    // Check if word is now validated
    final isValidated = isCorrect && _session!.isWordValidated(currentWord);

    // Wait for feedback delay
    await Future.delayed(Duration(milliseconds: isValidated ? 800 : 500));

    // Play celebration if word validated
    if (isValidated) {
      audio.playWordComplete();
      haptic.success();
      await Future.delayed(const Duration(milliseconds: 400));
    }

    // Generate next question
    _currentQuestion = _generateQuestion();

    // Auto-play TTS for next word (non-blocking for UI)
    if (_currentQuestion != null) {
      final tts = ref.read(ttsServiceProvider);
      tts.speak(_currentQuestion!.word).ignore();
    }

    // Update state with new question
    state = AsyncData(_buildState());
  }

  /// Save word mastery (and completed game) to database
  Future<void> _saveProgress(String word, bool success) async {
    final gameCompleted = _session?.isComplete ?? false;
    final repository = ref.read(wordListRepositoryProvider);
    final wordList = await repository.getById(listId);

    if (wordList == null) return;

    var updated = wordList.recordAttempt(word, success: success);
    if (gameCompleted) {
      updated = updated.recordGamePlayed(GameType.scramble);
    }

    await repository.update(updated);
  }

  /// Get current game session
  GameSession? get session => _session;

  /// Check if game is complete
  bool get isComplete => _session?.isComplete ?? true;
}
