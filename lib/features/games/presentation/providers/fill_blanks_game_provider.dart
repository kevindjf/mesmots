import 'package:mesmots/core/utils/audio_service.dart';
import 'package:mesmots/core/utils/haptic_service.dart';
import 'package:mesmots/core/utils/tts_service.dart';
import 'package:mesmots/features/games/domain/entities/game_session.dart';
import 'package:mesmots/features/word_lists/data/repositories/word_list_repository_impl.dart';
import 'package:mesmots/features/word_lists/domain/entities/game_level.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fill_blanks_game_provider.g.dart';

/// Fill blanks question state
class FillBlanksQuestion {
  final String word;
  final List<int> blankPositions; // Indices of letters to hide
  final Map<int, String> userInputs; // Map of position -> user input
  final int successCount;

  const FillBlanksQuestion({
    required this.word,
    required this.blankPositions,
    required this.userInputs,
    required this.successCount,
  });

  /// Get the letter at a position (visible or blank)
  String? getLetterAt(int position) {
    if (blankPositions.contains(position)) {
      return userInputs[position]; // Return user input or null
    }
    return word[position]; // Return actual letter
  }

  /// Check if position is a blank
  bool isBlank(int position) => blankPositions.contains(position);

  /// Check if all blanks are filled
  bool get areAllBlanksFilled {
    return blankPositions.every((pos) => userInputs.containsKey(pos));
  }

  /// Get current blank index (first unfilled blank)
  int? get currentBlankIndex {
    for (final pos in blankPositions) {
      if (!userInputs.containsKey(pos)) {
        return pos;
      }
    }
    return null;
  }
}

/// Fill blanks game state
class FillBlanksGameState {
  final FillBlanksQuestion? question;
  final double progress;
  final int validatedCount;
  final int totalCount;

  const FillBlanksGameState({
    required this.question,
    required this.progress,
    required this.validatedCount,
    required this.totalCount,
  });
}

/// Fill blanks game provider
@riverpod
class FillBlanksGame extends _$FillBlanksGame {
  GameSession? _session;
  FillBlanksQuestion? _currentQuestion;

  @override
  FutureOr<FillBlanksGameState> build(String listId) async {
    // Load word list and initialize session
    final repository = ref.read(wordListRepositoryProvider);
    final wordList = await repository.getById(listId);

    if (wordList == null) {
      throw Exception('Word list not found');
    }

    // Get words that are not fully validated in FillBlanks level
    final progress = wordList.progress[GameLevel.fillBlanks]!;
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

    return _buildState();
  }

  /// Build current game state
  FillBlanksGameState _buildState() {
    return FillBlanksGameState(
      question: _currentQuestion,
      progress: _session?.progress ?? 0.0,
      validatedCount: _session?.validatedCount ?? 0,
      totalCount: _session?.totalWords ?? 0,
    );
  }

  /// Generate a question for current word
  FillBlanksQuestion? _generateQuestion() {
    if (_session == null || _session!.currentWord == null) {
      return null;
    }

    final word = _session!.currentWord!;
    final successCount = _session!.getSuccessCount(word);

    // Determine number of blanks based on success count
    // 0 successes: hide ~50% of letters
    // 1 success: hide ~30% of letters (easier)
    final blankPercentage = successCount == 0 ? 0.5 : 0.3;
    final numBlanks = (word.length * blankPercentage).ceil().clamp(1, word.length - 1);

    // Select random positions to hide (but not first letter to give a hint)
    final availablePositions = List.generate(word.length - 1, (i) => i + 1);
    availablePositions.shuffle();
    final blankPositions = availablePositions.take(numBlanks).toList()..sort();

    return FillBlanksQuestion(
      word: word,
      blankPositions: blankPositions,
      userInputs: {},
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

  /// Add letter to current blank position
  void addLetter(String letter) {
    if (_currentQuestion == null) return;

    final currentBlank = _currentQuestion!.currentBlankIndex;
    if (currentBlank == null) return; // All blanks filled

    // Update user inputs
    final newInputs = Map<int, String>.from(_currentQuestion!.userInputs);
    newInputs[currentBlank] = letter.toLowerCase();

    _currentQuestion = FillBlanksQuestion(
      word: _currentQuestion!.word,
      blankPositions: _currentQuestion!.blankPositions,
      userInputs: newInputs,
      successCount: _currentQuestion!.successCount,
    );

    state = AsyncData(_buildState());

    // Auto-submit if all blanks are filled
    if (_currentQuestion!.areAllBlanksFilled) {
      submitAnswer();
    }
  }

  /// Remove last filled blank
  void removeLetter() {
    if (_currentQuestion == null) return;
    if (_currentQuestion!.userInputs.isEmpty) return;

    // Find the last filled position
    final sortedPositions = _currentQuestion!.blankPositions.toList()..sort();
    int? lastFilledPos;
    for (final pos in sortedPositions.reversed) {
      if (_currentQuestion!.userInputs.containsKey(pos)) {
        lastFilledPos = pos;
        break;
      }
    }

    if (lastFilledPos == null) return;

    // Remove last filled input
    final newInputs = Map<int, String>.from(_currentQuestion!.userInputs);
    newInputs.remove(lastFilledPos);

    _currentQuestion = FillBlanksQuestion(
      word: _currentQuestion!.word,
      blankPositions: _currentQuestion!.blankPositions,
      userInputs: newInputs,
      successCount: _currentQuestion!.successCount,
    );

    state = AsyncData(_buildState());
  }

  /// Clear all user inputs
  void clearInput() {
    if (_currentQuestion == null) return;

    _currentQuestion = FillBlanksQuestion(
      word: _currentQuestion!.word,
      blankPositions: _currentQuestion!.blankPositions,
      userInputs: {},
      successCount: _currentQuestion!.successCount,
    );

    state = AsyncData(_buildState());
  }

  /// Submit answer
  Future<void> submitAnswer() async {
    if (_session == null || _currentQuestion == null) return;
    if (!_currentQuestion!.areAllBlanksFilled) return;

    final currentWord = _currentQuestion!.word;

    // Check if all blanks are correct
    bool isCorrect = true;
    for (final pos in _currentQuestion!.blankPositions) {
      final userLetter = _currentQuestion!.userInputs[pos]?.toLowerCase();
      final correctLetter = currentWord[pos].toLowerCase();
      if (userLetter != correctLetter) {
        isCorrect = false;
        break;
      }
    }

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
      GameLevel.fillBlanks,
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
