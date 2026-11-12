import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/features/games/presentation/providers/scramble_game_provider.dart';
import 'package:mesmots/features/games/presentation/widgets/letter_slot.dart';
import 'package:mesmots/shared/widgets/shake.dart';

/// The row of answer boxes of "Lettres mélangées", sized to fit the word.
/// Shakes when the answer is wrong.
class ScrambleAnswer extends StatelessWidget {
  static const _maxSlotSize = 48.0;
  static const _gap = AppDimensions.spacingXs;

  final ScrambleQuestion question;
  final ValueChanged<int> onSlotTap;

  const ScrambleAnswer({
    super.key,
    required this.question,
    required this.onSlotTap,
  });

  LetterSlotState _stateOf(int slot) {
    switch (question.phase) {
      case ScramblePhase.correct:
        return LetterSlotState.correct;
      case ScramblePhase.wrong:
        return question.wrongSlots.contains(slot)
            ? LetterSlotState.wrong
            : LetterSlotState.correct;
      case ScramblePhase.playing:
        if (question.slots[slot] == null) return LetterSlotState.empty;
        return question.lockedSlots.contains(slot)
            ? LetterSlotState.locked
            : LetterSlotState.filled;
    }
  }

  @override
  Widget build(BuildContext context) {
    final count = question.slots.length;
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(
          _maxSlotSize,
          (constraints.maxWidth - _gap * (count - 1)) / count,
        );
        return Shake(
          trigger: question.phase == ScramblePhase.wrong ? 1 : 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < count; i++) ...[
                if (i > 0) const SizedBox(width: _gap),
                LetterSlot(
                  letter: question.letterAt(i),
                  state: _stateOf(i),
                  size: size,
                  onTap: () => onSlotTap(i),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
