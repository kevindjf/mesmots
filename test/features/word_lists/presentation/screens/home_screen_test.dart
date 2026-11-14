import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_list.dart';
import 'package:mesmots/features/word_lists/presentation/providers/word_list_providers.dart';
import 'package:mesmots/features/word_lists/presentation/screens/home_screen.dart';
import 'package:mesmots/features/word_lists/presentation/widgets/word_list_card.dart';
import 'package:mesmots/shared/widgets/adaptive_scale.dart';

WordList _list(String name, {DateTime? playedAt, DateTime? updatedAt}) =>
    WordList.create(id: name, name: name, words: const ['chat']).copyWith(
      lastPlayedAt: playedAt,
      updatedAt: updatedAt,
    );

void main() {
  Future<void> pumpHome(WidgetTester tester, List<WordList> lists) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          wordListsProvider.overrideWith((ref) => Stream.value(lists)),
        ],
        child: const MaterialApp(
          builder: AdaptiveScale.builder,
          home: HomeScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  List<String> cardNames(WidgetTester tester) => tester
      .widgetList<WordListCard>(find.byType(WordListCard))
      .map((card) => card.wordList.name)
      .toList();

  testWidgets(
      'the list played last comes first, even if another was edited '
      'after', (tester) async {
    // Arrange
    final lists = [
      _list('Semaine 10', playedAt: DateTime(2026, 11, 1)),
      _list('Semaine 11', playedAt: DateTime(2026, 11, 10)),
      // Edited today but never played.
      _list('Semaine 12', updatedAt: DateTime(2026, 11, 13)),
    ];

    // Act
    await pumpHome(tester, lists);

    // Assert
    expect(cardNames(tester).first, 'Semaine 11');
    expect(cardNames(tester).sublist(1), ['Semaine 10', 'Semaine 12']);
    expect(find.text(AppStrings.currentList), findsOneWidget);
    expect(find.text(AppStrings.otherLists), findsOneWidget);
  });

  testWidgets('before any game, lists show under "your lists"', (tester) async {
    // Act
    await pumpHome(tester, [_list('Semaine 12'), _list('Semaine 11')]);

    // Assert
    expect(find.byType(WordListCard), findsNWidgets(2));
    expect(find.text(AppStrings.yourLists), findsOneWidget);
    expect(find.text(AppStrings.currentList), findsNothing);
    expect(find.text(AppStrings.otherLists), findsNothing);
  });

  testWidgets('a single played list has no "other lists" title',
      (tester) async {
    // Act
    await pumpHome(tester, [_list('Semaine 12', playedAt: DateTime(2026))]);

    // Assert
    expect(find.text(AppStrings.currentList), findsOneWidget);
    expect(find.text(AppStrings.otherLists), findsNothing);
  });

  testWidgets('shows the other lists two per row on a tablet', (tester) async {
    // Arrange
    tester.view
      ..physicalSize = const Size(1032, 1376)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final lists = [
      _list('Semaine 12', playedAt: DateTime(2026, 11, 12)),
      _list('Semaine 11'),
      _list('Semaine 10'),
      _list('Semaine 9'),
    ];

    // Act
    await pumpHome(tester, lists);
    final cards = [
      for (var i = 0; i < lists.length; i++)
        tester.getRect(find.byType(WordListCard).at(i)),
    ];

    // Assert
    // The current list, then the three others: two, then one.
    expect(cards[2].top, cards[1].top);
    expect(cards[2].left, greaterThan(cards[1].right));
    expect(cards[3].top, greaterThanOrEqualTo(cards[1].bottom));
  });
}
