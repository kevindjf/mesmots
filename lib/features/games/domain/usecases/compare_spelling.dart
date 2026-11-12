import 'package:mesmots/core/utils/string_utils.dart';

/// Marks which letters the child typed right, to show a mistake letter by
/// letter: each typed letter is right when it belongs to the longest
/// sequence of letters shared, in order, with the word.
///
/// "ecolle" for "école" gives `[false, true, true, true, true, false]`:
/// the "e" lacks its accent and one "l" is extra.
List<bool> markTypedLetters(String typed, String word) {
  final a = typed.nfc.toLowerCase().graphemes;
  final b = word.nfc.toLowerCase().graphemes;

  // Longest common subsequence table.
  final lcs = List.generate(a.length + 1, (_) => List.filled(b.length + 1, 0));
  for (var i = a.length - 1; i >= 0; i--) {
    for (var j = b.length - 1; j >= 0; j--) {
      lcs[i][j] = a[i] == b[j]
          ? lcs[i + 1][j + 1] + 1
          : (lcs[i + 1][j] > lcs[i][j + 1] ? lcs[i + 1][j] : lcs[i][j + 1]);
    }
  }

  final marks = List.filled(a.length, false);
  var i = 0;
  var j = 0;
  while (i < a.length && j < b.length) {
    if (a[i] == b[j]) {
      marks[i] = true;
      i++;
      j++;
    } else if (lcs[i + 1][j] >= lcs[i][j + 1]) {
      i++;
    } else {
      j++;
    }
  }
  return marks;
}
