import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/core/utils/audio_service.dart';
import 'package:mesmots/core/utils/haptic_service.dart';
import 'package:mesmots/core/utils/tts_service.dart';
import 'package:mesmots/features/games/presentation/providers/crossword_game_provider.dart';
import 'package:mesmots/features/word_lists/data/repositories/word_list_repository_impl.dart';
import 'package:mesmots/features/word_lists/domain/entities/game_type.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_list.dart';
import 'package:mesmots/features/word_lists/domain/repositories/word_list_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockWordListRepository extends Mock implements WordListRepository {}

class MockAudioService extends Mock implements AudioService {}

class MockTtsService extends Mock implements TtsService {}

class MockHapticService extends Mock implements HapticService {}

void main() {
  late MockWordListRepository repository;
  late WordList stored;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(
      WordList.create(id: 'fallback', name: '', words: const []),
    );
  });

  void setUpList(List<String> words) {
    stored = WordList.create(id: 'l1', name: 'S1', words: words);
  }

  setUp(() {
    repository = MockWordListRepository();
    setUpList(['maison', 'école', 'chat', 'jardin', 'matin']);
    when(() => repository.getById('l1')).thenAnswer((_) async => stored);
    when(() => repository.update(any())).thenAnswer((invocation) async {
      stored = invocation.positionalArguments.first as WordList;
    });

    final audio = MockAudioService();
    final tts = MockTtsService();
    final haptic = MockHapticService();
    when(audio.playSuccess).thenAnswer((_) async {});
    when(audio.playStar).thenAnswer((_) async {});
    when(audio.playError).thenAnswer((_) async {});
    when(audio.playLevelComplete).thenAnswer((_) async {});
    when(() => tts.speak(any())).thenAnswer((_) async {});
    when(() => tts.stop()).thenAnswer((_) async {});
    when(haptic.success).thenAnswer((_) async {});
    when(haptic.error).thenAnswer((_) async {});
    when(haptic.selectionClick).thenAnswer((_) async {});

    container = ProviderContainer(overrides: [
      wordListRepositoryProvider.overrideWithValue(repository),
      audioServiceProvider.overrideWithValue(audio),
      ttsServiceProvider.overrideWithValue(tts),
      hapticServiceProvider.overrideWithValue(haptic),
    ]);
  });

  tearDown(() => container.dispose());

  final provider = crosswordGameProvider('l1');

  Future<CrosswordGameState> load() {
    container.listen(provider, (_, __) {});
    return container.read(provider.future);
  }

  CrosswordGame game() => container.read(provider.notifier);
  CrosswordGameState current() => container.read(provider).requireValue;

  /// Types the expected letters of the selected word in its free cells
  void typeSelectedWord({bool wrongLast = false}) {
    final state = current();
    final free = state.selected.cells.where(state.isEditable).toList();
    for (var i = 0; i < free.length; i++) {
      final letter = state.crossword.solution[free[i]]!;
      final isLast = i == free.length - 1;
      game().typeLetter(wrongLast && isLast
          ? (letter == 'z' ? 'y' : 'z')
          : letter.toLowerCase());
    }
  }

  /// Selects an unsolved word that has letters already in the grid
  /// before its first free cell.
  Future<void> selectWordStartingFilled() async {
    final state = await load();
    final entries = state.crossword.entries;
    final index = [
      for (var i = 0; i < entries.length; i++)
        if (!state.solved.contains(i) &&
            !state.isEditable(entries[i].cells.first) &&
            entries[i].cells.any(state.isEditable))
          i,
    ].first;
    game().selectEntry(index);
  }

  test('a whole word typed in one go steps over the letters already there',
      () async {
    // Arrange
    await selectWordStartingFilled();
    final index = current().selectedEntry;
    final cells = current().selected.cells;
    final solution = current().crossword.solution;

    // Act: every letter of the word, the filled ones included
    for (final cell in cells) {
      game().typeLetter(solution[cell]!);
    }

    // Assert
    expect(current().solved, contains(index));
    expect(current().isShowingMistake, isFalse);
  });

  test('a letter other than the filled one goes in the free cell', () async {
    // Arrange
    await selectWordStartingFilled();
    final free = current().selected.cells.firstWhere(current().isEditable);
    final letter = current().crossword.solution[free]!;
    final filled = current().inputs[current().selected.cells.first];

    // Act
    game().typeLetter(letter);

    // Assert
    if (letter != filled) expect(current().inputs[free], letter);
  });

  test('starts with given letters and the cursor on a free cell', () async {
    // Act
    final state = await load();

    // Assert
    for (final point in state.crossword.prefilled) {
      expect(state.inputs[point], state.crossword.solution[point]);
    }
    expect(state.cursor, isNotNull);
    expect(state.isEditable(state.cursor!), isTrue);
  });

  test('typing the right letters solves the word and selects the next',
      () async {
    // Arrange
    final state = await load();
    final first = state.selectedEntry;

    // Act
    typeSelectedWord();

    // Assert
    expect(current().solved, contains(first));
    expect(current().selectedEntry, isNot(first));
  });

  test('a wrong word shows its wrong letters, then erases only them', () async {
    // Arrange
    await load();
    final index = current().selectedEntry;
    final free = current().selected.cells.where(current().isEditable).toList();

    // Act
    typeSelectedWord(wrongLast: true);
    final shown = current();
    game().typeLetter('a'); // ignored while the mistake is shown
    await Future<void>.delayed(
      CrosswordGame.errorPause + const Duration(milliseconds: 50),
    );

    // Assert
    expect(shown.wrongCells, {free.last});
    expect(shown.solved, isNot(contains(index)));
    expect(current().isShowingMistake, isFalse);
    expect(current().inputs.containsKey(free.last), isFalse);
    expect(current().inputs.containsKey(free.first), isTrue);
    expect(current().cursor, free.last);
    expect(stored.statusOf(current().selected.word).consecutiveErrors, 1);

    // Act: type the right letter
    game().typeLetter(current().crossword.solution[free.last]!);

    // Assert
    expect(current().solved, contains(index));
  });

  test('a word found without mistake lights a star', () async {
    // Arrange
    await load();
    final word = current().selected.word;

    // Act
    typeSelectedWord();
    await Future<void>.delayed(Duration.zero);

    // Assert
    expect(stored.statusOf(word).successCount, 1);
  });

  test('hint reveals the right letter and locks it', () async {
    // Arrange
    await load();
    final cursor = current().cursor!;

    // Act
    game().revealLetter();

    // Assert
    expect(current().inputs[cursor], current().crossword.solution[cursor]);
    expect(current().locked, contains(cursor));
  });

  test('solving every word completes the game and saves progress', () async {
    // Arrange
    final initial = await load();
    final toFind = [
      for (var i = 0; i < initial.totalCount; i++)
        if (!initial.solved.contains(i)) initial.crossword.entries[i].word,
    ];

    // Act
    while (!current().isComplete) {
      typeSelectedWord();
    }
    await pumpEventQueue();

    // Assert
    expect(stored.playCountOf(GameType.crossword), 1);
    for (final word in toFind) {
      expect(stored.statusOf(word).successCount, 1, reason: word);
    }
  });

  test('words that cannot cross make the game unavailable', () async {
    // Arrange
    setUpList(['bus', 'chat', 'pot']);

    // Act
    container.listen(provider, (_, __) {});
    await expectLater(
      container.read(provider.future),
      throwsA(isA<CrosswordUnavailableException>()),
    );
  });
}
