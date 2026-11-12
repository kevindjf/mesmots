import 'package:mesmots/core/utils/string_utils.dart';

/// Where the child is in a [LetterPuzzle].
enum PuzzlePhase {
  /// Placing letters.
  playing,

  /// All letters right.
  correct,

  /// Some letters wrong: shown before trying again.
  wrong,
}

/// A word to complete with letter tiles: some letters are given, the
/// others ("blanks") are filled by tapping tiles.
///
/// Used by "Lettres mélangées" (every letter is a blank, the tiles are the
/// word's letters shuffled) and "Mots à trous" (a few blanks, tiles include
/// decoys). Immutable: every action returns a new puzzle.
class LetterPuzzle {
  final String word;

  /// The word's letters (graphemes), in order.
  final List<String> letters;

  /// Positions in [letters] to fill, in order. Each one is a "slot".
  final List<int> blanks;

  /// Letters the child can place.
  final List<String> tiles;

  /// For each slot, the index of the tile placed there.
  final List<int?> slots;

  /// Slots that can't change any more: right letters kept after a mistake,
  /// or placed by the help.
  final Set<int> lockedSlots;

  /// Slots holding a wrong letter, while [phase] is [PuzzlePhase.wrong].
  final Set<int> wrongSlots;

  final PuzzlePhase phase;

  LetterPuzzle({
    required this.word,
    required this.blanks,
    required this.tiles,
  })  : letters = word.graphemes,
        slots = List<int?>.filled(blanks.length, null),
        lockedSlots = const {},
        wrongSlots = const {},
        phase = PuzzlePhase.playing;

  const LetterPuzzle._({
    required this.word,
    required this.letters,
    required this.blanks,
    required this.tiles,
    required this.slots,
    required this.lockedSlots,
    required this.wrongSlots,
    required this.phase,
  });

  /// Whether [letter] can be a blank: punctuation and spaces in compound
  /// words ("arc-en-ciel", "pomme de terre") are always given.
  static bool isFillable(String letter) =>
      RegExp(r'\p{L}', unicode: true).hasMatch(letter);

  /// Letter expected in [slot].
  String expectedAt(int slot) => letters[blanks[slot]];

  /// Letter placed in [slot], or null if empty.
  String? letterAt(int slot) {
    final tile = slots[slot];
    return tile == null ? null : tiles[tile];
  }

  /// Slot at [position] in the word, or null if that letter is given.
  int? slotAt(int position) {
    final slot = blanks.indexOf(position);
    return slot < 0 ? null : slot;
  }

  bool isTileUsed(int tile) => slots.contains(tile);

  bool get isFull => !slots.contains(null);

  bool get canPlay => phase == PuzzlePhase.playing;

  /// Whether some placed letter can be taken back.
  bool get hasRemovable => [
        for (var i = 0; i < slots.length; i++)
          slots[i] != null && !lockedSlots.contains(i),
      ].any((removable) => removable);

  /// Slots whose letter is not the expected one.
  Set<int> get mistakes => {
        for (var i = 0; i < slots.length; i++)
          if (letterAt(i) != expectedAt(i)) i,
      };

  /// Put [tile] in the first empty slot.
  LetterPuzzle place(int tile) {
    if (!canPlay || isTileUsed(tile)) return this;
    final slot = slots.indexOf(null);
    if (slot < 0) return this;
    return _copy(slots: [...slots]..[slot] = tile);
  }

  /// Send the letter in [slot] back to the tiles.
  LetterPuzzle remove(int slot) {
    if (!canPlay || slots[slot] == null || lockedSlots.contains(slot)) {
      return this;
    }
    return _copy(slots: [...slots]..[slot] = null);
  }

  /// Send the last letter placed (not locked) back to the tiles.
  LetterPuzzle removeLast() {
    for (var slot = slots.length - 1; slot >= 0; slot--) {
      if (slots[slot] != null && !lockedSlots.contains(slot)) {
        return remove(slot);
      }
    }
    return this;
  }

  /// Send every letter that isn't locked back to the tiles.
  LetterPuzzle clear() {
    if (!canPlay) return this;
    return _copy(
      slots: [
        for (var i = 0; i < slots.length; i++)
          lockedSlots.contains(i) ? slots[i] : null,
      ],
    );
  }

  /// Put the right letter in the first slot that doesn't have it, and lock
  /// it. A tile with that letter is taken from an unlocked slot if needed.
  LetterPuzzle hint() {
    if (!canPlay) return this;
    final slot = List.generate(slots.length, (i) => i).firstWhere(
      (i) => !lockedSlots.contains(i) && letterAt(i) != expectedAt(i),
      orElse: () => -1,
    );
    if (slot < 0) return this;

    final expected = expectedAt(slot);
    final newSlots = [...slots]..[slot] = null;
    var tile = List.generate(tiles.length, (t) => t).firstWhere(
      (t) => tiles[t] == expected && !newSlots.contains(t),
      orElse: () => -1,
    );
    if (tile < 0) {
      final from = List.generate(newSlots.length, (i) => i).firstWhere(
        (i) =>
            !lockedSlots.contains(i) &&
            newSlots[i] != null &&
            tiles[newSlots[i]!] == expected,
        orElse: () => -1,
      );
      if (from < 0) return this;
      tile = newSlots[from]!;
      newSlots[from] = null;
    }
    newSlots[slot] = tile;
    return _copy(slots: newSlots, lockedSlots: {...lockedSlots, slot});
  }

  /// Show the result of a full puzzle: correct, or wrong with the wrong
  /// slots marked.
  LetterPuzzle checked() {
    final wrong = mistakes;
    return _copy(
      phase: wrong.isEmpty ? PuzzlePhase.correct : PuzzlePhase.wrong,
      wrongSlots: wrong,
    );
  }

  /// After a mistake: keep and lock the right letters, send the wrong ones
  /// back, and play again.
  LetterPuzzle retry() {
    final wrong = mistakes;
    return _copy(
      slots: [
        for (var i = 0; i < slots.length; i++)
          wrong.contains(i) ? null : slots[i],
      ],
      lockedSlots: {
        ...lockedSlots,
        for (var i = 0; i < slots.length; i++)
          if (!wrong.contains(i)) i,
      },
      wrongSlots: const {},
      phase: PuzzlePhase.playing,
    );
  }

  LetterPuzzle _copy({
    List<int?>? slots,
    Set<int>? lockedSlots,
    Set<int>? wrongSlots,
    PuzzlePhase? phase,
  }) {
    return LetterPuzzle._(
      word: word,
      letters: letters,
      blanks: blanks,
      tiles: tiles,
      slots: slots ?? this.slots,
      lockedSlots: lockedSlots ?? this.lockedSlots,
      wrongSlots: wrongSlots ?? this.wrongSlots,
      phase: phase ?? this.phase,
    );
  }
}
