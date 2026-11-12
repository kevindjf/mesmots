import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/features/games/domain/usecases/keyboard_for_words.dart';

void main() {
  test('always offers the common accents', () {
    // Act
    final keys = keyboardForWords(const ['chat', 'maison']);

    // Assert
    expect(keys.accents, ['é', 'è', 'ê', 'à', 'ç']);
    expect(keys.hasSpace, isFalse);
  });

  test('adds the accents and signs used by the words', () {
    // Act
    final keys = keyboardForWords(
      const ['cœur', 'maïs', 'pomme de terre', 'arc-en-ciel', "aujourd'hui"],
    );

    // Assert
    expect(keys.accents, containsAll(['œ', 'ï', 'é']));
    expect(keys.accents.length, lessThanOrEqualTo(10));
    expect(keys.hasSpace, isTrue);
    expect(keys.hasHyphen, isTrue);
    expect(keys.hasApostrophe, isTrue);
  });
}
