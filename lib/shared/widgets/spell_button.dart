import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmots/core/extensions/palette_context.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/utils/haptic_service.dart';
import 'package:mesmots/core/utils/tts_service.dart';

/// Round button that says a word (unless [sayWordFirst] is false), then
/// spells it letter by letter
/// ("sept": S, E, P, T). Mr. Square style with a 3D shadow.
class SpellButton extends ConsumerStatefulWidget {
  final String word;
  final double size;
  final Color backgroundColor;
  final Color shadowColor;

  /// Position of the letter being said, then null when the spelling ends.
  final ValueChanged<int?>? onLetter;

  /// Say the whole word before its letters.
  final bool sayWordFirst;

  const SpellButton({
    super.key,
    required this.word,
    this.size = 56.0,
    this.backgroundColor = AppColors.buttonOrange,
    this.shadowColor = AppColors.buttonOrangeShadow,
    this.onLetter,
    this.sayWordFirst = true,
  });

  @override
  ConsumerState<SpellButton> createState() => _SpellButtonState();
}

class _SpellButtonState extends ConsumerState<SpellButton> {
  late final TtsService _tts = ref.read(ttsServiceProvider);
  bool _isPressed = false;
  bool _isSpelling = false;

  Future<void> _spell() async {
    ref.read(hapticServiceProvider).light().ignore();
    setState(() => _isSpelling = true);
    await _tts.spell(
      widget.word,
      sayWordFirst: widget.sayWordFirst,
      onLetter: (position) {
        if (mounted) widget.onLetter?.call(position);
      },
    );
    if (mounted) setState(() => _isSpelling = false);
  }

  @override
  void dispose() {
    // Don't keep spelling a word that is no longer on screen.
    if (_isSpelling) _tts.stop().ignore();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final offset = widget.size / 10;
    return Semantics(
      button: true,
      label: AppStrings.spellWord,
      child: Tooltip(
        message: AppStrings.spellWord,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            _spell();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: widget.size,
            height: widget.size,
            transform:
                Matrix4.translationValues(0, _isPressed ? offset / 2 : 0, 0),
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.shadowColor,
                  blurRadius: 0,
                  offset: Offset(0, _isPressed ? offset / 2 : offset),
                ),
              ],
            ),
            child: Icon(
              Icons.abc_rounded,
              color: context.palette.onBlock(widget.backgroundColor),
              size: widget.size * 0.6,
            ),
          ),
        ),
      ),
    );
  }
}
