import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/core/constants/app_breakpoints.dart';
import 'package:mesmots/features/games/presentation/widgets/game_header.dart';
import 'package:mesmots/features/games/presentation/widgets/game_layout.dart';
import 'package:mesmots/shared/widgets/circle_icon_button.dart';

void main() {
  const portrait = Key('portrait');
  const prompt = Key('prompt');
  const answer = Key('answer');

  Future<void> pumpOn(
    WidgetTester tester,
    Size size, {
    bool squarePrompt = false,
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GameLayout(
            squarePrompt: squarePrompt,
            progress: 0.5,
            validatedCount: 1,
            totalCount: 2,
            portrait: const SizedBox.expand(key: portrait),
            prompt: const SizedBox.expand(key: prompt),
            answer: const SizedBox.expand(key: answer),
          ),
        ),
      ),
    );
  }

  testWidgets('puts the close button on the progress line', (tester) async {
    // Arrange
    const phone = Size(390, 844);

    // Act
    await pumpOn(tester, phone);

    // Assert
    final close = tester.getRect(find.byType(CircleIconButton));
    final header = tester.getRect(find.byType(GameHeader));
    expect(close.right, lessThanOrEqualTo(header.left));
    expect(close.center.dy, closeTo(header.center.dy, 1));
  });

  testWidgets('shows the portrait content below the progress, upright',
      (tester) async {
    // Arrange
    const phone = Size(390, 844);

    // Act
    await pumpOn(tester, phone);

    // Assert
    expect(find.byKey(portrait), findsOneWidget);
    expect(find.byKey(prompt), findsNothing);
    expect(find.byKey(answer), findsNothing);
    final header = tester.getRect(find.byType(GameHeader));
    expect(
      tester.getRect(find.byKey(portrait)).top,
      greaterThanOrEqualTo(header.bottom),
    );
    expect(tester.widget<GameHeader>(find.byType(GameHeader)).compact, isFalse);
  });

  testWidgets('puts the answer next to the prompt, sideways', (tester) async {
    // Arrange
    const phone = Size(852, 393);

    // Act
    await pumpOn(tester, phone);

    // Assert
    expect(find.byKey(portrait), findsNothing);
    final promptRect = tester.getRect(find.byKey(prompt));
    final answerRect = tester.getRect(find.byKey(answer));
    expect(answerRect.left, greaterThanOrEqualTo(promptRect.right));
    expect(answerRect.width, AppBreakpoints.sidePanelWidth);
    // The answer pane is as tall as the screen, the header sits on the left.
    expect(answerRect.height, phone.height);
    expect(
      tester.getRect(find.byType(GameHeader)).right,
      lessThanOrEqualTo(promptRect.right),
    );
    expect(tester.widget<GameHeader>(find.byType(GameHeader)).compact, isTrue);
  });

  testWidgets('keeps room for the prompt on a narrow screen held sideways',
      (tester) async {
    // Arrange
    const narrow = Size(600, 360);

    // Act
    await pumpOn(tester, narrow);

    // Assert
    final answerRect = tester.getRect(find.byKey(answer));
    expect(
      answerRect.width,
      narrow.width * AppBreakpoints.sidePanelMaxFraction,
    );
  });

  testWidgets('a square prompt takes the whole height, sideways',
      (tester) async {
    // Arrange
    const phone = Size(923, 412);

    // Act
    await pumpOn(tester, phone, squarePrompt: true);

    // Assert
    final promptRect = tester.getRect(find.byKey(prompt));
    final answerRect = tester.getRect(find.byKey(answer));
    final header = tester.getRect(find.byType(GameHeader));
    expect(promptRect.width, phone.height);
    expect(promptRect.height, phone.height);
    expect(header.left, greaterThanOrEqualTo(promptRect.right));
    expect(answerRect.top, greaterThanOrEqualTo(header.bottom));
  });

  testWidgets('a square prompt leaves room for the answer, sideways',
      (tester) async {
    // Arrange
    const narrow = Size(480, 320);

    // Act
    await pumpOn(tester, narrow, squarePrompt: true);

    // Assert
    expect(
      tester.getRect(find.byKey(answer)).width,
      AppBreakpoints.sidePanelMinWidth,
    );
  });
}
