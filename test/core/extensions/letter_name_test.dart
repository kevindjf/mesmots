import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/core/extensions/letter_name.dart';
import 'package:mesmots/core/utils/string_utils.dart';

void main() {
  test('names the letters of "sept" the French way', () {
    // Act
    final names = 'sept'.graphemes.map((l) => l.letterName).toList();

    // Assert
    expect(names, ['èss', 'eu', 'pé', 'té']);
  });

  test('names accents, cedilla and punctuation of compound words', () {
    // Assert
    expect('é'.letterName, 'eu accent aigu');
    expect('à'.letterName, 'a accent grave');
    expect('ç'.letterName, 'cé cédille');
    expect('-'.letterName, 'trait d\'union');
    expect('\''.letterName, 'apostrophe');
  });

  test('ignores case and does not spell spaces', () {
    // Assert
    expect('S'.letterName, 'èss');
    expect(' '.letterName, isNull);
  });

  test('every lowercase letter of the alphabet has a name', () {
    // Arrange
    const alphabet = 'abcdefghijklmnopqrstuvwxyz';

    // Assert
    for (final letter in alphabet.split('')) {
      expect(letter.letterName, isNotNull, reason: letter);
    }
  });
}
