import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/shared/widgets/letter_tile.dart';
import 'package:mesmots/shared/widgets/letter_tiles_title.dart';

void main() {
  testWidgets('shows one tile per letter, one row per word', (tester) async {
    // Arrange
    await tester.pumpWidget(
      const MaterialApp(home: LetterTilesTitle(text: 'Mes mots')),
    );

    // Act
    await tester.pump(const Duration(seconds: 2));

    // Assert
    expect(find.byType(LetterTile), findsNWidgets(7));
    expect(find.byType(Row), findsNWidgets(2));
    expect(find.text('M'), findsNWidgets(2));
  });

  testWidgets('a tapped tile jumps then lands back', (tester) async {
    // Arrange
    await tester.pumpWidget(
      const MaterialApp(home: Center(child: LetterTilesTitle(text: 'ab'))),
    );
    await tester.pump(const Duration(seconds: 1));
    final tile = find.byType(LetterTile).first;
    final restY = tester.getCenter(tile).dy;

    // Act
    await tester.tap(tile);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 325));
    final jumpY = tester.getCenter(tile).dy;
    await tester.pump(const Duration(milliseconds: 400));

    // Assert
    expect(jumpY, lessThan(restY));
    expect(tester.getCenter(tile).dy, closeTo(restY, 13));
  });
}
