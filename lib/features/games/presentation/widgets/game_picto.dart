import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/features/word_lists/domain/entities/game_type.dart';

/// Small drawing of what the child does in a game, made of the same white
/// letter tiles as the games, so a child who can't read yet recognizes it:
/// - Le bon mot: four answers, one ticked green (the 2×2 grid of the game).
/// - Lettres mélangées: the letters of "chat" tumbling in every direction.
/// - Écoute et épelle: a speaker saying "a", "b", "c", one letter lit up.
/// - Mots à trous: "ch_t" with the missing "a" dropping into the hole.
/// - Écriture: "ch" being typed (cursor) above a row of keys.
/// - Mots mêlés: a letter grid with one word circled.
/// - Mots croisés: two words crossing, one box still to fill.
///
/// Drawn on a 72×60 board and scaled to [width].
class GamePicto extends StatelessWidget {
  static const _boardWidth = 72.0;
  static const _boardHeight = 60.0;

  final GameType type;
  final double width;

  const GamePicto({super.key, required this.type, this.width = 72});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: width * _boardHeight / _boardWidth,
      child: FittedBox(
        child: SizedBox(
          width: _boardWidth,
          height: _boardHeight,
          child: switch (type) {
            GameType.qcm => const _Qcm(),
            GameType.scramble => const _Scramble(),
            GameType.spelling => const _Spelling(),
            GameType.fillBlanks => const _FillBlanks(),
            GameType.writing => const _Writing(),
            GameType.wordSearch => const _WordSearch(),
            GameType.crossword => const _Crossword(),
          },
        ),
      ),
    );
  }
}

/// One letter tile of a picto.
class _Tile extends StatelessWidget {
  final String? letter;
  final double size;
  final Color color;
  final Color letterColor;

  /// An empty box to fill: dashed-looking outline, no fill.
  final bool isEmpty;

  const _Tile(
    this.letter, {
    this.size = 16,
    this.color = AppColors.surface,
    this.letterColor = AppColors.textPrimary,
  }) : isEmpty = false;

  const _Tile.empty({this.size = 16})
      : letter = null,
        color = Colors.transparent,
        letterColor = Colors.transparent,
        isEmpty = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 1.12,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size / 4),
        border:
            isEmpty ? Border.all(color: AppColors.surface, width: 1.5) : null,
        boxShadow: isEmpty
            ? null
            : [
                BoxShadow(
                  color: AppColors.textPrimary.withValues(alpha: 0.25),
                  blurRadius: 0,
                  offset: const Offset(0, 1.5),
                ),
              ],
      ),
      child: letter == null
          ? null
          : Text(
              letter!,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: size * 0.68,
                fontWeight: AppTypography.bold,
                color: letterColor,
                height: 1,
              ),
            ),
    );
  }
}

/// A tile placed on the 72×60 board, optionally tilted.
class _Placed extends StatelessWidget {
  final double left;
  final double top;
  final double angle;
  final Widget child;

  const _Placed(this.left, this.top, this.child, {this.angle = 0});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Transform.rotate(angle: angle, child: child),
    );
  }
}

class _Qcm extends StatelessWidget {
  const _Qcm();

  Widget _answer({bool right = false}) {
    return Container(
      width: 30,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: right ? AppColors.success : AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: right
                ? AppColors.successShadow
                : AppColors.textPrimary.withValues(alpha: 0.25),
            blurRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: right
          ? const Icon(
              Icons.check_rounded,
              color: AppColors.textOnColor,
              size: 18,
            )
          // A word, drawn as a short line: the answers to choose from.
          : Container(
              width: 16,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.textLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_answer(), const SizedBox(width: 5), _answer(right: true)],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_answer(), const SizedBox(width: 5), _answer()],
        ),
      ],
    );
  }
}

class _Scramble extends StatelessWidget {
  const _Scramble();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        _Placed(10, 6, _Tile('t', size: 20), angle: -0.35),
        _Placed(38, 2, _Tile('a', size: 20), angle: 0.3),
        _Placed(16, 32, _Tile('h', size: 20), angle: 0.25),
        _Placed(42, 30, _Tile('c', size: 20), angle: -0.2),
      ],
    );
  }
}

class _Spelling extends StatelessWidget {
  const _Spelling();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned(
          left: 0,
          top: 16,
          child: Icon(
            Icons.volume_up_rounded,
            color: AppColors.textOnColor,
            size: 30,
          ),
        ),
        // The letters come out of the speaker one by one; "a" is being said.
        _Placed(
          32,
          4,
          _Tile(
            'a',
            size: 18,
            color: AppColors.accent,
            letterColor: AppColors.textOnColor,
          ),
        ),
        _Placed(42, 22, _Tile('b', size: 18)),
        _Placed(52, 40, _Tile('c', size: 16)),
      ],
    );
  }
}

class _FillBlanks extends StatelessWidget {
  const _FillBlanks();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        // The missing letter, dropping into the hole.
        _Placed(
          37,
          0,
          _Tile(
            'a',
            size: 15,
            color: AppColors.accent,
            letterColor: AppColors.textOnColor,
          ),
          angle: 0.2,
        ),
        Positioned(
          left: 38,
          top: 17,
          child: Icon(
            Icons.arrow_downward_rounded,
            color: AppColors.textOnColor,
            size: 14,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 33,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Tile('c'),
              SizedBox(width: 2),
              _Tile('h'),
              SizedBox(width: 2),
              _Tile.empty(),
              SizedBox(width: 2),
              _Tile('t'),
            ],
          ),
        ),
      ],
    );
  }
}

class _Writing extends StatelessWidget {
  const _Writing();

  Widget _key() {
    return Container(
      width: 11,
      height: 10,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(3),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.25),
            blurRadius: 0,
            offset: const Offset(0, 1.5),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // The word being typed, with the cursor.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const _Tile('c', size: 18),
            const SizedBox(width: 2),
            const _Tile('h', size: 18),
            const SizedBox(width: 3),
            Container(width: 2.5, height: 20, color: AppColors.textOnColor),
            const SizedBox(width: 12),
          ],
        ),
        const SizedBox(height: 8),
        // The keyboard.
        for (final count in [5, 4]) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < count; i++) ...[
                if (i > 0) const SizedBox(width: 2.5),
                _key(),
              ],
            ],
          ),
          const SizedBox(height: 3),
        ],
      ],
    );
  }
}

class _WordSearch extends StatelessWidget {
  const _WordSearch();

  static const _letters = [
    'x',
    'b',
    'o',
    'c',
    'h',
    'a',
    't',
    'p',
    'k',
    'u',
    'z',
    'e'
  ];

  @override
  Widget build(BuildContext context) {
    const size = 12.0;
    const gap = 2.0;
    return Center(
      child: SizedBox(
        width: 4 * size + 3 * gap + 8,
        height: 3 * size * 1.12 + 2 * gap + 8,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var row = 0; row < 3; row++) ...[
                  if (row > 0) const SizedBox(height: gap),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var col = 0; col < 4; col++) ...[
                        if (col > 0) const SizedBox(width: gap),
                        row == 1
                            ? _Tile(
                                _letters[row * 4 + col],
                                size: size,
                                color: AppColors.accent,
                                letterColor: AppColors.textOnColor,
                              )
                            : _Tile(_letters[row * 4 + col], size: size),
                      ],
                    ],
                  ),
                ],
              ],
            ),
            // The found word, circled.
            Container(
              width: 4 * size + 3 * gap + 7,
              height: size * 1.12 + 7,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.textOnColor, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Crossword extends StatelessWidget {
  const _Crossword();

  static const _size = 16.0;
  static const _colStep = _size + 2;
  static const _rowStep = _size * 1.12 + 2;
  static const _left = (72 - 3 * _colStep + 2) / 2;
  static const _top = (60 - 3 * _rowStep + 2) / 2;

  static Widget _at(int col, int row, _Tile tile) =>
      _Placed(_left + col * _colStep, _top + row * _rowStep, tile);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Down: "lit", its last box still to fill.
        _at(1, 0, const _Tile('l', size: _size)),
        _at(1, 1, const _Tile('i', size: _size)),
        _at(1, 2, const _Tile.empty(size: _size)),
        // Across: "vie", crossing on the "i", its last box still to fill.
        _at(0, 1, const _Tile('v', size: _size)),
        _at(2, 1, const _Tile.empty(size: _size)),
      ],
    );
  }
}
