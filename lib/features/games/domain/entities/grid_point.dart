/// A cell position in a letter grid.
class GridPoint {
  final int row;
  final int col;

  const GridPoint(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      other is GridPoint && other.row == row && other.col == col;

  @override
  int get hashCode => Object.hash(row, col);

  @override
  String toString() => '($row, $col)';
}

/// Direction of a word in a grid, always in reading order.
enum WordDirection {
  horizontal,
  vertical,

  /// Top-left to bottom-right (word search only).
  diagonal;

  /// Directions where words cross in a crossword.
  static const straight = [horizontal, vertical];

  int get rowStep => this == WordDirection.horizontal ? 0 : 1;
  int get colStep => this == WordDirection.vertical ? 0 : 1;
}
