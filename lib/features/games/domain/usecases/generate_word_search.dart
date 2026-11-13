import 'dart:math';

import 'package:mesmots/core/utils/string_utils.dart';
import 'package:mesmots/features/games/domain/entities/grid_point.dart';
import 'package:mesmots/features/games/domain/entities/placed_word.dart';
import 'package:mesmots/features/games/domain/entities/word_search_grid.dart';
import 'package:mesmots/features/games/domain/usecases/letter_confusions.dart';

/// Builds a word search grid from a word list.
///
/// Words are placed left-to-right, top-to-bottom or diagonally down to the
/// right: always in reading order, never backwards (readable for 5-10 year
/// olds). Letters are lowercase with their accents. Filler
/// letters come from the words and the letters children confuse them with
/// (e/é/è, s/ss/c…), so a word can't be spotted by a rare letter and the
/// grid holds near-words that must be read carefully.
class GenerateWordSearch {
  static const int minSize = 8;
  static const int maxSize = 12;
  static const int _attemptsPerWord = 200;
  static const String _alphabet = 'abcdefghijklmnopqrstuvwxyz';

  final Random _random;

  GenerateWordSearch({Random? random}) : _random = random ?? Random();

  WordSearchGrid call(List<String> words) {
    final entries = <({String word, List<String> letters})>[
      for (final word in words.toSet())
        if (word.gridLetters.length >= 2)
          // Lowercase, like the words the child learns.
          (
            word: word,
            letters: [for (final l in word.gridLetters) l.toLowerCase()],
          ),
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
      final direction =
          WordDirection.values[_random.nextInt(WordDirection.values.length)];
      final maxRow = direction.rowStep == 1 ? size - letters.length : size - 1;
      final maxCol = direction.colStep == 1 ? size - letters.length : size - 1;
      final candidate = PlacedWord(
        word: word,
        letters: letters,
        start:
            GridPoint(_random.nextInt(maxRow + 1), _random.nextInt(maxCol + 1)),
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
    final traps = [
      for (final letter in wordLetters.toSet())
        ...?letterConfusions[letter]?.where((c) => c.length == 1),
    ];
    String filler() {
      final roll = _random.nextDouble();
      if (wordLetters.isNotEmpty && roll < 0.5) {
        return wordLetters[_random.nextInt(wordLetters.length)];
      }
      if (traps.isNotEmpty && roll < 0.8) {
        return traps[_random.nextInt(traps.length)];
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
