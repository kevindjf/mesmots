import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/utils/string_utils.dart';

/// A word whose letter at [position] (grapheme index) is drawn in
/// [highlightColor]: the letter being spelled aloud.
class HighlightedWord extends StatelessWidget {
  final String word;
  final int? position;
  final TextStyle style;
  final Color highlightColor;
  final TextAlign? textAlign;

  const HighlightedWord({
    super.key,
    required this.word,
    required this.position,
    required this.style,
    this.highlightColor = AppColors.accent,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final letters = word.graphemes;
    return Text.rich(
      TextSpan(
        children: [
          for (var i = 0; i < letters.length; i++)
            TextSpan(
              text: letters[i],
              style: i == position ? TextStyle(color: highlightColor) : null,
            ),
        ],
      ),
      style: style,
      textAlign: textAlign,
    );
  }
}
