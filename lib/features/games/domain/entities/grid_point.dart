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

/// Direction of a word in a grid.
enum WordDirection {
  horizontal,
  vertical;

  int get rowStep => this == WordDirection.vertical ? 1 : 0;
  int get colStep => this == WordDirection.horizontal ? 1 : 0;
}
