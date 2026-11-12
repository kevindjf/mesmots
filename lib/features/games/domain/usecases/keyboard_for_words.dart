import 'package:mesmots/core/utils/string_utils.dart';

/// Extra keys a keyboard needs for a list of words.
class KeyboardKeys {
  /// Accented letters (and œ) to show, at most [maxAccents].
  final List<String> accents;

  final bool hasSpace;
  final bool hasHyphen;
  final bool hasApostrophe;

  const KeyboardKeys({
    required this.accents,
    required this.hasSpace,
    required this.hasHyphen,
    required this.hasApostrophe,
  });
}

/// Picks the extra keys for [words]: the accents they use, completed with
/// the most common ones (é, è, ê, à, ç) so they also act as traps, and the
/// space, hyphen or apostrophe only if a word has one.
KeyboardKeys keyboardForWords(List<String> words) {
  const order = [
    'é',
    'è',
    'ê',
    'ë',
    'à',
    'â',
    'ç',
    'ù',
    'û',
    'î',
    'ï',
    'ô',
    'œ',
    'æ',
  ];
  const common = ['é', 'è', 'ê', 'à', 'ç'];
  const maxAccents = 10;

  final letters = {
    for (final word in words) ...word.nfc.toLowerCase().graphemes,
  };
  final used = order.where(letters.contains).toList();
  final accents = <String>{
    ...used,
    ...common,
  }.take(maxAccents).toList()
    ..sort((a, b) => order.indexOf(a).compareTo(order.indexOf(b)));

  return KeyboardKeys(
    accents: accents,
    hasSpace: letters.contains(' '),
    hasHyphen: letters.contains('-'),
    hasApostrophe: letters.contains("'") || letters.contains('’'),
  );
}
