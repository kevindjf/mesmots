import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/extensions/motion_context.dart';
import 'package:mesmots/shared/widgets/jump_on_tap.dart';
import 'package:mesmots/shared/widgets/letter_tile.dart';
import 'package:mesmots/shared/widgets/pop_in.dart';

/// A word spelled with colorful 3D letter tiles that drop in one by one.
///
/// Once they have landed, a wave runs through the tiles every few seconds,
/// and each tile jumps when tapped.
class LetterTilesTitle extends StatefulWidget {
  static const _palette = [
    (AppColors.buttonOrange, AppColors.buttonOrangeShadow),
    (AppColors.buttonPink, AppColors.buttonPinkShadow),
    (AppColors.buttonBlue, AppColors.buttonBlueShadow),
    (AppColors.buttonMagenta, AppColors.buttonMagentaShadow),
    (AppColors.buttonCoral, AppColors.buttonCoralShadow),
  ];

  final String text;
  final double tileSize;
  final Duration delay;
  final Duration stagger;

  const LetterTilesTitle({
    super.key,
    required this.text,
    this.tileSize = 44,
    this.delay = Duration.zero,
    this.stagger = const Duration(milliseconds: 90),
  });

  @override
  State<LetterTilesTitle> createState() => _LetterTilesTitleState();
}

class _LetterTilesTitleState extends State<LetterTilesTitle>
    with SingleTickerProviderStateMixin {
  static const _palette = LetterTilesTitle._palette;

  /// Height of the wave, in logical pixels.
  static const _waveHeight = 12.0;

  /// Time for the wave to move from one tile to the next.
  static const _slot = Duration(milliseconds: 250);

  /// Slots after the bump has started on the last tile before it starts
  /// again on the first one. The bump lasts 2 slots, so 1 keeps the wave
  /// almost continuous: the first tile rises while the last one comes down.
  static const _restSlots = 1;

  late final AnimationController _wave = AnimationController(
    vsync: this,
    duration: _slot * (_tileCount + _restSlots),
  );
  bool _waveStarted = false;

  int get _tileCount => widget.text.replaceAll(' ', '').characters.length;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_waveStarted || context.reduceMotion) return;
    _waveStarted = true;
    // Start once every tile has landed.
    final landed = widget.delay +
        widget.stagger * _tileCount +
        const Duration(milliseconds: 900);
    Future<void>.delayed(landed, () {
      if (mounted) _wave.repeat();
    });
  }

  @override
  void dispose() {
    _wave.dispose();
    super.dispose();
  }

  /// Lift of tile [i] at wave progress [t]: a bump travelling left to right.
  double _lift(int i, double t) {
    final phase = t * (_tileCount + _restSlots) - i;
    if (phase < 0 || phase > 2) return 0;
    return math.sin(phase / 2 * math.pi) * _waveHeight;
  }

  @override
  Widget build(BuildContext context) {
    // Each space starts a new row of tiles.
    final rows = widget.text.toUpperCase().split(' ');
    var index = 0;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final letter in row.characters)
                    _buildTile(letter, index++),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTile(String letter, int i) {
    final (color, shadowColor) = _palette[i % _palette.length];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: PopIn.drop(
        delay: widget.delay + widget.stagger * i,
        child: AnimatedBuilder(
          animation: _wave,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, -_lift(i, _wave.value)),
            child: child,
          ),
          child: JumpOnTap(
            child: LetterTile(
              letter: letter,
              size: widget.tileSize,
              color: color,
              shadowColor: shadowColor,
              // Alternate a slight tilt for a playful look.
              angle: i.isEven ? -0.06 : 0.06,
            ),
          ),
        ),
      ),
    );
  }
}
