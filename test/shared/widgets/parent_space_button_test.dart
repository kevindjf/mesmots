import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/shared/widgets/parent_space_button.dart';

void main() {
  testWidgets('shows the parent symbol and opens on tap', (tester) async {
    // Arrange
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(child: ParentSpaceButton(onTap: () => taps++)),
        ),
      ),
    );

    // Act
    await tester.tap(find.byType(ParentSpaceButton));
    await tester.pump();

    // Assert
    expect(find.byType(SvgPicture), findsOneWidget);
    expect(taps, 1);
  });
}
