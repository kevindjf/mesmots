import 'dart:math';

/// Generates plausible misspellings of a French word, for "Le bon mot".
///
/// A good distractor sounds like the word, so the child has to look at the
/// spelling: "écolle", "ecole", "maizon", "poison". Each distractor applies
/// one spelling change that keeps (roughly) the same sound:
/// - sounds written several ways (o/au/eau, é/er/ez, ai/è, an/en, in/ain…),
/// - consonants that sound alike (c/k/qu, s/ss/c/ç, s/z, g/j, f/ph),
/// - doubled or single consonants (never at the start of the word),
/// - accents, silent letters at the end, silent h.
class GenerateDistractors {
  /// Number of distractors wanted (the right answer makes 4 options).
  static const count = 3;

  static const _v = 'aeiouyéèêëàâîïôûù';

  static final List<_Rule> _rules = [
    // o / au / eau
    _Rule(r'eau', ['au', 'o']),
    _Rule(r'(?<![eo])au', ['o', 'eau']),
    _Rule(r'(?<![aeo])o(?![uinm])', ['au']),
    _Rule(r'(?<![aeo])o$', ['eau', 'ot']),
    // è / ai / ei / ê / é
    _Rule(r'ai(?![nm])', ['è', 'ei']),
    _Rule(r'ei(?![nm])', ['ai']),
    _Rule(r'è', ['ai', 'ê']),
    _Rule(r'ê', ['è', 'ai']),
    _Rule(r'é$', ['er', 'ez', 'ée']),
    _Rule(r'é(?!$)', ['e', 'è']),
    _Rule(r'er$', ['é', 'ez']),
    _Rule(r'et$', ['ait', 'è']),
    // Nasal sounds
    _Rule(r'on$', ['ont', 'om']),
    _Rule(r'an$', ['ant', 'en']),
    _Rule(r'oi', ['oa']),
    _Rule(r'an', ['en']),
    _Rule(r'en', ['an']),
    _Rule(r'am(?=[bp])', ['em']),
    _Rule(r'em(?=[bp])', ['am']),
    _Rule(r'ain', ['in', 'ein']),
    _Rule(r'ein', ['ain', 'in']),
    _Rule(r'(?<![aeo])in(?![V])', ['ain', 'ein']),
    // Consonants that sound alike
    _Rule(r'n(?=[bp])', ['m']),
    _Rule(r'm(?=[bp])', ['n']),
    _Rule(r'ph', ['f']),
    _Rule(r'f', ['ph']),
    _Rule(r'qu(?=[eiéèêy])', ['k']),
    _Rule(r'qu(?=[aoô])', ['c', 'k']),
    _Rule(r'c(?=[aoôu])', ['k', 'qu']),
    _Rule(r'c(?=[eiéèêy])', ['s', 'ss']),
    _Rule(r'ç', ['s', 'ss']),
    _Rule(r'ss(?=[eiéèêy])', ['c']),
    _Rule(r'ss', ['s']),
    _Rule(r'(?<=[V])s(?=[V])', ['z']),
    _Rule(r'(?<=[V])z(?=[V])', ['s']),
    _Rule(r'g(?=[eiéèêy])', ['j']),
    _Rule(r'j(?=[eiéèê])', ['g']),
    _Rule(r'ge(?=[aoôu])', ['j']),
    _Rule(r'gn', ['ni']),
    _Rule(r'ill', ['y', 'il']),
    // Silent h
    _Rule(r'^h', ['']),
    _Rule(r'^(?=[aeiouéè])', ['h']),
    // Double / single consonants, never at the start
    _Rule(r'(?<=.)([bcdfglmnprt])\1', [r'$1']),
    _Rule(r'(?<=[V])([lmnprtf])(?=[V])', [r'$1$1']),
    // Accents
    _Rule(r'(?<=^|[^V])e(?=[^V])', ['é', 'è']),
    // Tiny words ("le", "de")
    _Rule(r'^([^V])e$', [r'$1é', r'$1eu']),
    _Rule(r'à', ['a']),
    _Rule(r'â', ['a']),
    _Rule(r'ô', ['o']),
    _Rule(r'î', ['i']),
    _Rule(r'û', ['u']),
    // Silent consonants inside a word or after a nasal sound. A closed list
    // of known cases: a general "pt -> t" would also hit "adapter",
    // "septembre" or "concept", where the letter is heard.
    _Rule(r'^sept(?=$|s$|ième)', ['set', 'cet']),
    _Rule(r'(?<=^(dé|ra)?com)p(?=t)', ['']),
    _Rule(r'^comp(?=t)', ['con']),
    _Rule(r'(?<=^ba)p(?=t)', ['']),
    _Rule(r'(?<=^scul)p(?=t)', ['']),
    _Rule(r'(?<=^(auto|conda|da))m(?=n)', ['']),
    _Rule(r'(?<=^(prin)?te)mps$', ['ms', 'mp', 'n']),
    _Rule(r'(?<=^(doi|vin))gt(?=s?$)', ['t', 'g', '']),
    _Rule(r'(?<=[ao])ng$', ['n', 'nc']),
    // "donc" is left out: its c is often heard.
    _Rule(r'(?<!^do)(?<=[ao])nc$', ['n', 'nt']),
    _Rule(r'(?<=^co)rps$', ['r', 'rt']),
    // Silent endings
    _Rule(r'(?<=[V][^V])e$', ['']),
    _Rule(r'(?<=[V])r$', ['re']),
    _Rule(r'(?<=[V])l$', ['le']),
    _Rule(r'(?<![ae][ou])(?<=[aiouy])$', ['t', 'd']),
    _Rule(r'(?<=[^V])s$', ['', 'x']),
    _Rule(r'(?<=[V])t$', ['d', 's', '']),
    _Rule(r'(?<=[V])d$', ['t', '']),
    _Rule(r'(?<=[V])x$', ['s', '']),
    _Rule(r'(?<=[V])s$', ['t', '']),
  ];

  final Random _random;

  GenerateDistractors([Random? random]) : _random = random ?? Random();

  /// Up to [count] distinct misspellings of [word], in random order.
  /// Very short words may get fewer.
  List<String> call(String word) {
    final byRule = variantsByRule(word)
        .values
        .map((v) => v.toList()..shuffle(_random))
        .toList()
      ..shuffle(_random);

    // Take one variant per rule first, so the errors are of different kinds.
    final picked = <String>[];
    for (var round = 0; picked.length < count; round++) {
      var added = false;
      for (final variants in byRule) {
        if (round < variants.length && !picked.contains(variants[round])) {
          picked.add(variants[round]);
          added = true;
          if (picked.length == count) break;
        }
      }
      if (!added) break;
    }

    if (picked.length < count) {
      picked.addAll(
        _fallbacks(word)
            .where((f) => !picked.contains(f))
            .take(count - picked.length),
      );
    }
    return picked..shuffle(_random);
  }

  /// Every plausible misspelling of [word], grouped by the rule producing it.
  Map<int, Set<String>> variantsByRule(String word) {
    final result = <int, Set<String>>{};
    for (var i = 0; i < _rules.length; i++) {
      final variants =
          _rules[i].apply(word).where((v) => _isAcceptable(v, word)).toSet();
      if (variants.isNotEmpty) result[i] = variants;
    }
    return result;
  }

  bool _isAcceptable(String variant, String word) {
    if (variant == word || variant.length < 2) return false;
    // No tripled letters ("pommme"), no doubled first letter ("mmaison").
    if (RegExp(r'(.)\1\1').hasMatch(variant)) return false;
    if (variant.length > 1 && variant[0] == variant[1]) return false;
    return true;
  }

  /// Last resort for words with few spelling traps: double a consonant
  /// between two vowels ("bonjour" -> "bonnjour" is avoided: n is not
  /// between vowels).
  Iterable<String> _fallbacks(String word) sync* {
    for (var i = 1; i < word.length - 1; i++) {
      final c = word[i];
      final between = _v.contains(word[i - 1]) && _v.contains(word[i + 1]);
      if (!between || !'bcdfglmnprst'.contains(c)) continue;
      final doubled = word.substring(0, i) + c + word.substring(i);
      if (_isAcceptable(doubled, word)) yield doubled;
    }
  }
}

/// Replaces one occurrence of [pattern] by each of [replacements].
/// `$1` in a replacement stands for the first group of the match.
class _Rule {
  final RegExp pattern;
  final List<String> replacements;

  /// In [pattern], `V` stands for any vowel.
  _Rule(String pattern, this.replacements)
      : pattern = RegExp(
          pattern.replaceAll('V', GenerateDistractors._v),
          unicode: true,
        );

  Iterable<String> apply(String word) sync* {
    for (final match in pattern.allMatches(word)) {
      for (final replacement in replacements) {
        final text = replacement.replaceAll(
          r'$1',
          match.groupCount >= 1 ? match.group(1) ?? '' : '',
        );
        yield word.substring(0, match.start) + text + word.substring(match.end);
      }
    }
  }
}
