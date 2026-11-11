import 'package:characters/characters.dart';
import 'package:jerevise/core/utils/audio_service.dart';
import 'package:jerevise/core/utils/haptic_service.dart';
import 'package:jerevise/core/utils/string_utils.dart';
import 'package:jerevise/core/utils/tts_service.dart';
import 'package:jerevise/features/games/domain/entities/game_session.dart';
import 'package:jerevise/features/word_lists/data/repositories/word_list_repository_impl.dart';
import 'package:jerevise/features/word_lists/domain/entities/game_level.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'writing_game_provider.g.dart';

/// Writing question state
class WritingQuestion {
  final String word;
  final String userInput;
  final int successCount;

  const WritingQuestion({
    required this.word,
    required this.userInput,
    required this.successCount,
  });

  WritingQuestion copyWith({
    String? word,
    String? userInput,
    int? successCount,
  }) {
    return WritingQuestion(
      word: word ?? this.word,
      userInput: userInput ?? this.userInput,
      successCount: successCount ?? this.successCount,
    );
  }
}

/// Writing game state
class WritingGameState {
  final WritingQuestion? question;
  final double progress;
  final int validatedCount;
  final int totalCount;

  const WritingGameState({
    required this.question,
    required this.progress,
    required this.validatedCount,
    required this.totalCount,
  });
}

/// Writing game provider
@riverpod
class WritingGame extends _$WritingGame {
  GameSession? _session;
  WritingQuestion? _currentQuestion;

  @override
  FutureOr<WritingGameState> build(String listId) async {
    // Load word list and initialize session
    final repository = ref.read(wordListRepositoryProvider);
    final wordList = await repository.getById(listId);

    if (wordList == null) {
      throw Exception('Word list not found');
    }

    // Get words that are not fully validated in Writing level
    final progress = wordList.progress[GameLevel.writing]!;
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

    // Auto-play TTS (non-blocking to avoid hanging on emulators)
    if (_currentQuestion != null) {
      final tts = ref.read(ttsServiceProvider);
      tts.speak(_currentQuestion!.word).ignore();
    }

    return _buildState();
  }

  /// Build current game state
  WritingGameState _buildState() {
    return WritingGameState(
      question: _currentQuestion,
      progress: _session?.progress ?? 0.0,
      validatedCount: _session?.validatedCount ?? 0,
      totalCount: _session?.totalWords ?? 0,
    );
  }

  /// Generate a question for current word
  WritingQuestion? _generateQuestion() {
    if (_session == null || _session!.currentWord == null) {
      return null;
    }

    final word = _session!.currentWord!;
    final successCount = _session!.getSuccessCount(word);

    return WritingQuestion(
      word: word,
      userInput: '',
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

  /// Update user input
  void updateInput(String input) {
    if (_currentQuestion == null) return;

    _currentQuestion = _currentQuestion!.copyWith(userInput: input);
    state = AsyncData(_buildState());
  }

  /// Add a single letter to user input
  void addLetter(String letter) {
    if (_currentQuestion == null) return;

    _currentQuestion = _currentQuestion!.copyWith(
      userInput: _currentQuestion!.userInput + letter,
    );
    state = AsyncData(_buildState());
  }

  /// Remove the last grapheme from user input
  void removeLetter() {
    if (_currentQuestion == null) return;
    if (_currentQuestion!.userInput.isEmpty) return;

    final graphemes = _currentQuestion!.userInput.characters.toList();
    graphemes.removeLast();
    _currentQuestion = _currentQuestion!.copyWith(
      userInput: graphemes.join(),
    );
    state = AsyncData(_buildState());
  }

  /// Clear user input
  void clearInput() {
    if (_currentQuestion == null) return;

    _currentQuestion = _currentQuestion!.copyWith(userInput: '');
    state = AsyncData(_buildState());
  }

  /// Submit answer
  Future<void> submitAnswer() async {
    if (_session == null || _currentQuestion == null) return;
    if (_currentQuestion!.userInput.trim().isEmpty) return;

    final currentWord = _currentQuestion!.word;
    final userAnswer = _currentQuestion!.userInput.trim();

    final isCorrect = normalizedEquals(userAnswer, currentWord);

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

    // Update state immediately so UI refreshes (progress bar updates)
    state = AsyncData(_buildState());

    // Save progress to database asynchronously (non-blocking)
    _saveProgress(isCorrect).ignore();

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

  /// Save progress to database
  Future<void> _saveProgress(bool success) async {
    if (_currentQuestion == null) return;

    final repository = ref.read(wordListRepositoryProvider);
    final wordList = await repository.getById(listId);

    if (wordList == null) return;

    final updated = wordList.updateProgress(
      GameLevel.writing,
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
