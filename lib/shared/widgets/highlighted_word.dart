import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/utils/string_utils.dart';

/// A word whose letter at [position] (grapheme index) is drawn in
/// [highlightColor]: the letter being spelled aloud.
///
/// A word too long for its room shrinks to stay on one line, down to
/// [minScale] of its size; past that, it wraps at that size.
class HighlightedWord extends StatelessWidget {
  final String word;
  final int? position;
  final TextStyle style;
  final Color highlightColor;
  final TextAlign? textAlign;

  /// Smallest size, as a share of [style]'s, a long word shrinks to.
  final double minScale;

  const HighlightedWord({
    super.key,
    required this.word,
    required this.position,
    required this.style,
    this.highlightColor = AppColors.accent,
    this.textAlign,
    this.minScale = 0.6,
  });

  @override
  Widget build(BuildContext context) {
    final letters = word.graphemes;
    final span = TextSpan(
      children: [
        for (var i = 0; i < letters.length; i++)
          TextSpan(
            text: letters[i],
            style: i == position ? TextStyle(color: highlightColor) : null,
          ),
      ],
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final style = DefaultTextStyle.of(context).style.merge(this.style);
        final scale = constraints.hasBoundedWidth
            ? _fitScale(context, span, style, constraints.maxWidth)
            : 1.0;
        return Text.rich(
          span,
          style: style.copyWith(fontSize: (style.fontSize ?? 14) * scale),
          textAlign: textAlign,
          maxLines: scale > minScale ? 1 : null,
        );
      },
    );
  }

  /// Scale at which [span] fits [maxWidth] on one line, between [minScale]
  /// and 1.
  double _fitScale(
    BuildContext context,
    TextSpan span,
    TextStyle style,
    double maxWidth,
  ) {
    final painter = TextPainter(
      text: TextSpan(style: style, children: [span]),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final width = painter.width;
    painter.dispose();
    if (width <= maxWidth) return 1;
    // A hair under the exact ratio, so rounding never pushes a letter out.
    return (maxWidth / width * 0.98).clamp(minScale, 1.0);
  }
}
