import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/core/utils/audio_service.dart';
import 'package:mesmots/core/utils/haptic_service.dart';
import 'package:mesmots/core/utils/tts_service.dart';
import 'package:mesmots/features/games/presentation/providers/writing_game_provider.dart';
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
    list = WordList.create(id: listId, name: 'Semaine', words: const ['école']);
    when(() => repository.getById(listId)).thenAnswer((_) async => list);
    when(() => repository.update(any())).thenAnswer((invocation) async {
      list = invocation.positionalArguments.first as WordList;
    });
    when(() => tts.speak(any())).thenAnswer((_) async {});
    when(() => tts.stop()).thenAnswer((_) async {});
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
    container.listen(writingGameProvider(listId), (_, __) {});
  });

  WritingGame game() => container.read(writingGameProvider(listId).notifier);

  WritingGameState state() =>
      container.read(writingGameProvider(listId)).value!;

  Future<void> start() => container.read(writingGameProvider(listId).future);

  void typeWord(String word) {
    for (final letter in word.split('')) {
      game().type(letter);
    }
  }

  test('a right word lights a star', () async {
    // Arrange
    await start();
    typeWord('école');

    // Act
    final submitting = game().submit();
    await Future<void>.delayed(Duration.zero);

    // Assert
    expect(state().question!.phase, WritingPhase.correct);
    expect(state().stars, 1);
    await submitting;
  });

  test('a mistake is marked letter by letter, then the word is copied',
      () async {
    // Arrange
    await start();
    typeWord('ecole');

    // Act
    final submitting = game().submit();
    await Future<void>.delayed(Duration.zero);
    final shown = state().question!;
    game().type('x'); // ignored while shown
    await submitting;

    // Assert
    expect(shown.phase, WritingPhase.wrong);
    expect(shown.marks, [false, true, true, true, true]);
    expect(shown.input, 'ecole');
    expect(state().question!.isCopying, isTrue);
    expect(state().question!.input, isEmpty);
    expect(list.statusOf('école').consecutiveErrors, 1);
  });

  test('a copied word gives no star', () async {
    // Arrange: a mistake, then the copy
    await start();
    typeWord('ecole');
    await game().submit();
    typeWord('école');

    // Act
    final submitting = game().submit();
    await Future<void>.delayed(Duration.zero);

    // Assert
    expect(state().question!.phase, WritingPhase.correct);
    expect(state().stars, 0);
    await submitting;
  });

  test('help keeps the right beginning and adds the next letter', () async {
    // Arrange
    await start();
    typeWord('écx');

    // Act
    game().hint();

    // Assert
    expect(state().question!.input, 'éco');
  });
}
