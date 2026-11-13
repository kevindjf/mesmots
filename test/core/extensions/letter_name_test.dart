import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/core/extensions/letter_name.dart';
import 'package:mesmots/core/utils/string_utils.dart';

void main() {
  test('plain letters are said as a single capital letter', () {
    // Act
    final names = 'sept'.graphemes.map((l) => l.letterName).toList();

    // Assert
    expect(names, ['S', 'E', 'P', 'T']);
  });

  test('names accents, cedilla and punctuation of compound words', () {
    // Assert
    expect('é'.letterName, 'E accent aigu');
    expect('à'.letterName, 'A accent grave');
    expect('ç'.letterName, 'C cédille');
    expect('-'.letterName, 'trait d\'union');
    expect('\''.letterName, 'apostrophe');
  });

  test('ignores case and does not spell spaces', () {
    // Assert
    expect('S'.letterName, 'S');
    expect(' '.letterName, isNull);
  });

  test('every letter of the alphabet has a name', () {
    // Arrange
    const alphabet = 'abcdefghijklmnopqrstuvwxyz';

    // Assert
    for (final letter in alphabet.split('')) {
      expect(letter.letterName, letter.toUpperCase(), reason: letter);
    }
  });
}
