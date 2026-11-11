import 'dart:math';

import 'package:mesmots/core/utils/string_utils.dart';
import 'package:mesmots/features/games/domain/entities/grid_point.dart';
import 'package:mesmots/features/games/domain/entities/placed_word.dart';
import 'package:mesmots/features/games/domain/entities/word_search_grid.dart';

/// Builds a word search grid from a word list.
///
/// Words are placed left-to-right or top-to-bottom only (readable for
/// 5-10 year olds). Accents are kept, and filler letters include letters
/// from the words so accented letters are not a giveaway.
class GenerateWordSearch {
  static const int minSize = 8;
  static const int maxSize = 12;
  static const int _attemptsPerWord = 200;
  static const String _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  final Random _random;

  GenerateWordSearch({Random? random}) : _random = random ?? Random();

  WordSearchGrid call(List<String> words) {
    final entries = <({String word, List<String> letters})>[
      for (final word in words.toSet())
        if (word.gridLetters.length >= 2)
          (word: word, letters: word.gridLetters),
    ]..sort((a, b) => b.letters.length.compareTo(a.letters.length));

    if (entries.isEmpty) {
      return const WordSearchGrid(size: 0, letters: [], words: []);
    }

    final longest = entries.first.letters.length;
    final startSize = max(longest + 1, minSize);
    final sizeLimit = max(maxSize, longest);
    var size = min(startSize, sizeLimit);

    while (true) {
      final placed = _tryPlaceAll(entries, size);
      if (placed != null || size >= sizeLimit) {
        return _fill(size, placed ?? _placeWhatFits(entries, size));
      }
      size++;
    }
  }

  /// Places every word or returns null.
  List<PlacedWord>? _tryPlaceAll(
    List<({String word, List<String> letters})> entries,
    int size,
  ) {
    final placed = _placeWhatFits(entries, size);
    return placed.length == entries.length ? placed : null;
  }

  List<PlacedWord> _placeWhatFits(
    List<({String word, List<String> letters})> entries,
    int size,
  ) {
    final grid = List.generate(size, (_) => List<String?>.filled(size, null));
    final placed = <PlacedWord>[];

    for (final entry in entries) {
      final word = _placeWord(grid, entry.word, entry.letters, size);
      if (word != null) placed.add(word);
    }
    return placed;
  }

  PlacedWord? _placeWord(
    List<List<String?>> grid,
    String word,
    List<String> letters,
    int size,
  ) {
    if (letters.length > size) return null;

    for (var attempt = 0; attempt < _attemptsPerWord; attempt++) {
      final direction = WordDirection.values[_random.nextInt(2)];
      final maxRow =
          direction == WordDirection.vertical ? size - letters.length : size - 1;
      final maxCol = direction == WordDirection.horizontal
          ? size - letters.length
          : size - 1;
      final candidate = PlacedWord(
        word: word,
        letters: letters,
        start: GridPoint(_random.nextInt(maxRow + 1), _random.nextInt(maxCol + 1)),
        direction: direction,
      );

      if (_fits(grid, candidate)) {
        final cells = candidate.cells;
        for (var i = 0; i < cells.length; i++) {
          grid[cells[i].row][cells[i].col] = letters[i];
        }
        return candidate;
      }
    }
    return null;
  }

  bool _fits(List<List<String?>> grid, PlacedWord candidate) {
    final cells = candidate.cells;
    for (var i = 0; i < cells.length; i++) {
      final current = grid[cells[i].row][cells[i].col];
      if (current != null && current != candidate.letters[i]) return false;
    }
    return true;
  }

  WordSearchGrid _fill(int size, List<PlacedWord> placed) {
    final grid = List.generate(size, (_) => List<String?>.filled(size, null));
    for (final word in placed) {
      final cells = word.cells;
      for (var i = 0; i < cells.length; i++) {
        grid[cells[i].row][cells[i].col] = word.letters[i];
      }
    }

    final wordLetters = [for (final w in placed) ...w.letters];
    String filler() {
      if (wordLetters.isNotEmpty && _random.nextDouble() < 0.3) {
        return wordLetters[_random.nextInt(wordLetters.length)];
      }
      return _alphabet[_random.nextInt(_alphabet.length)];
    }

    return WordSearchGrid(
      size: size,
      letters: [
        for (final row in grid) [for (final cell in row) cell ?? filler()],
      ],
      words: placed,
    );
  }
}
