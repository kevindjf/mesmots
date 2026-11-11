import 'package:mesmots/features/games/domain/entities/grid_point.dart';

/// A word placed in a letter grid.
class PlacedWord {
  /// Original word, as written in the list
  final String word;

  /// Grid letters of the word (uppercase, separators removed)
  final List<String> letters;

  /// First cell of the word
  final GridPoint start;

  final WordDirection direction;

  const PlacedWord({
    required this.word,
    required this.letters,
    required this.start,
    required this.direction,
  });

  int get length => letters.length;

  /// Cells covered by the word, in reading order
  List<GridPoint> get cells => List.generate(
        length,
        (i) => GridPoint(
          start.row + i * direction.rowStep,
          start.col + i * direction.colStep,
        ),
      );
}
