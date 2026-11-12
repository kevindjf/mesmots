import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/shared/widgets/keyboard_key.dart';

/// Lowercase AZERTY keyboard for children: keys 44 px high, one big
/// backspace, a row with the accents the words need, and space, hyphen or
/// apostrophe only when the words use them.
class ChildKeyboard extends StatelessWidget {
  static const _rows = [
    ['a', 'z', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
    ['q', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'm'],
    ['w', 'x', 'c', 'v', 'b', 'n'],
  ];
  static const _gap = 4.0;
  static const _rowGap = 8.0;

  /// Accented letters row (at most 10).
  final List<String> accents;
  final bool hasSpace;
  final bool hasHyphen;
  final bool hasApostrophe;
  final ValueChanged<String>? onLetter;
  final VoidCallback? onBackspace;

  const ChildKeyboard({
    super.key,
    required this.accents,
    this.hasSpace = false,
    this.hasHyphen = false,
    this.hasApostrophe = false,
    required this.onLetter,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final keyWidth = (constraints.maxWidth - _gap * 9) / 10;
        Widget letter(String l) => KeyboardKey(
              label: l,
              width: keyWidth,
              onTap: onLetter == null ? null : () => onLetter!(l),
            );

        Widget row(List<Widget> children) => Padding(
              padding: const EdgeInsets.only(bottom: _rowGap),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < children.length; i++) ...[
                    if (i > 0) const SizedBox(width: _gap),
                    children[i],
                  ],
                ],
              ),
            );

        final signs = [
          if (hasHyphen) letter('-'),
          if (hasApostrophe) letter("'"),
          if (hasSpace)
            KeyboardKey(
              icon: Icons.space_bar,
              width: keyWidth * 4,
              onTap: onLetter == null ? null : () => onLetter!(' '),
            ),
        ];

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            row([for (final l in _rows[0]) letter(l)]),
            row([for (final l in _rows[1]) letter(l)]),
            row([
              for (final l in _rows[2]) letter(l),
              KeyboardKey(
                icon: Icons.backspace_outlined,
                width: keyWidth * 2 + _gap,
                color: AppColors.buttonCoral,
                shadowColor: AppColors.buttonCoralShadow,
                contentColor: AppColors.textOnColor,
                onTap: onBackspace,
              ),
            ]),
            row([for (final l in accents) letter(l)]),
            if (signs.isNotEmpty) row(signs),
          ],
        );
      },
    );
  }
}
