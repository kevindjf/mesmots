import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/core/theme/app_palette.dart';
import 'package:mesmots/core/theme/app_theme.dart';
import 'package:mesmots/features/games/presentation/providers/writing_game_provider.dart';
import 'package:mesmots/features/games/presentation/widgets/tappable_letter.dart';
import 'package:mesmots/features/games/presentation/widgets/writing_answer.dart';

void main() {
  Future<List<int>> pumpAnswer(
    WidgetTester tester,
    WritingQuestion question,
  ) async {
    final moves = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.of(AppPalette.light),
        home: Scaffold(
          body: Center(
            child: WritingAnswer(question: question, onMoveCursor: moves.add),
          ),
        ),
      ),
    );
    return moves;
  }

  testWidgets('shows the cursor where the next letter goes', (tester) async {
    // Arrange
    const question = WritingQuestion(word: 'bureau', input: 'bueau', cursor: 2);

    // Act
    await pumpAnswer(tester, question);

    // Assert
    final cursor = tester.getRect(find.byKey(const ValueKey('cursor')));
    final letters = find.byType(TappableLetter);
    expect(
        cursor.left, greaterThanOrEqualTo(tester.getRect(letters.at(1)).right));
    expect(cursor.right, lessThanOrEqualTo(tester.getRect(letters.at(2)).left));
  });

  testWidgets('tapping a letter moves the cursor next to it', (tester) async {
    // Arrange
    const question = WritingQuestion(word: 'bureau', input: 'bueau');
    final moves = await pumpAnswer(tester, question);
    final e = tester.getRect(find.byType(TappableLetter).at(2));

    // Act
    await tester.tapAt(e.centerLeft + const Offset(2, 0));
    await tester.tapAt(e.centerRight - const Offset(2, 0));

    // Assert
    expect(moves, [2, 3]);
  });
}
