// Renders the app screens used by the Play Store screenshots, with realistic
// lists and games in progress. Skipped by a plain `flutter test`; run
// tool/store_screenshots.sh, which also frames them (docs/play/screenshots/).
@Tags(['store'])
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/core/theme/app_palette.dart';
import 'package:mesmots/core/theme/app_theme.dart';
import 'package:mesmots/features/games/domain/entities/grid_point.dart'
    show WordDirection;
import 'package:mesmots/features/games/presentation/providers/crossword_game_provider.dart';
import 'package:mesmots/features/games/presentation/providers/qcm_game_provider.dart';
import 'package:mesmots/features/games/presentation/providers/spelling_game_provider.dart';
import 'package:mesmots/features/games/presentation/providers/word_search_game_provider.dart';
import 'package:mesmots/features/games/presentation/providers/writing_game_provider.dart';
import 'package:mesmots/features/games/presentation/screens/crossword_game_screen.dart';
import 'package:mesmots/features/games/presentation/screens/qcm_game_screen.dart';
import 'package:mesmots/features/games/presentation/screens/spelling_game_screen.dart';
import 'package:mesmots/features/games/presentation/screens/word_search_game_screen.dart';
import 'package:mesmots/features/games/presentation/screens/writing_game_screen.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_list.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_status.dart';
import 'package:mesmots/features/word_lists/presentation/screens/home_screen.dart';
import 'package:mesmots/features/word_lists/presentation/screens/list_detail_screen.dart';
import 'package:mesmots/features/word_lists/presentation/screens/list_edit_screen.dart';

import '../goldens/golden_harness.dart';

const _enabled = bool.fromEnvironment('STORE_SCREENSHOTS');
const _outputDir = 'build/store_screenshots/raw';

/// Logical screen of a common Android phone, rendered at 721 × 1470.
const _screenSize = Size(412, 840);
const _pixelRatio = 1.75;

/// Room for the status bar and the gesture bar drawn by the framing script.
const _topInset = 28.0;
const _bottomInset = 16.0;

WordList _list(
  String id,
  String name,
  Map<String, int> stars, {
  required DateTime lastPlayedAt,
}) {
  final list = WordList.create(id: id, name: name, words: stars.keys.toList());
  return list.copyWith(
    lastPlayedAt: lastPlayedAt,
    mastery: {
      for (final entry in stars.entries)
        entry.key: WordStatus(successCount: entry.value, consecutiveErrors: 0),
    },
  );
}

final _week12 = _list(
  'week12',
  'Semaine 12',
  const {
    'maison': 3,
    'école': 3,
    'jardin': 2,
    'chapeau': 1,
    'bateau': 3,
    'oiseau': 1,
    'gâteau': 0,
    'crayon': 2,
  },
  lastPlayedAt: DateTime(2026, 11, 12),
);

final _lists = [
  _week12,
  _list(
    'animals',
    'Les animaux',
    const {
      'lapin': 3,
      'cheval': 2,
      'poisson': 3,
      'éléphant': 1,
      'girafe': 2,
      'souris': 3,
      'tortue': 0,
    },
    lastPlayedAt: DateTime(2026, 11, 9),
  ),
  _list(
    'week11',
    'Semaine 11',
    const {
      'automne': 3,
      'feuille': 3,
      'marron': 3,
      'champignon': 3,
      'parapluie': 3,
      'écureuil': 3,
    },
    lastPlayedAt: DateTime(2026, 11, 6),
  ),
  _list(
    'week10',
    'Semaine 10',
    const {
      'famille': 3,
      'frère': 3,
      'sœur': 2,
      'grand-mère': 3,
      'cousin': 3,
      'bébé': 3,
    },
    lastPlayedAt: DateTime(2026, 10, 30),
  ),
];

final _appKey = GlobalKey();

Future<void> _pumpScreen(WidgetTester tester, Widget screen) async {
  tester.view
    ..physicalSize = _screenSize * _pixelRatio
    ..devicePixelRatio = _pixelRatio
    ..padding = const FakeViewPadding(
      top: _topInset * _pixelRatio,
      bottom: _bottomInset * _pixelRatio,
    )
    ..viewPadding = const FakeViewPadding(
      top: _topInset * _pixelRatio,
      bottom: _bottomInset * _pixelRatio,
    );
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    RepaintBoundary(
      key: _appKey,
      child: ProviderScope(
        overrides: goldenOverrides(_lists),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: _theme(),
          home: screen,
        ),
      ),
    ),
  );
  await _settle(tester);
}

/// Lets SVGs load and timers/animations run.
Future<void> _settle(WidgetTester tester, {int steps = 10}) async {
  await tester
      .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
  for (var i = 0; i < steps; i++) {
    await tester.pump(const Duration(milliseconds: 300));
  }
}

ProviderContainer _container(WidgetTester tester, Type screen) =>
    ProviderScope.containerOf(tester.element(find.byType(screen)));

Future<void> _capture(WidgetTester tester, String name) async {
  final boundary =
      tester.renderObject<RenderRepaintBoundary>(find.byKey(_appKey));
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: _pixelRatio);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('$_outputDir/$name.png')..createSync(recursive: true);
    file.writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

/// Let pending game timers finish, so the test ends cleanly.
Future<void> _drain(WidgetTester tester) => _settle(tester, steps: 12);

/// Material icons from the Flutter SDK given by the run script, and a
/// system font for the symbols Fredoka lacks (→), as the phone falls back
/// to its own.
Future<void> _loadExtraFonts() async {
  Future<void> load(String family, String path) async {
    final file = File(path);
    if (!file.existsSync()) return;
    final loader = FontLoader(family)
      ..addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
    await loader.load();
  }

  await load(
    'MaterialIcons',
    '${const String.fromEnvironment('FLUTTER_ROOT')}'
        '/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  await load('Symbols', '/System/Library/Fonts/Supplemental/Arial Bold.ttf');
}

ThemeData _theme() {
  final theme = AppTheme.of(AppPalette.light);
  return theme.copyWith(
    textTheme: theme.textTheme.apply(fontFamilyFallback: const ['Symbols']),
  );
}

void main() {
  setUpAll(() async {
    await loadGoldenFonts();
    await _loadExtraFonts();
  });

  testWidgets('01 home', skip: !_enabled, (tester) async {
    await _pumpScreen(tester, const HomeScreen());
    await _capture(tester, '01-home');
  });

  testWidgets('02 new list', skip: !_enabled, (tester) async {
    await _pumpScreen(tester, const ListEditScreen());
    final fields = find.byType(TextField);
    await tester.enterText(fields.first, 'Semaine 13');
    for (final word in [
      'hiver',
      'neige',
      'bonnet',
      'écharpe',
      'sapin',
      'cadeau',
      'bougie',
    ]) {
      await tester.enterText(fields.at(1), word);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump(const Duration(milliseconds: 300));
    }
    FocusManager.instance.primaryFocus?.unfocus();
    await _settle(tester);
    await _capture(tester, '02-newlist');
    await _drain(tester);
  });

  testWidgets('03 games', skip: !_enabled, (tester) async {
    await _pumpScreen(tester, ListDetailScreen(listId: _week12.id));
    await _capture(tester, '03-games');
  });

  testWidgets('04 qcm', skip: !_enabled, (tester) async {
    await _pumpScreen(tester, QcmGameScreen(listId: _week12.id));
    final notifier = _container(tester, QcmGameScreen)
        .read(qcmGameProvider(_week12.id).notifier);
    String right() => _container(tester, QcmGameScreen)
        .read(qcmGameProvider(_week12.id))
        .requireValue
        .question!
        .options
        .firstWhere((option) => option.isCorrect)
        .text;
    for (var i = 0; i < 3; i++) {
      notifier.answer(right()).ignore();
      await _settle(tester, steps: 6);
    }
    // The right answer just picked, shown in green.
    notifier.answer(right()).ignore();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 200));
    await _capture(tester, '04-qcm');
    await _drain(tester);
  });

  testWidgets('05 spelling', skip: !_enabled, (tester) async {
    await _pumpScreen(tester, SpellingGameScreen(listId: _week12.id));
    final engine = _container(tester, SpellingGameScreen)
        .read(spellingGameProvider(_week12.id).notifier)
        .engine;
    int filled() =>
        engine.state.puzzle!.slots.where((slot) => slot != null).length;
    for (var word = 0; word < 2; word++) {
      final slots = engine.state.puzzle!.slots.length;
      for (var i = 0; i < slots; i++) {
        engine.hint();
        await tester.pump(const Duration(milliseconds: 100));
      }
      await _settle(tester, steps: 15);
    }
    while (filled() < 3) {
      engine.hint();
      await tester.pump(const Duration(milliseconds: 100));
    }
    await _settle(tester, steps: 15);
    await _capture(tester, '05-spelling');
    await _drain(tester);
  });

  testWidgets('06 writing', skip: !_enabled, (tester) async {
    await _pumpScreen(tester, WritingGameScreen(listId: _week12.id));
    final container = _container(tester, WritingGameScreen);
    final notifier = container.read(writingGameProvider(_week12.id).notifier);
    String word() => container
        .read(writingGameProvider(_week12.id))
        .requireValue
        .question!
        .word;
    for (var i = 0; i < 3; i++) {
      for (final letter in word().split('')) {
        notifier.type(letter);
      }
      notifier.submit().ignore();
      await _settle(tester, steps: 8);
    }
    for (final letter in word().split('').take(3)) {
      notifier.type(letter);
    }
    await _settle(tester, steps: 3);
    await _capture(tester, '06-writing');
    await _drain(tester);
  });

  testWidgets('07 word search', skip: !_enabled, (tester) async {
    await _pumpScreen(tester, WordSearchGameScreen(listId: _week12.id));
    final container = _container(tester, WordSearchGameScreen);
    final provider = wordSearchGameProvider(_week12.id);
    // Draw grids until one has a diagonal word.
    for (var i = 0; i < 100; i++) {
      final grid = container.read(provider).requireValue.grid;
      if (grid.words.any((w) => w.direction == WordDirection.diagonal)) break;
      container.invalidate(provider);
      await _settle(tester, steps: 1);
    }
    final grid = container.read(provider).requireValue.grid;
    final words = [
      for (final direction in [
        WordDirection.diagonal,
        WordDirection.horizontal,
        WordDirection.vertical,
      ])
        ...grid.words.where((w) => w.direction == direction).take(1),
    ];
    expect(words.first.direction, WordDirection.diagonal);
    // The diagonal word and two others found.
    for (final word in words) {
      container.read(provider.notifier)
        ..tapCell(word.cells.first)
        ..tapCell(word.cells.last);
      await _settle(tester, steps: 4);
    }
    await _settle(tester);
    await _capture(tester, '07-wordsearch');
    await _drain(tester);
  });

  testWidgets('08 crossword', skip: !_enabled, (tester) async {
    await _pumpScreen(tester, CrosswordGameScreen(listId: _week12.id));
    final container = _container(tester, CrosswordGameScreen);
    final provider = crosswordGameProvider(_week12.id);
    final notifier = container.read(provider.notifier);
    CrosswordGameState state() => container.read(provider).requireValue;
    void typeNext() {
      final cursor = state().cursor!;
      notifier.typeLetter(state().crossword.solution[cursor]!);
    }

    for (var solved = 0; solved < 2; solved++) {
      final entry = state().selectedEntry;
      while (!state().solved.contains(entry) && state().cursor != null) {
        typeNext();
        await tester.pump(const Duration(milliseconds: 100));
      }
      await _settle(tester, steps: 6);
    }
    for (var i = 0; i < 2 && state().cursor != null; i++) {
      typeNext();
      await tester.pump(const Duration(milliseconds: 100));
    }
    await _settle(tester, steps: 4);
    await _capture(tester, '08-crossword');
    await _drain(tester);
  });
}
