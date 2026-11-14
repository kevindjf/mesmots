import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/core/utils/audio_service.dart';
import 'package:mesmots/core/utils/haptic_service.dart';
import 'package:mesmots/core/utils/tts_service.dart';
import 'package:mesmots/features/games/domain/entities/grid_point.dart';
import 'package:mesmots/features/games/presentation/providers/word_search_game_provider.dart';
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

  setUp(() {
    repository = MockWordListRepository();
    stored = WordList.create(id: 'l1', name: 'S1', words: ['chat', 'école']);
    when(() => repository.getById('l1')).thenAnswer((_) async => stored);
    when(() => repository.update(any())).thenAnswer((invocation) async {
      stored = invocation.positionalArguments.first as WordList;
    });

    final audio = MockAudioService();
    final tts = MockTtsService();
    final haptic = MockHapticService();
    when(audio.playSuccess).thenAnswer((_) async {});
    when(audio.playLevelComplete).thenAnswer((_) async {});
    when(() => tts.speak(any())).thenAnswer((_) async {});
    when(haptic.success).thenAnswer((_) async {});
    when(haptic.light).thenAnswer((_) async {});
    when(haptic.selectionClick).thenAnswer((_) async {});

    container = ProviderContainer(overrides: [
      wordListRepositoryProvider.overrideWithValue(repository),
      audioServiceProvider.overrideWithValue(audio),
      ttsServiceProvider.overrideWithValue(tts),
      hapticServiceProvider.overrideWithValue(haptic),
    ]);
  });

  tearDown(() => container.dispose());

  Future<WordSearchGameState> load() async {
    final provider = wordSearchGameProvider('l1');
    container.listen(provider, (_, __) {});
    return container.read(provider.future);
  }

  WordSearchGame notifier() =>
      container.read(wordSearchGameProvider('l1').notifier);

  WordSearchGameState current() =>
      container.read(wordSearchGameProvider('l1')).requireValue;

  void dragOver(List<GridPoint> cells) {
    notifier()
      ..startSelection(cells.first)
      ..updateSelection(cells.last)
      ..endSelection();
  }

  test('dragging over a hidden word marks it as found', () async {
    // Arrange
    final state = await load();
    final word = state.grid.words.first;

    // Act
    dragOver(word.cells);

    // Assert
    expect(current().foundCount, 1);
    expect(current().selection, isEmpty);
  });

  test('a wrong selection is cleared without penalty', () async {
    // Arrange
    final state = await load();
    final cells = state.grid.words.first.cells;

    // Act
    dragOver(cells.sublist(0, cells.length - 1));

    // Assert
    expect(current().foundCount, 0);
    expect(current().selection, isEmpty);
    expect(stored.statusOf(state.grid.words.first.word).consecutiveErrors, 0);
  });

  test('finding every word completes the game and saves progress', () async {
    // Arrange
    final state = await load();

    // Act
    for (final word in state.grid.words) {
      dragOver(word.cells);
    }
    await Future<void>.delayed(Duration.zero);
    await pumpEventQueue();

    // Assert
    expect(current().isComplete, isTrue);
    expect(stored.statusOf('chat').successCount, 1);
    expect(stored.statusOf('école').successCount, 1);
    expect(stored.playCountOf(GameType.wordSearch), 1);
  });

  test('a drag close to 45° selects a diagonal', () async {
    // Arrange
    await load();

    // Act
    notifier()
      ..startSelection(const GridPoint(0, 0))
      ..updateSelection(const GridPoint(3, 2));

    // Assert
    expect(current().selection, const [
      GridPoint(0, 0),
      GridPoint(1, 1),
      GridPoint(2, 2),
    ]);
  });

  test('a mostly vertical drag stays in the column', () async {
    // Arrange
    await load();

    // Act
    notifier()
      ..startSelection(const GridPoint(4, 4))
      ..updateSelection(const GridPoint(0, 3));

    // Assert
    expect(current().selection, const [
      GridPoint(4, 4),
      GridPoint(3, 4),
      GridPoint(2, 4),
      GridPoint(1, 4),
      GridPoint(0, 4),
    ]);
  });
}
