import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/core/utils/tts_service.dart';
import 'package:mesmots/features/word_lists/presentation/widgets/edit_word_item.dart';
import 'package:mocktail/mocktail.dart';

class _MockTts extends Mock implements TtsService {}

void main() {
  late _MockTts tts;
  late bool deleted;

  setUp(() {
    tts = _MockTts();
    deleted = false;
    when(() => tts.speak(any())).thenAnswer((_) async {});
    when(() => tts.stop()).thenAnswer((_) async {});
    when(() => tts.spell(any(), onLetter: any(named: 'onLetter')))
        .thenAnswer((_) async {});
  });

  Future<void> pump(WidgetTester tester) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [ttsServiceProvider.overrideWithValue(tts)],
        child: MaterialApp(
          home: Scaffold(
            body: EditWordItem(
              word: 'sept',
              colorIndex: 0,
              onDelete: () => deleted = true,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('the parent can hear the word', (tester) async {
    // Arrange
    await pump(tester);

    // Act
    await tester.tap(find.byIcon(Icons.volume_up_rounded));

    // Assert
    verify(() => tts.speak('sept')).called(1);
  });

  testWidgets('the parent can hear the word spelled', (tester) async {
    // Arrange
    await pump(tester);

    // Act
    await tester.tap(find.byIcon(Icons.abc_rounded));

    // Assert
    verify(() => tts.spell('sept', onLetter: any(named: 'onLetter')))
        .called(1);
  });

  testWidgets('the parent can remove the word', (tester) async {
    // Arrange
    await pump(tester);

    // Act
    await tester.tap(find.byIcon(Icons.close));

    // Assert
    expect(deleted, isTrue);
  });
}
