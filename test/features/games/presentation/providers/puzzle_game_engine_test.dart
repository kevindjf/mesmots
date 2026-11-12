import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/core/utils/audio_service.dart';
import 'package:mesmots/core/utils/haptic_service.dart';
import 'package:mesmots/core/utils/tts_service.dart';
import 'package:mesmots/features/games/domain/entities/letter_puzzle.dart';
import 'package:mesmots/features/games/presentation/providers/progress_recorder.dart';
import 'package:mesmots/features/games/presentation/providers/puzzle_game_engine.dart';
import 'package:mesmots/features/word_lists/domain/entities/game_type.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_list.dart';
import 'package:mesmots/features/word_lists/domain/repositories/word_list_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepository extends Mock implements WordListRepository {}

class _MockTts extends Mock implements TtsService {}

class _MockAudio extends Mock implements AudioService {}

class _MockHaptic extends Mock implements HapticService {}

void main() {
  late WordList list;
  late _MockAudio audio;
  late PuzzleGameEngine engine;
  late List<PuzzleGameState> published;

  setUpAll(() {
    registerFallbackValue(
      WordList.create(id: 'x', name: 'x', words: const ['x']),
    );
  });

  setUp(() {
    final repository = _MockRepository();
    final tts = _MockTts();
    final haptic = _MockHaptic();
    audio = _MockAudio();
    list = WordList.create(id: 'l', name: 'Semaine', words: const ['chat']);
    when(() => repository.getById('l')).thenAnswer((_) async => list);
    when(() => repository.update(any())).thenAnswer((invocation) async {
      list = invocation.positionalArguments.first as WordList;
    });
    when(() => tts.speak(any())).thenAnswer((_) async {});
    for (final call in [
      audio.playSuccess,
      audio.playError,
      audio.playStar,
      audio.playWordComplete,
      audio.playLevelComplete,
      haptic.success,
      haptic.error,
      haptic.selectionClick,
    ]) {
      when(call).thenAnswer((_) async {});
    }
    published = [];
    engine = PuzzleGameEngine(
      wordList: list,
      type: GameType.fillBlanks,
      // "chat" with h and t to find, a decoy "d"
      makePuzzle: (word) => LetterPuzzle(
          word: word, blanks: const [1, 3], tiles: const ['t', 'h', 'd']),
      tts: tts,
      audio: audio,
      haptic: haptic,
      recorder: ProgressRecorder(repository, 'l'),
      onChange: published.add,
    );
  });

  LetterPuzzle puzzle() => engine.state.puzzle!;

  test('a right word lights a star with the star sound', () async {
    // Act
    engine.place(1);
    final checking = engine.state;
    engine.place(0);
    await Future<void>.delayed(Duration.zero);

    // Assert
    expect(checking.puzzle!.phase, PuzzlePhase.playing);
    expect(published.last.puzzle!.phase, PuzzlePhase.correct);
    expect(published.last.stars, 1);
    verify(() => audio.playStar()).called(1);
    verifyNever(() => audio.playSuccess());
  });

  test('a wrong word is shown, then the right letters stay', () async {
    // Act: "chad"
    engine.place(1);
    engine.place(2);
    final shown = puzzle();
    engine.remove(0); // ignored while shown
    await Future<void>.delayed(
      PuzzleGameEngine.errorPause + const Duration(milliseconds: 50),
    );

    // Assert
    expect(shown.phase, PuzzlePhase.wrong);
    expect(shown.wrongSlots, {1});
    expect(puzzle().phase, PuzzlePhase.playing);
    expect(puzzle().letterAt(0), 'h');
    expect(puzzle().lockedSlots, {0});
    expect(list.statusOf('chat').consecutiveErrors, 1);
    verify(() => audio.playError()).called(1);
  });

  test('a word finished after a mistake gives no star', () async {
    // Arrange: a mistake first
    engine.place(1);
    engine.place(2);
    await Future<void>.delayed(
      PuzzleGameEngine.errorPause + const Duration(milliseconds: 50),
    );

    // Act
    engine.place(0);
    await Future<void>.delayed(Duration.zero);

    // Assert
    expect(published.last.puzzle!.phase, PuzzlePhase.correct);
    expect(published.last.stars, 0);
    verify(() => audio.playSuccess()).called(1);
  });

  test('nothing is published after the screen is closed', () async {
    // Arrange
    engine.place(1);
    engine.place(0);
    final count = published.length;

    // Act
    engine.dispose();
    await Future<void>.delayed(
      PuzzleGameEngine.successPause + const Duration(milliseconds: 50),
    );

    // Assert
    expect(published.length, count);
  });
}
