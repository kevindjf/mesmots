import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/core/utils/audio_service.dart';
import 'package:mesmots/core/utils/haptic_service.dart';
import 'package:mesmots/core/utils/tts_service.dart';
import 'package:mesmots/features/games/presentation/providers/scramble_game_provider.dart';
import 'package:mesmots/features/word_lists/data/repositories/word_list_repository_impl.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_list.dart';
import 'package:mesmots/features/word_lists/domain/repositories/word_list_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepository extends Mock implements WordListRepository {}

class _MockTts extends Mock implements TtsService {}

class _MockAudio extends Mock implements AudioService {}

class _MockHaptic extends Mock implements HapticService {}

void main() {
  const listId = 'list';
  late WordList list;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(
      WordList.create(id: 'x', name: 'x', words: const ['x']),
    );
  });

  setUp(() {
    final repository = _MockRepository();
    final tts = _MockTts();
    final audio = _MockAudio();
    final haptic = _MockHaptic();
    list = WordList.create(id: listId, name: 'Semaine', words: const ['chat']);
    when(() => repository.getById(listId)).thenAnswer((_) async => list);
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
    container = ProviderContainer(
      overrides: [
        wordListRepositoryProvider.overrideWithValue(repository),
        ttsServiceProvider.overrideWithValue(tts),
        audioServiceProvider.overrideWithValue(audio),
        hapticServiceProvider.overrideWithValue(haptic),
      ],
    );
    addTearDown(container.dispose);
    container.listen(scrambleGameProvider(listId), (_, __) {});
  });

  ScrambleGame game() => container.read(scrambleGameProvider(listId).notifier);

  ScrambleQuestion question() =>
      container.read(scrambleGameProvider(listId)).value!.question!;

  /// Tile indices spelling [word] with the current tiles.
  List<int> tilesFor(String word) {
    final tiles = [...question().tiles];
    final indices = <int>[];
    for (final letter in word.split('')) {
      final i = tiles.indexOf(letter);
      indices.add(i);
      tiles[i] = '';
    }
    return indices;
  }

  Future<void> start() => container.read(scrambleGameProvider(listId).future);

  test('fills slots in order and lets a letter be taken back', () async {
    // Arrange
    await start();
    final tiles = tilesFor('chat');

    // Act
    game().placeTile(tiles[0]);
    game().placeTile(tiles[1]);
    game().removeSlot(0);

    // Assert
    expect(question().letterAt(0), isNull);
    expect(question().letterAt(1), 'h');
  });

  test('checks the word when the last slot is filled', () async {
    // Arrange
    await start();

    // Act
    for (final tile in tilesFor('chat')) {
      game().placeTile(tile);
    }

    // Assert
    expect(question().phase, ScramblePhase.correct);
    expect(question().stars, 1);
  });

  test('after a mistake, keeps the right letters and ignores taps',
      () async {
    // Arrange
    await start();

    // Act: "chta" instead of "chat"
    for (final tile in tilesFor('chta')) {
      game().placeTile(tile);
    }
    final shown = question();
    game().removeSlot(0);

    // Assert
    expect(shown.phase, ScramblePhase.wrong);
    expect(shown.wrongSlots, {2, 3});
    expect(question().letterAt(0), 'c', reason: 'taps ignored while shown');

    // Act: wait for the pause
    await Future<void>.delayed(const Duration(seconds: 2));

    // Assert
    expect(question().phase, ScramblePhase.playing);
    expect(question().lockedSlots, {0, 1});
    expect(question().letterAt(2), isNull);
    expect(list.statusOf('chat').consecutiveErrors, 1);
  });

  test('the help places the next right letter and locks it', () async {
    // Arrange
    await start();
    final tiles = tilesFor('a');
    game().placeTile(tiles[0]); // "a" in slot 0: wrong

    // Act
    game().hint();

    // Assert
    expect(question().letterAt(0), 'c');
    expect(question().lockedSlots, {0});
  });
}
