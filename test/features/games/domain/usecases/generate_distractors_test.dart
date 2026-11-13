import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/features/games/domain/usecases/generate_distractors.dart';

void main() {
  late GenerateDistractors generate;

  setUp(() => generate = GenerateDistractors(Random(42)));

  Set<String> allVariants(String word) =>
      generate.variantsByRule(word).values.expand((v) => v).toSet();

  const sample = [
    'maison',
    'école',
    'poisson',
    'soleil',
    'chat',
    'gâteau',
    'jardin',
    'cerise',
    'garçon',
    'fenêtre',
    'chapeau',
    'vélo',
    'bonjour',
    'hibou',
    'neige',
    'famille',
    'lit',
    'ami',
    'toujours',
    'le',
  ];

  test('gives up to 3 distinct distractors, all different from the word', () {
    for (final word in sample) {
      // Act
      final distractors = generate(word);

      // Assert
      expect(distractors.length, inInclusiveRange(1, 3), reason: word);
      expect(distractors.toSet().length, distractors.length, reason: word);
      expect(distractors, isNot(contains(word)), reason: word);
    }
  });

  test('never produces absurd spellings', () {
    for (final word in sample) {
      // Act
      final variants = {...allVariants(word), ...generate(word)};

      // Assert
      for (final v in variants) {
        expect(v, isNot(matches(RegExp(r'[0-9A-Z]'))), reason: '$word -> $v');
        expect(v[0], isNot(v[1]), reason: '$word -> $v: doubled first letter');
        expect(v, isNot(matches(RegExp(r'(.)\1\1'))), reason: '$word -> $v');
      }
    }
  });

  test('uses spellings that sound alike', () {
    // Assert
    expect(allVariants('maison'), contains('maizon'));
    expect(allVariants('école'), containsAll(['ecole', 'écolle', 'ékole']));
    expect(allVariants('poisson'), containsAll(['poison', 'poissont']));
    expect(generate('poisson').length, 3);
    expect(allVariants('chapeau'), containsAll(['chapo', 'chapau']));
    expect(allVariants('jardin'), containsAll(['jardain', 'jardein']));
    expect(allVariants('garçon'), contains('garson'));
  });

  test('drops silent letters inside a word', () {
    // Assert
    expect(allVariants('sept'), containsAll(['set', 'cet']));
    expect(generate('sept').length, 3);
    expect(allVariants('septième'), contains('setième'));
    expect(allVariants('compter'), containsAll(['comter', 'conter']));
    expect(allVariants('baptême'), contains('batême'));
    expect(allVariants('sculpter'), contains('sculter'));
    expect(allVariants('automne'), contains('autone'));
    expect(allVariants('printemps'), contains('printems'));
    expect(allVariants('doigt'), containsAll(['doit', 'doig']));
    expect(allVariants('vingt'), contains('vint'));
    expect(allVariants('blanc'), contains('blan'));
    expect(allVariants('rang'), contains('ran'));
    expect(allVariants('corps'), contains('cor'));
  });

  test('keeps letters that are heard', () {
    // Assert
    expect(allVariants('septembre'), isNot(contains('setembre')));
    expect(allVariants('adapter'), isNot(contains('adater')));
    expect(allVariants('concept'), isNot(contains('concet')));
    expect(allVariants('donc'), isNot(contains('don')));
  });

  test('avoids spellings that change the sound', () {
    // Assert: "ercole", "coleil", "éceaule" were produced before
    expect(allVariants('école'),
        isNot(anyOf(contains('ercole'), contains('éceaule'))));
    expect(allVariants('soleil'), isNot(contains('coleil')));
    expect(allVariants('maison'), isNot(contains('maitson')));
    expect(allVariants('montagne'), isNot(contains('montagn')));
  });
}
