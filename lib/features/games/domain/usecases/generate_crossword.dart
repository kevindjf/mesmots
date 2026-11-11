import 'dart:math';

import 'package:mesmots/core/utils/string_utils.dart';
import 'package:mesmots/features/games/domain/entities/crossword.dart';
import 'package:mesmots/features/games/domain/entities/grid_point.dart';
import 'package:mesmots/features/games/domain/entities/placed_word.dart';

/// Builds a crossword from a word list.
///
/// Each word is placed on a common letter of an already placed word, with
/// no side contact between parallel words. Several orders are tried and
/// the grid placing the most words (then the most compact) is kept.
class GenerateCrossword {
  static const int maxDimension = 13;
  static const int _attempts = 40;

  /// Letters missing from the in-app keyboard, always given
  static const Set<String> _notTypeable = {'Œ', 'Æ', 'Ÿ', 'Ü', 'Ö', 'Ä'};

  final Random _random;

  GenerateCrossword({Random? random}) : _random = random ?? Random();

  Crossword call(List<String> words) {
    final entries = <({String word, List<String> letters})>[
      for (final word in words.toSet())
        if (word.gridLetters.length >= 2 &&
            word.gridLetters.length <= maxDimension)
          (word: word, letters: word.gridLetters),
    ];
    if (entries.isEmpty) return Crossword.empty;

    List<PlacedWord> best = const [];
    int? bestArea;

    for (var attempt = 0; attempt < _attempts; attempt++) {
      final order = List.of(entries)..shuffle(_random);
      if (attempt == 0) {
        order.sort((a, b) => b.letters.length.compareTo(a.letters.length));
      }
      final placed = _build(order);
      final area = _area(placed);
      if (placed.length > best.length ||
          (placed.length == best.length &&
              (bestArea == null || area < bestArea))) {
        best = placed;
        bestArea = area;
      }
      if (best.length == entries.length && attempt >= _attempts ~/ 4) break;
    }

    return _finalize(best);
  }

  List<PlacedWord> _build(List<({String word, List<String> letters})> order) {
    final grid = _Grid();
    final placed = <PlacedWord>[];

    final first = order.first;
    final start = PlacedWord(
      word: first.word,
      letters: first.letters,
      start: const GridPoint(0, 0),
      direction: WordDirection.horizontal,
    );
    grid.add(start);
    placed.add(start);

    var pending = order.sublist(1);
    var progress = true;
    while (pending.isNotEmpty && progress) {
      progress = false;
      final stillPending = <({String word, List<String> letters})>[];
      for (final entry in pending) {
        final candidate = _bestPlacement(grid, entry.word, entry.letters);
        if (candidate == null) {
          stillPending.add(entry);
        } else {
          grid.add(candidate);
          placed.add(candidate);
          progress = true;
        }
      }
      pending = stillPending;
    }
    return placed;
  }

  PlacedWord? _bestPlacement(_Grid grid, String word, List<String> letters) {
    // Avoid bit shifts for sentinels: on the web they yield unsigned values.
    PlacedWord? best;
    int? bestScore;

    for (final cell in grid.letters.entries) {
      for (var i = 0; i < letters.length; i++) {
        if (letters[i] != cell.value) continue;

        for (final direction in WordDirection.values) {
          if (grid.directions[cell.key]!.contains(direction)) continue;
          final candidate = PlacedWord(
            word: word,
            letters: letters,
            start: GridPoint(
              cell.key.row - i * direction.rowStep,
              cell.key.col - i * direction.colStep,
            ),
            direction: direction,
          );
          final crossings = grid.crossings(candidate);
          if (crossings == null) continue;

          final bounds = grid.boundsWith(candidate);
          if (bounds.rows > maxDimension || bounds.cols > maxDimension) {
            continue;
          }
          final score = crossings * 20 -
              bounds.rows * bounds.cols -
              (bounds.rows - bounds.cols).abs() * 2 +
              _random.nextInt(3);
          if (bestScore == null || score > bestScore) {
            bestScore = score;
            best = candidate;
          }
        }
      }
    }
    return best;
  }

  int _area(List<PlacedWord> placed) {
    final grid = _Grid();
    placed.forEach(grid.add);
    final bounds = grid.bounds;
    return bounds.rows * bounds.cols;
  }

  Crossword _finalize(List<PlacedWord> placed) {
    final grid = _Grid();
    placed.forEach(grid.add);
    final minRow = grid.minRow;
    final minCol = grid.minCol;

    final shifted = [
      for (final word in placed)
        PlacedWord(
          word: word.word,
          letters: word.letters,
          start: GridPoint(word.start.row - minRow, word.start.col - minCol),
          direction: word.direction,
        ),
    ];

    // Number words by start cell, reading order
    final starts = shifted.map((w) => w.start).toSet().toList()
      ..sort((a, b) => a.row != b.row ? a.row - b.row : a.col - b.col);
    final numbers = {for (var i = 0; i < starts.length; i++) starts[i]: i + 1};
    final entries = [
      for (final word in shifted)
        CrosswordEntry(number: numbers[word.start]!, placement: word),
    ]..sort(
        (a, b) => a.direction != b.direction
            ? a.direction.index - b.direction.index
            : a.number - b.number,
      );

    final solution = <GridPoint, String>{};
    final prefilled = <GridPoint>{};
    for (final entry in entries) {
      final cells = entry.cells;
      for (var i = 0; i < cells.length; i++) {
        solution[cells[i]] = entry.letters[i];
        if (_isGiven(i, entry.letters)) prefilled.add(cells[i]);
      }
    }

    final bounds = grid.bounds;
    return Crossword(
      rows: placed.isEmpty ? 0 : bounds.rows,
      cols: placed.isEmpty ? 0 : bounds.cols,
      entries: entries,
      solution: solution,
      prefilled: prefilled,
    );
  }

  /// First letter, one letter out of four for long words, and letters the
  /// keyboard cannot type.
  static bool _isGiven(int index, List<String> letters) {
    if (_notTypeable.contains(letters[index])) return true;
    if (index == 0) return true;
    return letters.length > 6 && index % 4 == 0;
  }
}

/// Mutable grid used while placing words.
class _Grid {
  final Map<GridPoint, String> letters = {};
  final Map<GridPoint, Set<WordDirection>> directions = {};

  void add(PlacedWord word) {
    final cells = word.cells;
    for (var i = 0; i < cells.length; i++) {
      letters[cells[i]] = word.letters[i];
      directions.putIfAbsent(cells[i], () => {}).add(word.direction);
    }
  }

  /// Number of crossings if [word] can be placed, null otherwise.
  int? crossings(PlacedWord word) {
    final cells = word.cells;
    final dir = word.direction;
    final before = GridPoint(
      word.start.row - dir.rowStep,
      word.start.col - dir.colStep,
    );
    final after = GridPoint(
      cells.last.row + dir.rowStep,
      cells.last.col + dir.colStep,
    );
    if (letters.containsKey(before) || letters.containsKey(after)) return null;

    var count = 0;
    for (var i = 0; i < cells.length; i++) {
      final cell = cells[i];
      final existing = letters[cell];
      if (existing != null) {
        if (existing != word.letters[i]) return null;
        if (directions[cell]!.contains(dir)) return null;
        count++;
        continue;
      }
      // Empty cell: no letter on either side (perpendicular to the word)
      final sideA = GridPoint(cell.row + dir.colStep, cell.col + dir.rowStep);
      final sideB = GridPoint(cell.row - dir.colStep, cell.col - dir.rowStep);
      if (letters.containsKey(sideA) || letters.containsKey(sideB)) return null;
    }
    return count == 0 ? null : count;
  }

  int get minRow => letters.keys.map((p) => p.row).reduce(min);
  int get minCol => letters.keys.map((p) => p.col).reduce(min);

  ({int rows, int cols}) get bounds => _boundsOf(letters.keys);

  ({int rows, int cols}) boundsWith(PlacedWord word) =>
      _boundsOf([...letters.keys, ...word.cells]);

  static ({int rows, int cols}) _boundsOf(Iterable<GridPoint> points) {
    if (points.isEmpty) return (rows: 0, cols: 0);
    final rows = points.map((p) => p.row);
    final cols = points.map((p) => p.col);
    return (
      rows: rows.reduce(max) - rows.reduce(min) + 1,
      cols: cols.reduce(max) - cols.reduce(min) + 1,
    );
  }
}
