/// How a letter is named aloud in French, written for the text-to-speech
/// engine.
///
/// A single capital letter is read by its name ("S" -> "èsse"), the way
/// screen readers spell. Phonetic spellings are avoided: an unknown word
/// like "èss" is itself spelled ("è", "s", "s"), and a real word like "eu"
/// is read with its own sound ("u").
extension LetterName on String {
  static const _names = {
    'é': 'E accent aigu',
    'è': 'E accent grave',
    'ê': 'E accent circonflexe',
    'ë': 'E tréma',
    'à': 'A accent grave',
    'â': 'A accent circonflexe',
    'î': 'I accent circonflexe',
    'ï': 'I tréma',
    'ô': 'O accent circonflexe',
    'ù': 'U accent grave',
    'û': 'U accent circonflexe',
    'ü': 'U tréma',
    'ÿ': 'Y tréma',
    'ç': 'C cédille',
    'œ': 'E dans l\'O',
    'æ': 'E dans l\'A',
    '-': 'trait d\'union',
    '\'': 'apostrophe',
    '’': 'apostrophe',
  };

  static final _plainLetter = RegExp('^[a-z]\$');

  /// Name of this letter (one grapheme) as said aloud, or null for what is
  /// not spelled (spaces).
  String? get letterName {
    final letter = toLowerCase();
    if (_plainLetter.hasMatch(letter)) return letter.toUpperCase();
    return _names[letter];
  }
}
