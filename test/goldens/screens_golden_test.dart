@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/core/theme/app_palette.dart';
import 'package:mesmots/core/theme/app_theme.dart';
import 'package:mesmots/features/appearance/presentation/widgets/appearance_section.dart';
import 'package:mesmots/features/games/presentation/screens/scramble_game_screen.dart';
import 'package:mesmots/features/games/presentation/screens/writing_game_screen.dart';
import 'package:mesmots/features/onboarding/presentation/screens/pin_setup_screen.dart';
import 'package:mesmots/features/parental/presentation/screens/parent_space_screen.dart';
import 'package:mesmots/features/word_lists/presentation/screens/home_screen.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_status.dart';
import 'package:mesmots/features/word_lists/presentation/screens/list_detail_screen.dart';

import 'package:mesmots/shared/widgets/gradient_background.dart';

import 'golden_harness.dart';

/// Every theme the app offers, each checked against its own goldens.
final themes = <String, ThemeData>{
  'turquoise': AppTheme.lightTheme,
  'light': AppTheme.of(AppPalette.light),
  'dark': AppTheme.of(AppPalette.dark),
};

void main() {
  setUpAll(loadGoldenFonts);

  final lists = [
    goldenList(),
    goldenList(id: 'done', words: const ['vélo']).copyWith(
      name: 'Semaine 11',
      mastery: const {
        'vélo': WordStatus(successCount: 3, consecutiveErrors: 0),
      },
    ),
    // One word, so the game always starts on it; same letter repeated, so
    // the shuffled tiles look the same on every run.
    goldenList(id: 'scramble', words: const ['aaaa']),
    goldenList(id: 'writing', words: const ['chat']),
  ];

  final screens = <String, Widget>{
    'home': const HomeScreen(),
    'list_detail': const ListDetailScreen(listId: 'list'),
    'parent_space': const ParentSpaceScreen(),
    'scramble': const ScrambleGameScreen(listId: 'scramble'),
    'writing': const WritingGameScreen(listId: 'writing'),
    'pin_setup': const PinSetupScreen(),
    'appearance': const Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: AppearanceSection(),
          ),
        ),
      ),
    ),
  };

  for (final theme in themes.entries) {
    for (final screen in screens.entries) {
      testWidgets('${screen.key} in ${theme.key} theme', (tester) async {
        // Arrange
        await pumpGoldenScreen(
          tester,
          screen.value,
          theme: theme.value,
          overrides: goldenOverrides(lists),
        );
        if (screen.key == 'scramble') {
          // Place one letter, so both placed and free tiles show.
          await tester.tap(find.text('a').last);
          for (var i = 0; i < 6; i++) {
            await tester.pump(const Duration(milliseconds: 300));
          }
        }

        // Assert
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('images/${screen.key}_${theme.key}.png'),
        );
      });
    }
  }
}
