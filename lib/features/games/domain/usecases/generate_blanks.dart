import 'dart:math';

import 'package:mesmots/core/utils/string_utils.dart';
import 'package:mesmots/features/games/domain/entities/letter_puzzle.dart';

/// Builds a "Mots à trous" puzzle: the blanks are on the word's spelling
/// difficulties, and the tiles mix the right letters with letters children
/// confuse them with.
///
/// Difficulties, by priority: sounds written with several letters (eau,
/// ain, ou, an, qu, ph…), double consonants, accented letters, silent
/// letters at the end. The first letter is always given, as a hint.
class GenerateBlanks {
  static const _vowels = 'aeiouyéèêëàâîïôûù';

  /// Groups of letters to hide together, most specific first.
  static final List<RegExp> _difficulties = [
    for (final pattern in [
      'eau',
      '(?:ain|ein)(?![${_vowels}nm])',
      'au|ai|ei|ou|oi',
      '(?:an|am|en|em|in|im|on|om|un)(?![${_vowels}nm])',
      'qu|ph|gn',
      r'([bcdfglmnprst])\1',
      '[éèêëàâîïôûùç]',
      '(?<=[^$_vowels])e\$',
      '(?<=[$_vowels])[tdsx]\$',
    ])
      RegExp(pattern, unicode: true),
  ];

  /// Letters children write instead of the right one.
  static const Map<String, List<String>> _confusions = {
    'é': ['e', 'è', 'ê'],
    'è': ['é', 'e', 'ê'],
    'ê': ['è', 'é', 'e'],
    'ë': ['e', 'é'],
    'e': ['é', 'è', 'a'],
    'a': ['e', 'à', 'o'],
    'à': ['a', 'â'],
    'â': ['a', 'à'],
    'i': ['y', 'î', 'e'],
    'î': ['i', 'ï'],
    'ï': ['i', 'î'],
    'o': ['au', 'ô', 'a'],
    'ô': ['o'],
    'u': ['o', 'û'],
    'û': ['u'],
    'ù': ['u'],
    'y': ['i'],
    'c': ['k', 's', 'ç'],
    'ç': ['c', 's'],
    'k': ['c', 'q'],
    'q': ['c', 'k'],
    's': ['z', 'c', 'x'],
    'z': ['s'],
    'x': ['s'],
    't': ['d', 's'],
    'd': ['t'],
    'm': ['n'],
    'n': ['m'],
    'p': ['b'],
    'b': ['p', 'd'],
    'g': ['j'],
    'j': ['g'],
    'f': ['v', 'p'],
    'v': ['f'],
    'h': ['e', 'a'],
    'l': ['r'],
    'r': ['l'],
  };

  final Random _random;

  GenerateBlanks([Random? random]) : _random = random ?? Random();

  LetterPuzzle call(String word) {
    final letters = word.graphemes;
    final blanks = blankPositions(word);
    final needed = [for (final b in blanks) letters[b]];
    final tiles = [...needed, ...decoysFor(needed)]..shuffle(_random);
    return LetterPuzzle(word: word, blanks: blanks, tiles: tiles);
  }

  /// Positions to hide: 1 difficulty for short words, 2 for longer ones.
  List<int> blankPositions(String word) {
    final letters = word.graphemes;
    final wanted = letters.length <= 5 ? 1 : 2;

    final groups = _difficultyGroups(word, letters)..shuffle(_random);
    final blanks = <int>{
      for (final group in groups.take(wanted)) ...group,
    };

    if (blanks.isEmpty) {
      final candidates = [
        for (var i = 1; i < letters.length; i++)
          if (LetterPuzzle.isFillable(letters[i])) i,
      ]..shuffle(_random);
      blanks.addAll(candidates.take(wanted));
    }
    return blanks.toList()..sort();
  }

  /// Difficulties found in the word, as lists of positions, never
  /// overlapping and never including the first letter.
  List<List<int>> _difficultyGroups(String word, List<String> letters) {
    final lower = word.toLowerCase();
    // Patterns work on characters: only usable when each letter is one
    // character (precomposed accents, which the app stores).
    if (lower.length != letters.length) return [];

    final taken = <int>{0};
    final groups = <List<int>>[];
    for (final pattern in _difficulties) {
      for (final match in pattern.allMatches(lower)) {
        final positions = [for (var i = match.start; i < match.end; i++) i];
        if (positions.isEmpty || positions.any(taken.contains)) continue;
        taken.addAll(positions);
        groups.add(positions);
      }
    }
    return groups;
  }

  /// 2 or 3 single letters the child could confuse with [needed].
  List<String> decoysFor(List<String> needed) {
    final wanted = needed.length >= 4 ? 2 : 3;
    final candidates = <String>{
      for (final letter in needed) ...?_confusions[letter.toLowerCase()],
    }..removeWhere((c) => c.length != 1 || needed.contains(c));

    final decoys = candidates.toList()..shuffle(_random);
    if (decoys.length < wanted) {
      final extra = 'aeiourstlnm'.split('')
        ..removeWhere((c) => needed.contains(c) || decoys.contains(c))
        ..shuffle(_random);
      decoys.addAll(extra.take(wanted - decoys.length));
    }
    return decoys.take(wanted).toList();
  }
}
