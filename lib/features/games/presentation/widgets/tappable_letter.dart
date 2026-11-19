import 'package:flutter/material.dart';

/// A typed letter the child can tap to move the cursor next to it:
/// [onTapBefore] on its left half, [onTapAfter] on its right half.
class TappableLetter extends StatelessWidget {
  final String letter;
  final TextStyle style;
  final VoidCallback onTapBefore;
  final VoidCallback onTapAfter;

  const TappableLetter({
    super.key,
    required this.letter,
    required this.style,
    required this.onTapBefore,
    required this.onTapAfter,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (details) {
        final width = context.size?.width ?? 0;
        details.localPosition.dx < width / 2 ? onTapBefore() : onTapAfter();
      },
      child: Text(letter, style: style),
    );
  }
}
