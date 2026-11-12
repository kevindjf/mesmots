import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/shared/widgets/pop_in.dart';

double _opacity(WidgetTester tester) => tester
    .widget<Opacity>(
      find.descendant(of: find.byType(PopIn), matching: find.byType(Opacity)),
    )
    .opacity;

void main() {
  testWidgets('is invisible during its delay, then fully shown', (tester) async {
    // Arrange
    await tester.pumpWidget(
      const MaterialApp(
        home: PopIn(delay: Duration(milliseconds: 500), child: Text('mot')),
      ),
    );

    // Act
    await tester.pump(const Duration(milliseconds: 200));
    final duringDelay = _opacity(tester);
    await tester.pumpAndSettle();

    // Assert
    expect(duringDelay, 0);
    expect(_opacity(tester), 1);
  });

  testWidgets('is shown at once when animations are reduced', (tester) async {
    // Arrange
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          home: PopIn(delay: Duration(seconds: 1), child: Text('mot')),
        ),
      ),
    );

    // Act
    await tester.pump();

    // Assert
    expect(_opacity(tester), 1);
  });
}
