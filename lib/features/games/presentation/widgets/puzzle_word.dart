import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/extensions/motion_context.dart';
import 'package:mesmots/features/games/domain/entities/letter_puzzle.dart';
import 'package:mesmots/features/games/presentation/widgets/letter_slot.dart';
import 'package:mesmots/shared/widgets/shake.dart';

/// The word of a [LetterPuzzle] as a row of letter boxes, sized to fit:
/// given letters, blanks to fill, and the result colors. Shakes when the
/// answer is wrong.
class PuzzleWord extends StatelessWidget {
  static const _maxSize = 48.0;
  static const _gap = AppDimensions.spacingXs;

  final LetterPuzzle puzzle;
  final ValueChanged<int> onSlotTap;

  /// Position of the letter being spelled aloud: its box pops up.
  final int? highlighted;

  const PuzzleWord({
    super.key,
    required this.puzzle,
    required this.onSlotTap,
    this.highlighted,
  });

  LetterSlotState _stateOf(int position) {
    final slot = puzzle.slotAt(position);
    switch (puzzle.phase) {
      case PuzzlePhase.correct:
        return LetterSlotState.correct;
      case PuzzlePhase.wrong:
        if (slot == null) return LetterSlotState.given;
        return puzzle.wrongSlots.contains(slot)
            ? LetterSlotState.wrong
            : LetterSlotState.correct;
      case PuzzlePhase.playing:
        if (slot == null) return LetterSlotState.given;
        if (puzzle.slots[slot] == null) return LetterSlotState.empty;
        return puzzle.lockedSlots.contains(slot)
            ? LetterSlotState.locked
            : LetterSlotState.filled;
    }
  }

  @override
  Widget build(BuildContext context) {
    final letters = puzzle.letters;
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = letters.length;
        final size = math.min(
          _maxSize,
          (constraints.maxWidth - _gap * (count - 1)) / count,
        );
        return Shake(
          trigger: puzzle.phase == PuzzlePhase.wrong ? 1 : 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < count; i++) ...[
                if (i > 0) const SizedBox(width: _gap),
                if (letters[i] == ' ')
                  SizedBox(width: size / 2)
                else
                  AnimatedSlide(
                    offset: Offset(0, i == highlighted ? -0.2 : 0),
                    duration: context.motion(
                      const Duration(milliseconds: 150),
                    ),
                    child: LetterSlot(
                      letter: puzzle.slotAt(i) == null
                          ? letters[i]
                          : puzzle.letterAt(puzzle.slotAt(i)!),
                      state: _stateOf(i),
                      size: size,
                      isHighlighted: i == highlighted,
                      onTap: puzzle.slotAt(i) == null
                          ? null
                          : () => onSlotTap(puzzle.slotAt(i)!),
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}
