import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/shared/widgets/highlighted_word.dart';

void main() {
  const style = TextStyle(fontSize: 20);

  Future<void> pumpIn(WidgetTester tester, double width, String word) =>
      tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox(
              width: width,
              child: HighlightedWord(word: word, position: null, style: style),
            ),
          ),
        ),
      );

  double fontSizeOf(WidgetTester tester) =>
      tester.widget<RichText>(find.byType(RichText)).text.style!.fontSize!;

  int lineCount(WidgetTester tester) {
    final height = tester.getSize(find.byType(RichText)).height;
    return (height / (fontSizeOf(tester) * 1.2)).round();
  }

  testWidgets('keeps its size when it fits', (tester) async {
    // Act
    await pumpIn(tester, 300, 'chat');

    // Assert
    expect(fontSizeOf(tester), 20);
  });

  testWidgets('shrinks a long word to stay on one line', (tester) async {
    // Act
    await pumpIn(tester, 200, 'hypocondriaque');

    // Assert
    expect(fontSizeOf(tester), lessThan(20));
    expect(fontSizeOf(tester), greaterThanOrEqualTo(20 * 0.6));
    expect(lineCount(tester), 1);
  });

  testWidgets('wraps at the smallest size past it', (tester) async {
    // Act
    await pumpIn(tester, 100, 'anticonstitutionnellement');

    // Assert
    expect(fontSizeOf(tester), closeTo(20 * 0.6, 0.01));
    expect(lineCount(tester), greaterThan(1));
  });
}
