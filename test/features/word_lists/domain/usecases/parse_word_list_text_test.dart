import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/features/word_lists/domain/usecases/parse_word_list_text.dart';

void main() {
  const parse = ParseWordListText();

  test('keeps one word per line, lowercased', () {
    // Act
    final words = parse(['Maison', 'École', 'soleil']);

    // Assert
    expect(words, ['maison', 'école', 'soleil']);
  });

  test('keeps accented capitals at the start of a word', () {
    // Act
    final words = parse(['Écureuil', 'Île', 'Ça']);

    // Assert
    expect(words, ['écureuil', 'île', 'ça']);
  });

  test('removes numbering and bullets', () {
    // Act
    final words = parse(['1. maison', '2) jardin', '3 - fleur', '• arbre', '- ciel']);

    // Assert
    expect(words, ['maison', 'jardin', 'fleur', 'arbre', 'ciel']);
  });

  test('drops titles', () {
    // Act
    final words = parse(['Mots de la semaine', 'Liste 3', 'Dictée :', 'chat']);

    // Assert
    expect(words, ['chat']);
  });

  test('removes leading articles', () {
    // Act
    final words = parse(['la maison', 'un chien', "l'école", 'l’arbre', 'les amis']);

    // Assert
    expect(words, ['maison', 'chien', 'école', 'arbre', 'amis']);
  });

  test('keeps compound words', () {
    // Act
    final words = parse(['une pomme de terre', 'salle à manger', 'arc-en-ciel']);

    // Assert
    expect(words, ['pomme de terre', 'salle à manger', 'arc-en-ciel']);
  });

  test('splits lines holding several words', () {
    // Act
    final words = parse(['chat, chien; loup', 'vélo moto train et bus']);

    // Assert
    expect(words, ['chat', 'chien', 'loup', 'vélo', 'moto', 'train', 'bus']);
  });

  test('strips edge punctuation and drops noise', () {
    // Act
    final words = parse(['« maison ».', '12', 'a', '***', 'b4b4', '']);

    // Assert
    expect(words, ['maison']);
  });

  test('removes duplicates and normalizes decomposed accents', () {
    // Act
    final words = parse(['école', 'école', 'École']);

    // Assert
    expect(words, ['école']);
  });
}
