import 'package:flutter/material.dart';
import 'package:mesmots/core/extensions/palette_context.dart';

/// One dot per letter of a hidden word.
class LetterDots extends StatelessWidget {
  final int count;

  const LetterDots({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          Container(
            width: 7,
            height: 7,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: context.palette.panelHint,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }
}
