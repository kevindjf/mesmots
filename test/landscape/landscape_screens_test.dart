import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/theme/app_palette.dart';
import 'package:mesmots/core/theme/app_theme.dart';
import 'package:mesmots/features/games/presentation/screens/crossword_game_screen.dart';
import 'package:mesmots/features/games/presentation/screens/fill_blanks_game_screen.dart';
import 'package:mesmots/features/games/presentation/screens/qcm_game_screen.dart';
import 'package:mesmots/features/games/presentation/screens/scramble_game_screen.dart';
import 'package:mesmots/features/games/presentation/screens/spelling_game_screen.dart';
import 'package:mesmots/features/games/presentation/screens/word_search_game_screen.dart';
import 'package:mesmots/features/games/presentation/screens/writing_game_screen.dart';
import 'package:mesmots/features/games/presentation/widgets/game_header.dart';
import 'package:mesmots/features/games/presentation/widgets/qcm_option_card.dart';
import 'package:mesmots/features/games/presentation/widgets/word_search_board.dart';
import 'package:mesmots/features/onboarding/presentation/screens/pin_setup_screen.dart';
import 'package:mesmots/features/parental/presentation/screens/parent_space_screen.dart';
import 'package:mesmots/features/parental/presentation/widgets/pin_input_dialog.dart';
import 'package:mesmots/features/parental/presentation/widgets/pin_keypad.dart';
import 'package:mesmots/features/word_lists/presentation/screens/home_screen.dart';
import 'package:mesmots/features/word_lists/presentation/screens/list_detail_screen.dart';
import 'package:mesmots/features/word_lists/presentation/screens/list_edit_screen.dart';
import 'package:mesmots/shared/widgets/child_keyboard.dart';
import 'package:mesmots/shared/widgets/game_control_button.dart';
import 'package:mesmots/shared/widgets/letter_button.dart';

import '../goldens/golden_harness.dart';

/// A screen held sideways, with the notch and home bar insets of the device.
class _Landscape {
  final Size size;
  final FakeViewPadding padding;

  const _Landscape(this.size, [this.padding = FakeViewPadding.zero]);
}

/// Phones and tablets held sideways, in logical pixels.
const _devices = <String, _Landscape>{
  'iPhone SE': _Landscape(Size(667, 375)),
  'iPhone 16': _Landscape(
    Size(852, 393),
    FakeViewPadding(left: 59, right: 59, bottom: 21),
  ),
  'Android phone': _Landscape(Size(800, 360)),
  'small Android phone': _Landscape(Size(640, 360)),
  'iPad mini': _Landscape(Size(1133, 744), FakeViewPadding(bottom: 20)),
  'Android tablet': _Landscape(Size(1280, 800)),
};

/// Words that cross into a playable grid.
final _crossword = goldenList(
  id: 'crossword',
  words: const ['maison', 'école', 'jardin', 'chapeau', 'bateau', 'oiseau'],
);

/// What the child taps in each game: it must be on screen, whole.
final _games = <String, (Widget, List<Type>)>{
  'spelling': (
    const SpellingGameScreen(listId: 'list'),
    [LetterButton, GameControlButton],
  ),
  'scramble': (
    const ScrambleGameScreen(listId: 'list'),
    [LetterButton, GameControlButton],
  ),
  'fill blanks': (
    const FillBlanksGameScreen(listId: 'list'),
    [LetterButton, GameControlButton],
  ),
  'writing': (
    const WritingGameScreen(listId: 'list'),
    [ChildKeyboard, GameControlButton],
  ),
  'qcm': (const QcmGameScreen(listId: 'list'), [QcmOptionCard]),
  'crossword': (
    CrosswordGameScreen(listId: _crossword.id),
    [ChildKeyboard],
  ),
  'word search': (
    const WordSearchGameScreen(listId: 'list'),
    [WordSearchBoard],
  ),
};

final _otherScreens = <String, Widget>{
  'home': const HomeScreen(),
  'list detail': const ListDetailScreen(listId: 'list'),
  'list editor': const ListEditScreen(listId: 'list'),
  'new list': const ListEditScreen(),
  'parent space': const ParentSpaceScreen(),
  'pin dialog': const Scaffold(body: PinInputDialog()),
};

void main() {
  setUpAll(loadGoldenFonts);

  Future<void> pumpOn(
    WidgetTester tester,
    _Landscape device,
    Widget screen,
  ) async {
    tester.view.padding = device.padding;
    tester.view.viewPadding = device.padding;
    await pumpGoldenScreen(
      tester,
      screen,
      theme: AppTheme.of(AppPalette.light),
      overrides: goldenOverrides([goldenList(), _crossword]),
      size: device.size,
    );
  }

  for (final device in _devices.entries) {
    group('held sideways on an ${device.key}', () {
      for (final game in _games.entries) {
        testWidgets('${game.key} fits the screen', (tester) async {
          // Arrange
          final (screen, controls) = game.value;
          final bounds = Offset.zero & device.value.size;

          // Act
          await pumpOn(tester, device.value, screen);

          // Assert
          // An overflow would have failed the test while pumping.
          expect(find.byType(GameHeader), findsOneWidget);
          for (final control in controls) {
            final found = find.byType(control);
            expect(found, findsWidgets, reason: '$control');
            for (final element in found.evaluate()) {
              final rect = tester.getRect(find.byWidget(element.widget));
              expect(
                bounds.intersect(rect).size,
                rect.size,
                reason: '$control at $rect is cut off',
              );
            }
          }
        });
      }

      testWidgets('onboarding fits every step', (tester) async {
        // Arrange
        final bounds = Offset.zero & device.value.size;
        Future<void> tapText(String text) async {
          await tester.ensureVisible(find.text(text));
          await tester.tap(find.text(text));
          for (var i = 0; i < 5; i++) {
            await tester.pump(const Duration(milliseconds: 300));
          }
        }

        // Act
        await pumpOn(tester, device.value, const PinSetupScreen());
        await tapText(AppStrings.start.toUpperCase());
        await tapText(AppStrings.next.toUpperCase());
        await tapText(AppStrings.next.toUpperCase());
        await tapText(AppStrings.createMyCode.toUpperCase());

        // Assert
        // An overflow on any step would have failed the test.
        final keypad = tester.getRect(find.byType(PinKeypad));
        expect(bounds.intersect(keypad).size, keypad.size);
      });

      for (final screen in _otherScreens.entries) {
        testWidgets('${screen.key} does not overflow', (tester) async {
          // Act
          await pumpOn(tester, device.value, screen.value);

          // Assert
          expect(tester.takeException(), isNull);
        });
      }
    });
  }
}
