import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/core/utils/haptic_service.dart';
import 'package:mesmots/core/utils/tts_service.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_list.dart';
import 'package:mesmots/features/word_lists/presentation/widgets/word_list_panel.dart';
import 'package:mesmots/features/word_lists/presentation/widgets/word_preview_sheet.dart';
import 'package:mocktail/mocktail.dart';

class _MockTts extends Mock implements TtsService {}

class _MockHaptic extends Mock implements HapticService {}

void main() {
  late _MockTts tts;

  setUp(() {
    tts = _MockTts();
    when(() => tts.speak(any())).thenAnswer((_) async {});
    when(() => tts.stop()).thenAnswer((_) async {});
  });

  Future<void> pump(WidgetTester tester) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          ttsServiceProvider.overrideWithValue(tts),
          hapticServiceProvider.overrideWithValue(_MockHaptic()),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: WordListPanel(
              wordList: WordList.create(
                id: 'l',
                name: 'Semaine',
                words: const ['sept', 'voiture'],
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('words are folded until the bar is tapped', (tester) async {
    // Arrange
    await pump(tester);
    final folded = find.text('voiture').evaluate().isEmpty;

    // Act
    await tester.tap(find.textContaining('2 mots'));
    await tester.pumpAndSettle();

    // Assert
    expect(folded, isTrue);
    expect(find.text('voiture'), findsOneWidget);
  });

  testWidgets('tapping a word opens it without reading it aloud',
      (tester) async {
    // Arrange
    await pump(tester);
    await tester.tap(find.textContaining('2 mots'));
    await tester.pumpAndSettle();

    // Act
    await tester.tap(find.text('sept'));
    await tester.pumpAndSettle();

    // Assert
    expect(find.byType(WordPreviewSheet), findsOneWidget);
    verifyNever(() => tts.speak(any()));
  });
}
