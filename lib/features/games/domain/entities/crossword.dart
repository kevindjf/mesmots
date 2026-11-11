import 'package:mesmots/features/games/domain/entities/grid_point.dart';
import 'package:mesmots/features/games/domain/entities/placed_word.dart';

/// A numbered word in a crossword.
class CrosswordEntry {
  final int number;
  final PlacedWord placement;

  const CrosswordEntry({required this.number, required this.placement});

  String get word => placement.word;
  WordDirection get direction => placement.direction;
  List<GridPoint> get cells => placement.cells;
  List<String> get letters => placement.letters;
}

/// A crossword built from the week's words.
///
/// Clues are the words read aloud; [prefilled] cells are given to the
/// child so each answer is unambiguous and never frustrating.
class Crossword {
  /// Minimum number of placed words for the game to be playable
  static const int minWords = 3;

  final int rows;
  final int cols;
  final List<CrosswordEntry> entries;

  /// Solution letter of every used cell
  final Map<GridPoint, String> solution;

  /// Cells shown to the child from the start
  final Set<GridPoint> prefilled;

  const Crossword({
    required this.rows,
    required this.cols,
    required this.entries,
    required this.solution,
    required this.prefilled,
  });

  static const empty = Crossword(
    rows: 0,
    cols: 0,
    entries: [],
    solution: {},
    prefilled: {},
  );

  bool get isPlayable => entries.length >= minWords;

  bool isCell(GridPoint point) => solution.containsKey(point);

  /// Number displayed in the cell, if a word starts there
  int? numberAt(GridPoint point) {
    for (final entry in entries) {
      if (entry.placement.start == point) return entry.number;
    }
    return null;
  }

  /// Indexes of the entries crossing [point]
  List<int> entriesAt(GridPoint point) => [
        for (var i = 0; i < entries.length; i++)
          if (entries[i].cells.contains(point)) i,
      ];
}
