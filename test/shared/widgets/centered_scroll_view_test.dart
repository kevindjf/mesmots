import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/shared/widgets/centered_scroll_view.dart';

void main() {
  const content = Key('content');

  Future<void> pumpOn(WidgetTester tester, Size size, double height) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CenteredScrollView(
            child: SizedBox(key: content, width: 100, height: height),
          ),
        ),
      ),
    );
  }

  testWidgets('keeps the content at the top on a phone', (tester) async {
    // Arrange
    await pumpOn(tester, const Size(412, 840), 200);

    // Act
    final top = tester.getTopLeft(find.byKey(content)).dy;

    // Assert
    expect(top, 0);
  });

  testWidgets('centers short content on a tablet', (tester) async {
    // Arrange
    await pumpOn(tester, const Size(800, 1280), 200);

    // Act
    final center = tester.getCenter(find.byKey(content)).dy;

    // Assert
    expect(center, 640);
  });

  testWidgets('scrolls content taller than a tablet', (tester) async {
    // Arrange
    await pumpOn(tester, const Size(800, 1280), 2000);

    // Act
    await tester.drag(find.byKey(content), const Offset(0, -500));
    await tester.pump();

    // Assert
    expect(tester.getTopLeft(find.byKey(content)).dy, -500);
  });
}
