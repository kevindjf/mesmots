import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/utils/string_utils.dart';
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
    final letters = widget.word.graphemes;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text.rich(
            TextSpan(
              children: [
                for (var i = 0; i < letters.length; i++)
                  TextSpan(
                    text: letters[i],
                    style: i == _position
                        ? const TextStyle(color: AppColors.accent)
                        : null,
                  ),
              ],
            ),
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
