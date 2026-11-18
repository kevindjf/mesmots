import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/core/constants/app_breakpoints.dart';
import 'package:mesmots/core/extensions/responsive_context.dart';

void main() {
  late BuildContext seen;

  Future<void> pumpOn(
    WidgetTester tester,
    Size size, {
    ScreenClass? scoped,
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final probe = Builder(
      builder: (context) {
        seen = context;
        return const SizedBox.shrink();
      },
    );
    await tester.pumpWidget(
      MaterialApp(
        home: scoped == null
            ? probe
            : ScreenClassScope(screenClass: scoped, child: probe),
      ),
    );
  }

  testWidgets('a phone held sideways is no tablet', (tester) async {
    // Arrange
    await pumpOn(tester, const Size(840, 412));

    // Act
    final isTablet = seen.isTablet;

    // Assert
    expect(isTablet, isFalse);
    expect(seen.isTabletLandscape, isFalse);
    expect(seen.isLandscape, isTrue);
  });

  testWidgets('a phone held upright is not landscape', (tester) async {
    // Arrange
    await pumpOn(tester, const Size(412, 840));

    // Act
    final isLandscape = seen.isLandscape;

    // Assert
    expect(isLandscape, isFalse);
  });

  testWidgets('a tablet held sideways has room for two panes', (tester) async {
    // Arrange
    await pumpOn(tester, const Size(1280, 800));

    // Act
    final isLandscape = seen.isTabletLandscape;

    // Assert
    expect(seen.screenClass, ScreenClass.md);
    expect(isLandscape, isTrue);
  });

  testWidgets('the scope wins over the logical screen size', (tester) async {
    // Arrange
    // Scaled down, an iPad's logical screen looks smaller than it is.
    await pumpOn(tester, const Size(737, 983), scoped: ScreenClass.lg);

    // Act
    final screenClass = seen.screenClass;

    // Assert
    expect(screenClass, ScreenClass.lg);
  });
}
