import 'package:mesmots/core/utils/string_utils.dart';

/// Turns the text lines of a word list (typed, pasted or, later, read
/// from a photo) into the words to learn.
///
/// Word lists given at school usually have one word per line, sometimes
/// numbered, with a title and an article in front of nouns. This parser:
/// - drops titles ("Mots de la semaine", lines ending with ':'),
/// - removes numbering and bullets ("1.", "2)", "-", "•"),
/// - removes leading articles ("la maison" -> "maison", "l'école" -> "école"),
/// - keeps compound words ("pomme de terre"),
/// - splits lines holding several words ("chat, chien" or "chat chien loup"),
/// - lowercases, keeps accents and removes duplicates.
class ParseWordListText {
  const ParseWordListText();

  static const _articles = {'le', 'la', 'les', 'un', 'une', 'des', 'du'};
  static const _linkWords = {'de', 'à', 'en', 'au', 'aux', 'du', 'des'};
  static final _stopWords = {..._articles, ..._linkWords, 'et', 'ou'};
  static const _titleWords = {
    'mot',
    'mots',
    'liste',
    'dictée',
    'dictee',
    'semaine',
  };

  static final _bullet = RegExp(r'^(\d+\s*[.):\-]?|[a-z]\)|[-–—•*·>]+)\s*');
  static final _separators = RegExp(r'[,;/|]+');
  static final _spaces = RegExp(r'\s+');
  static final _edgeNoise = RegExp(r'^[^\p{L}]+|[^\p{L}]+$', unicode: true);
  static final _letter = RegExp(r'\p{L}', unicode: true);
  static final _wordChars = RegExp(r"[\p{L}\s'\-]", unicode: true);
  static final _elidedArticle = RegExp(r"^l'(?=\p{L})", unicode: true);

  List<String> call(List<String> lines) {
    final words = <String>[];
    for (final rawLine in lines) {
      for (final word in _parseLine(rawLine)) {
        if (!words.contains(word)) words.add(word);
      }
    }
    return words;
  }

  Iterable<String> _parseLine(String rawLine) sync* {
    final line = rawLine.nfc.replaceAll('’', "'").trim();
    if (line.isEmpty || line.endsWith(':')) return;
    if (_isTitle(line)) return;

    final content = line.replaceFirst(_bullet, '');
    for (final segment in content.split(_separators)) {
      yield* _parseSegment(segment);
    }
  }

  bool _isTitle(String line) {
    final tokens = line.toLowerCase().split(_spaces);
    return tokens.length >= 2 && _titleWords.contains(tokens.first);
  }

  Iterable<String> _parseSegment(String segment) sync* {
    var tokens = segment
        .toLowerCase()
        .split(_spaces)
        .map((t) => t.replaceAll(_edgeNoise, ''))
        .where((t) => t.isNotEmpty)
        .toList();

    if (tokens.length > 1 && _articles.contains(tokens.first)) {
      tokens = tokens.sublist(1);
    }

    if (tokens.length == 1 || _isCompound(tokens)) {
      final word = _clean(tokens.join(' '));
      if (word != null) yield word;
      return;
    }

    for (final token in tokens) {
      if (_stopWords.contains(token)) continue;
      final word = _clean(token);
      if (word != null) yield word;
    }
  }

  /// "pomme de terre", "salle à manger", "chemin de fer".
  bool _isCompound(List<String> tokens) =>
      tokens.length == 3 && _linkWords.contains(tokens[1]);

  String? _clean(String text) {
    final word = text.replaceFirst(_elidedArticle, '').trim();
    if (word.length < 2) return null;

    final letters = _letter.allMatches(word).length;
    final forbidden = word.replaceAll(_wordChars, '');
    if (forbidden.isNotEmpty) return null;
    if (letters < word.length * 0.7) return null;
    return word;
  }
}
