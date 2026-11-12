import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/features/games/domain/usecases/compare_spelling.dart';

void main() {
  test('marks every letter right for the right spelling', () {
    // Act / Assert
    expect(markTypedLetters('école', 'école'), everyElement(isTrue));
    expect(markTypedLetters('École', 'école'), everyElement(isTrue));
  });

  test('marks a missing accent and an extra letter', () {
    // Act
    final marks = markTypedLetters('ecolle', 'école');

    // Assert: "e" without accent and one extra "l"
    expect(marks.where((m) => !m).length, 2);
    expect(marks.first, isFalse);
  });

  test('marks a wrong letter in the middle', () {
    // Act / Assert
    expect(markTypedLetters('maizon', 'maison'),
        [true, true, true, false, true, true]);
  });
}
