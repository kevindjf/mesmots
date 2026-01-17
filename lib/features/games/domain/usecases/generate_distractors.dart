import 'dart:math';

/// Use case to generate plausible distractors (wrong answers) for QCM
class GenerateDistractors {
  final Random _random = Random();

  /// Generate 3 unique distractors for a word
  List<String> call(String word) {
    final distractors = <String>{};

    // Try different error types until we have 3 unique distractors
    while (distractors.length < 3) {
      String distractor;

      // Prioritize phonetic errors (most pedagogical)
      if (distractors.isEmpty) {
        distractor = _phoneticError(word);
      } else if (distractors.length == 1) {
        distractor = _doubleLetter Error(word);
      } else {
        // Mix of other errors
        final errorType = _random.nextInt(3);
        switch (errorType) {
          case 0:
            distractor = _accentError(word);
            break;
          case 1:
            distractor = _finalLetterError(word);
            break;
          default:
            distractor = _randomError(word);
        }
      }

      // Ensure distractor is different from original and unique
      if (distractor != word && distractor.isNotEmpty) {
        distractors.add(distractor);
      }
    }

    return distractors.toList()..shuffle();
  }

  /// Generate phonetic errors (eau/au/o, ai/é/è, etc.)
  String _phoneticError(String word) {
    final phoneticRules = {
      'eau': ['au', 'o', 'aux'],
      'au': ['eau', 'o'],
      'ai': ['é', 'è', 'ait'],
      'é': ['ai', 'è', 'er'],
      'è': ['ai', 'é', 'ê'],
      'an': ['en'],
      'en': ['an'],
      'in': ['ain', 'ein'],
      'ain': ['in', 'ein'],
      'ph': ['f'],
      'f': ['ph'],
      'ss': ['s', 'c'],
      's': ['ss', 'c'],
      'c': ['ss', 's', 'qu'],
      'qu': ['k', 'c'],
      'tion': ['sion', 'ssion'],
    };

    // Try to find and apply a phonetic rule
    for (final entry in phoneticRules.entries) {
      if (word.contains(entry.key)) {
        final replacements = entry.value;
        final replacement =
            replacements[_random.nextInt(replacements.length)];
        return word.replaceFirst(entry.key, replacement);
      }
    }

    // Fallback to another error type
    return _doubleLetterError(word);
  }

  /// Generate double letter errors (mm→m, nn→n, etc.)
  String _doubleLetterError(String word) {
    final doubles = ['mm', 'nn', 'tt', 'll', 'ss', 'pp', 'rr', 'cc'];

    // Try to remove a double letter
    for (final double in doubles) {
      if (word.contains(double)) {
        return word.replaceFirst(double, double[0]);
      }
    }

    // Try to add a double letter
    final singles = ['m', 'n', 't', 'l', 's', 'p', 'r', 'c'];
    for (final single in singles) {
      if (word.contains(single) && !word.contains(single + single)) {
        return word.replaceFirst(single, single + single);
      }
    }

    return _accentError(word);
  }

  /// Generate accent errors (é→e/è/ê, à→a, etc.)
  String _accentError(String word) {
    final accentRules = {
      'é': ['e', 'è', 'ê'],
      'è': ['e', 'é', 'ê'],
      'ê': ['e', 'é', 'è'],
      'à': ['a'],
      'â': ['a'],
      'ù': ['u'],
      'û': ['u'],
      'î': ['i'],
      'ï': ['i'],
      'ô': ['o'],
    };

    for (final entry in accentRules.entries) {
      if (word.contains(entry.key)) {
        final replacements = entry.value;
        final replacement =
            replacements[_random.nextInt(replacements.length)];
        return word.replaceFirst(entry.key, replacement);
      }
    }

    // Try reverse: add accents
    final reverseRules = {
      'e': ['é', 'è', 'ê'],
      'a': ['à', 'â'],
      'u': ['ù', 'û'],
      'i': ['î', 'ï'],
      'o': ['ô'],
    };

    for (final entry in reverseRules.entries) {
      if (word.contains(entry.key)) {
        final replacements = entry.value;
        final replacement =
            replacements[_random.nextInt(replacements.length)];
        return word.replaceFirst(entry.key, replacement);
      }
    }

    return _finalLetterError(word);
  }

  /// Generate final letter errors (add/remove 'e' or 's')
  String _finalLetterError(String word) {
    if (word.endsWith('e')) {
      return word.substring(0, word.length - 1);
    } else if (!word.endsWith('s')) {
      return word + 's';
    } else if (word.endsWith('s')) {
      return word.substring(0, word.length - 1);
    } else {
      return word + 'e';
    }
  }

  /// Random error as fallback
  String _randomError(String word) {
    if (word.length < 3) return word + 'e';

    final pos = 1 + _random.nextInt(word.length - 2);
    final char = word[pos];

    // Replace a letter with a similar one
    const substitutions = {
      'a': 'e',
      'e': 'a',
      'i': 'y',
      'y': 'i',
      'o': 'au',
      'u': 'ou',
    };

    final replacement = substitutions[char] ?? char;
    return word.substring(0, pos) + replacement + word.substring(pos + 1);
  }
}
