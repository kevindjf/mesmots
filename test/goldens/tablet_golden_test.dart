@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/core/theme/app_palette.dart';
import 'package:mesmots/core/theme/app_theme.dart';
import 'package:mesmots/features/onboarding/presentation/screens/pin_setup_screen.dart';
import 'package:mesmots/features/parental/presentation/screens/parent_space_screen.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_status.dart';
import 'package:mesmots/features/word_lists/presentation/screens/home_screen.dart';
import 'package:mesmots/features/word_lists/presentation/screens/list_detail_screen.dart';
import 'package:mesmots/features/games/presentation/screens/writing_game_screen.dart';

import 'golden_harness.dart';

/// Tablets the app is laid out for, in logical pixels.
const tablets = <String, Size>{
  'ipad13': Size(1032, 1376),
  'tablet10_landscape': Size(1280, 800),
};

void main() {
  setUpAll(loadGoldenFonts);

  final lists = [
    goldenList().copyWith(lastPlayedAt: DateTime(2026, 11, 12)),
    goldenList(id: 'done', words: const ['vélo']).copyWith(
      name: 'Semaine 11',
      mastery: const {
        'vélo': WordStatus(successCount: 3, consecutiveErrors: 0),
      },
    ),
    goldenList(id: 'week10').copyWith(name: 'Semaine 10'),
    goldenList(id: 'writing', words: const ['chat']),
  ];

  final screens = <String, Widget>{
    'home': const HomeScreen(),
    'list_detail': const ListDetailScreen(listId: 'list'),
    'parent_space': const ParentSpaceScreen(),
    'pin_setup': const PinSetupScreen(),
    'writing': const WritingGameScreen(listId: 'writing'),
  };

  for (final tablet in tablets.entries) {
    for (final screen in screens.entries) {
      testWidgets('${screen.key} on ${tablet.key}', (tester) async {
        // Arrange
        await pumpGoldenScreen(
          tester,
          screen.value,
          theme: AppTheme.of(AppPalette.light),
          overrides: goldenOverrides(lists),
          size: tablet.value,
        );

        // Assert
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('images/tablet/${screen.key}_${tablet.key}.png'),
        );
      });
    }
  }
}
