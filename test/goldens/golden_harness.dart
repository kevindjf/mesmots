import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/core/utils/audio_service.dart';
import 'package:mesmots/core/utils/haptic_service.dart';
import 'package:mesmots/core/utils/tts_service.dart';
import 'package:mesmots/features/word_lists/data/repositories/word_list_repository_impl.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_list.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_status.dart';
import 'package:mesmots/features/word_lists/domain/repositories/word_list_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepository extends Mock implements WordListRepository {}

class _MockTts extends Mock implements TtsService {}

class _MockAudio extends Mock implements AudioService {}

class _MockHaptic extends Mock implements HapticService {}

/// Phone-sized surface, at a pixel ratio of 1 to keep the images small.
const goldenSize = Size(390, 844);

/// Loads the real fonts, so goldens show text instead of Ahem boxes.
Future<void> loadGoldenFonts() async {
  Future<void> load(String family, List<String> paths) async {
    final loader = FontLoader(family);
    for (final path in paths) {
      loader.addFont(
        Future.value(ByteData.sublistView(File(path).readAsBytesSync())),
      );
    }
    await loader.load();
  }

  await load('Fredoka', [
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold'])
      'assets/fonts/Fredoka-$weight.ttf',
  ]);
  final flutterRoot = File(Platform.resolvedExecutable).parent.parent.parent
      .parent.parent.parent.path;
  final icons =
      '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf';
  if (File(icons).existsSync()) await load('MaterialIcons', [icons]);
}

/// A list with some progress, so cards, stars and chips show every state.
WordList goldenList({String id = 'list', List<String>? words}) {
  final list = WordList.create(
    id: id,
    name: 'Semaine 12',
    words: words ?? const ['maison', 'école', 'chat', 'jardin'],
  );
  return list.copyWith(
    mastery: {
      ...list.mastery,
      if (list.words.length > 1) ...{
        list.words.first:
            const WordStatus(successCount: 3, consecutiveErrors: 0),
        list.words[1]: const WordStatus(successCount: 1, consecutiveErrors: 0),
      },
    },
  );
}

/// Overrides the repository and the device services with silent mocks.
List<Override> goldenOverrides(List<WordList> lists) {
  final repository = _MockRepository();
  final tts = _MockTts();
  final audio = _MockAudio();
  final haptic = _MockHaptic();
  registerFallbackValue(lists.first);
  when(() => repository.getById(any())).thenAnswer(
    (invocation) async => lists.firstWhere(
      (list) => list.id == invocation.positionalArguments.first,
    ),
  );
  when(() => repository.watchAll()).thenAnswer((_) => Stream.value(lists));
  when(() => repository.watchById(any())).thenAnswer(
    (invocation) => Stream.value(
      lists.firstWhere(
        (list) => list.id == invocation.positionalArguments.first,
      ),
    ),
  );
  when(() => repository.update(any())).thenAnswer((_) async {});
  when(() => tts.speak(any())).thenAnswer((_) async {});
  when(() => tts.stop()).thenAnswer((_) async {});
  for (final call in [
    audio.playSuccess,
    audio.playStar,
    audio.playError,
    audio.playWordComplete,
    audio.playLevelComplete,
    audio.playTap,
    haptic.success,
    haptic.error,
    haptic.light,
    haptic.medium,
    haptic.selectionClick,
  ]) {
    when(call).thenAnswer((_) async {});
  }
  return [
    wordListRepositoryProvider.overrideWithValue(repository),
    ttsServiceProvider.overrideWithValue(tts),
    audioServiceProvider.overrideWithValue(audio),
    hapticServiceProvider.overrideWithValue(haptic),
  ];
}

/// Pumps [screen] full-size with [theme] and lets entrance animations end.
Future<void> pumpGoldenScreen(
  WidgetTester tester,
  Widget screen, {
  required ThemeData theme,
  List<Override> overrides = const [],
}) async {
  tester.view
    ..physicalSize = goldenSize
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: screen,
      ),
    ),
  );
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 300));
  }
}
