import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/core/utils/audio_service.dart';
import 'package:mesmots/core/utils/haptic_service.dart';
import 'package:mesmots/core/utils/tts_service.dart';
import 'package:mesmots/features/games/presentation/providers/qcm_game_provider.dart';
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
  late _MockRepository repository;
  late _MockTts tts;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(
      WordList.create(id: 'x', name: 'x', words: const ['x']),
    );
  });

  setUp(() {
    repository = _MockRepository();
    tts = _MockTts();
    final audio = _MockAudio();
    final haptic = _MockHaptic();
    var list = WordList.create(
      id: listId,
      name: 'Semaine',
      words: const ['maison', 'école'],
    );
    when(() => repository.getById(listId)).thenAnswer((_) async => list);
    when(() => repository.update(any())).thenAnswer((invocation) async {
      list = invocation.positionalArguments.first as WordList;
    });
    when(() => tts.speak(any())).thenAnswer((_) async {});
    when(() => tts.stop()).thenAnswer((_) async {});
    for (final call in [
      audio.playSuccess,
      audio.playStar,
      audio.playError,
      audio.playWordComplete,
      audio.playLevelComplete,
      haptic.success,
      haptic.error,
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
    // Keep the auto-disposed game alive between reads.
    container.listen(qcmGameProvider(listId), (_, __) {});
  });

  Future<QcmQuestion> currentQuestion() async =>
      (await container.read(qcmGameProvider(listId).future)).question!;

  QcmGame game() => container.read(qcmGameProvider(listId).notifier);

  String wrongOption(QcmQuestion q) =>
      q.options.firstWhere((o) => !o.isCorrect).text;

  test('ignores a second tap while the answer is shown', () async {
    // Arrange
    final question = await currentQuestion();

    // Act
    final first = game().answer(question.word);
    await Future<void>.delayed(Duration.zero);
    final second = game().answer(wrongOption(question));
    await Future.wait([first, second]);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    // Assert: one success recorded, no error
    final saved = await repository.getById(listId);
    expect(saved!.statusOf(question.word).successCount, 1);
    expect(saved.statusOf(question.word).consecutiveErrors, 0);
  });

  test('keeps the wrong pick visible and reads the right word', () async {
    // Arrange
    final question = await currentQuestion();
    final wrong = wrongOption(question);
    clearInteractions(tts);

    // Act
    final answering = game().answer(wrong);
    await Future<void>.delayed(Duration.zero);
    final shown = container.read(qcmGameProvider(listId)).value!.question!;

    // Assert
    expect(shown.selected, wrong);
    expect(shown.isAnswered, isTrue);
    verify(() => tts.speak(question.word)).called(1);
    await answering;
  });

  test('a right answer lights one more mastery star', () async {
    // Arrange
    final question = await currentQuestion();

    // Act
    final answering = game().answer(question.word);
    await Future<void>.delayed(Duration.zero);
    final shown = container.read(qcmGameProvider(listId)).value!.question!;
    await answering;

    // Assert
    expect(question.stars, 0);
    expect(shown.stars, 1);
  });
}
