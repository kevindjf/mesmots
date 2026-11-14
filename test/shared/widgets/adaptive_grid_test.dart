import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/shared/widgets/adaptive_grid.dart';

void main() {
  Future<void> pumpGrid(WidgetTester tester, double width) async {
    tester.view
      ..physicalSize = const Size(1200, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: width,
              child: AdaptiveGrid(
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (var i = 0; i < 5; i++)
                    SizedBox(key: ValueKey(i), height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  double topOf(WidgetTester tester, int i) =>
      tester.getTopLeft(find.byKey(ValueKey(i))).dy;

  testWidgets('stacks the items on a phone', (tester) async {
    // Arrange
    await pumpGrid(tester, 372);

    // Act
    final tops = [for (var i = 0; i < 5; i++) topOf(tester, i)];

    // Assert
    expect(tops, [0, 66, 132, 198, 264]);
    expect(tester.getSize(find.byKey(const ValueKey(0))).width, 372);
  });

  testWidgets('puts two items per row on a tablet', (tester) async {
    // Arrange
    await pumpGrid(tester, 700);

    // Act
    final tops = [for (var i = 0; i < 5; i++) topOf(tester, i)];

    // Assert
    expect(tops, [0, 0, 66, 66, 132]);
    expect(tester.getSize(find.byKey(const ValueKey(0))).width, (700 - 16) / 2);
    // The last one keeps the width of a column.
    expect(tester.getSize(find.byKey(const ValueKey(4))).width, (700 - 16) / 2);
  });

  testWidgets('puts three items per row on a wide screen', (tester) async {
    // Arrange
    await pumpGrid(tester, 960);

    // Act
    final tops = [for (var i = 0; i < 5; i++) topOf(tester, i)];

    // Assert
    expect(tops, [0, 0, 0, 66, 66]);
  });
}
