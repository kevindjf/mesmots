import 'package:mesmots/features/games/domain/entities/grid_point.dart';
import 'package:mesmots/features/games/domain/entities/placed_word.dart';

/// A square word search grid with its hidden words.
class WordSearchGrid {
  final int size;

  /// Letters, indexed as [row][col]
  final List<List<String>> letters;

  final List<PlacedWord> words;

  const WordSearchGrid({
    required this.size,
    required this.letters,
    required this.words,
  });

  String letterAt(GridPoint point) => letters[point.row][point.col];

  /// Index of the word matching exactly [selection] (in any reading
  /// direction), or null.
  int? wordIndexFor(List<GridPoint> selection) {
    for (var i = 0; i < words.length; i++) {
      final cells = words[i].cells;
      if (_sameCells(cells, selection) ||
          _sameCells(cells.reversed.toList(), selection)) {
        return i;
      }
    }
    return null;
  }

  static bool _sameCells(List<GridPoint> a, List<GridPoint> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
