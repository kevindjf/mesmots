import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/shared/widgets/highlighted_word.dart';
import 'package:mesmots/shared/widgets/spell_button.dart';

/// A word shown with a [SpellButton]: while the word is spelled aloud, the
/// letter being said is highlighted.
class SpelledWord extends StatefulWidget {
  final String word;
  final TextStyle style;
  final double buttonSize;

  const SpelledWord({
    super.key,
    required this.word,
    required this.style,
    this.buttonSize = 40.0,
  });

  @override
  State<SpelledWord> createState() => _SpelledWordState();
}

class _SpelledWordState extends State<SpelledWord> {
  int? _position;

  @override
  void didUpdateWidget(SpelledWord oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.word != widget.word) _position = null;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: HighlightedWord(
            word: widget.word,
            position: _position,
            style: widget.style,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingM),
        SpellButton(
          word: widget.word,
          size: widget.buttonSize,
          onLetter: (position) => setState(() => _position = position),
        ),
      ],
    );
  }
}
