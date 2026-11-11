/// Utility functions for French string handling with proper accent support.
///
/// Handles Unicode normalization (NFC) to ensure accented characters
/// are stored and compared consistently, regardless of how the keyboard
/// sends them (composed vs decomposed form).
library;

import 'package:characters/characters.dart';

/// Map of common NFD (decomposed) sequences to their NFC (composed) equivalents.
/// Covers all French accented characters.
const _nfdToNfc = {
  'a\u0300': 'à',
  'a\u0301': 'á',
  'a\u0302': 'â',
  'a\u0308': 'ä',
  'c\u0327': 'ç',
  'e\u0300': 'è',
  'e\u0301': 'é',
  'e\u0302': 'ê',
  'e\u0308': 'ë',
  'i\u0300': 'ì',
  'i\u0302': 'î',
  'i\u0308': 'ï',
  'o\u0300': 'ò',
  'o\u0302': 'ô',
  'o\u0308': 'ö',
  'u\u0300': 'ù',
  'u\u0301': 'ú',
  'u\u0302': 'û',
  'u\u0308': 'ü',
  'y\u0308': 'ÿ',
  // Uppercase variants
  'A\u0300': 'À',
  'A\u0301': 'Á',
  'A\u0302': 'Â',
  'A\u0308': 'Ä',
  'C\u0327': 'Ç',
  'E\u0300': 'È',
  'E\u0301': 'É',
  'E\u0302': 'Ê',
  'E\u0308': 'Ë',
  'I\u0300': 'Ì',
  'I\u0302': 'Î',
  'I\u0308': 'Ï',
  'O\u0300': 'Ò',
  'O\u0302': 'Ô',
  'O\u0308': 'Ö',
  'U\u0300': 'Ù',
  'U\u0301': 'Ú',
  'U\u0302': 'Û',
  'U\u0308': 'Ü',
  'Y\u0308': 'Ÿ',
};

/// Regex matching Unicode combining diacritical marks (U+0300-U+036F).
final _combiningMarks = RegExp('[\u0300-\u036F]');

/// Normalize a string to NFC form for consistent French accent handling.
///
/// Converts decomposed characters (e + combining accent) to their
/// precomposed equivalents (é). This ensures consistent storage
/// and comparison regardless of keyboard input method.
String normalizeNFC(String input) {
  if (!_combiningMarks.hasMatch(input)) return input;

  var result = input;
  for (final entry in _nfdToNfc.entries) {
    result = result.replaceAll(entry.key, entry.value);
  }
  return result;
}

/// Split a string into grapheme clusters (visual characters).
///
/// Unlike `split('')` which splits by UTF-16 code units,
/// this correctly handles accented characters that may be
/// represented as multiple code units (NFD form).
///
/// Example: 'école' → ['é', 'c', 'o', 'l', 'e']
List<String> splitGraphemes(String input) {
  return input.characters.toList();
}

/// Get the number of visual characters (grapheme clusters) in a string.
int graphemeLength(String input) {
  return input.characters.length;
}

/// Get grapheme at a specific position.
String graphemeAt(String input, int index) {
  return input.characters.elementAt(index);
}

/// Compare two strings for equality after NFC normalization and lowercasing.
bool normalizedEquals(String a, String b) {
  return normalizeNFC(a).toLowerCase() == normalizeNFC(b).toLowerCase();
}

/// Extension on String for convenient access to normalization.
extension FrenchStringExtension on String {
  /// Normalize to NFC form.
  String get nfc => normalizeNFC(this);

  /// Split into grapheme clusters.
  List<String> get graphemes => splitGraphemes(this);

  /// Number of visual characters.
  int get graphemeLen => graphemeLength(this);
}
