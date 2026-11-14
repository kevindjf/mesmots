import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/core/constants/app_breakpoints.dart';
import 'package:mesmots/core/extensions/responsive_context.dart';
import 'package:mesmots/shared/widgets/adaptive_scale.dart';

void main() {
  late Size seenSize;
  late EdgeInsets seenPadding;
  late ScreenClass seenClass;

  Future<void> pumpOn(WidgetTester tester, Size size, {Widget? child}) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1
      ..padding = const FakeViewPadding(top: 28);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        builder: AdaptiveScale.builder,
        home: Builder(
          builder: (context) {
            seenSize = MediaQuery.sizeOf(context);
            seenPadding = MediaQuery.paddingOf(context);
            seenClass = context.screenClass;
            return child ?? const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  testWidgets('leaves a phone as it is', (tester) async {
    // Arrange
    const phone = Size(412, 840);

    // Act
    await pumpOn(tester, phone);

    // Assert
    expect(seenSize, phone);
    expect(seenPadding.top, 28);
    expect(seenClass, ScreenClass.sm);
  });

  testWidgets('shows a large tablet a smaller logical screen', (tester) async {
    // Arrange
    const ipad = Size(1032, 1376);

    // Act
    await pumpOn(tester, ipad);

    // Assert
    expect(seenSize.width, closeTo(1032 / AppBreakpoints.uiScaleLg, 0.01));
    expect(seenSize.height, closeTo(1376 / AppBreakpoints.uiScaleLg, 0.01));
    expect(seenPadding.top, closeTo(28 / AppBreakpoints.uiScaleLg, 0.01));
    expect(seenClass, ScreenClass.lg);
  });

  testWidgets('draws the UI bigger and still fills the screen', (tester) async {
    // Arrange
    const tablet = Size(800, 1280);
    const key = Key('box');

    // Act
    await pumpOn(
      tester,
      tablet,
      child: const Align(
        alignment: Alignment.topLeft,
        child: SizedBox(key: key, width: 100, height: 100),
      ),
    );

    // Assert
    expect(
      tester.getRect(find.byKey(key)).width,
      closeTo(100 * AppBreakpoints.uiScaleMd, 0.01),
    );
    final app = tester.getRect(find.byType(Navigator));
    expect(app.width, closeTo(tablet.width, 0.01));
    expect(app.height, closeTo(tablet.height, 0.01));
  });

  testWidgets('taps reach the scaled widgets', (tester) async {
    // Arrange
    var taps = 0;
    await pumpOn(
      tester,
      const Size(1032, 1376),
      child: Align(
        alignment: Alignment.bottomRight,
        child: ElevatedButton(
          onPressed: () => taps++,
          child: const Text('ok'),
        ),
      ),
    );

    // Act
    await tester.tap(find.text('ok'));
    await tester.pump();

    // Assert
    expect(taps, 1);
  });
}
