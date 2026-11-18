import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/core/constants/app_breakpoints.dart';
import 'package:mesmots/shared/widgets/bounded_content.dart';

void main() {
  const content = Key('content');

  Future<double> widthOn(WidgetTester tester, Size size, Widget bounded) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: bounded)));
    return tester.getSize(find.byKey(content)).width;
  }

  testWidgets('fills a phone', (tester) async {
    // Arrange
    const phone = Size(412, 840);

    // Act
    final width = await widthOn(
      tester,
      phone,
      const BoundedContent(child: SizedBox(key: content, height: 10)),
    );

    // Assert
    expect(width, phone.width);
  });

  testWidgets('keeps one centered column on a tablet', (tester) async {
    // Arrange
    const tablet = Size(800, 1280);

    // Act
    final width = await widthOn(
      tester,
      tablet,
      const BoundedContent(child: SizedBox(key: content, height: 10)),
    );

    // Assert
    expect(width, AppBreakpoints.contentMaxWidth);
    expect(tester.getCenter(find.byKey(content)).dx, tablet.width / 2);
  });

  testWidgets('side by side widens only on a screen held sideways',
      (tester) async {
    // Arrange
    const upright = Size(800, 1280);
    const sideways = Size(1280, 800);
    const bounded = BoundedContent.sideBySide(
      child: SizedBox(key: content, height: 10),
    );

    // Act
    final uprightWidth = await widthOn(tester, upright, bounded);
    final sidewaysWidth = await widthOn(tester, sideways, bounded);

    // Assert
    expect(uprightWidth, AppBreakpoints.contentMaxWidth);
    expect(sidewaysWidth, AppBreakpoints.wideContentMaxWidth);
  });

  testWidgets('side by side fills a phone held sideways', (tester) async {
    // Arrange
    const phone = Size(852, 393);

    // Act
    final width = await widthOn(
      tester,
      phone,
      const BoundedContent.sideBySide(
        child: SizedBox(key: content, height: 10),
      ),
    );

    // Assert
    expect(width, phone.width);
  });
}
