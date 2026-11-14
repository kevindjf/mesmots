import 'package:flutter/material.dart';
import 'package:mesmots/core/extensions/palette_context.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/features/games/presentation/extensions/game_type_presentation.dart';
import 'package:mesmots/features/games/presentation/widgets/game_picto.dart';
import 'package:mesmots/features/word_lists/domain/entities/game_type.dart';

/// Game card of the list screen (Mr. Square style), one per row: the game's
/// picto, its name and what to do. Every game is always playable.
class GameTile extends StatefulWidget {
  final GameType type;
  final int playCount;
  final VoidCallback? onTap;

  /// Optional message shown instead of the description when [onTap] is null
  final String? unavailableReason;

  const GameTile({
    super.key,
    required this.type,
    required this.playCount,
    required this.onTap,
    this.unavailableReason,
  });

  @override
  State<GameTile> createState() => _GameTileState();
}

class _GameTileState extends State<GameTile> {
  bool _isPressed = false;

  bool get _isEnabled => widget.onTap != null;

  @override
  Widget build(BuildContext context) {
    final type = widget.type;

    return GestureDetector(
      onTapDown: _isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: _isEnabled
          ? (_) {
              setState(() => _isPressed = false);
              widget.onTap!();
            }
          : null,
      onTapCancel: _isEnabled ? () => setState(() => _isPressed = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.all(AppDimensions.paddingS),
        transform: Matrix4.translationValues(0, _isPressed ? 3 : 0, 0),
        decoration: BoxDecoration(
          color: _isEnabled ? type.color : context.palette.panel,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          border: context.palette.outlineOf(_isEnabled ? type.color : null),
          boxShadow: [
            BoxShadow(
              color:
                  _isEnabled ? type.shadowColor : context.palette.panelShadow,
              blurRadius: 0,
              offset: Offset(0, _isPressed ? 2 : 5),
            ),
          ],
        ),
        child: Opacity(
          opacity: _isEnabled ? 1 : 0.6,
          child: Row(
            children: [
              Container(
                width: 80,
                height: 68,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _isEnabled
                      ? AppColors.textOnColor.withValues(alpha: 0.25)
                      : context.palette.panelHint,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                ),
                child: GamePicto(type: type, width: 66),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Shrinks rather than cuts the name in a narrow column.
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        type.label,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: AppTypography.bodyLarge,
                          fontWeight: AppTypography.bold,
                          color: _isEnabled
                              ? context.palette.onBlock(type.color)
                              : context.palette.panelTextMuted,
                          height: 1.1,
                        ),
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isEnabled
                          ? type.description
                          : widget.unavailableReason ?? type.description,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: AppTypography.bodySmall,
                        fontWeight: AppTypography.semiBold,
                        color: _isEnabled
                            ? context.palette
                                .onBlock(type.color)
                                .withValues(alpha: 0.9)
                            : context.palette.panelTextMuted,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.playCount > 0) ...[
                      const SizedBox(height: AppDimensions.spacingXs),
                      _PlayCountBadge(widget.playCount, blockColor: type.color),
                    ],
                  ],
                ),
              ),
              if (_isEnabled) ...[
                const SizedBox(width: AppDimensions.spacingS),
                Icon(
                  Icons.chevron_right_rounded,
                  color: context.palette.onBlock(type.color),
                  size: AppDimensions.iconL,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayCountBadge extends StatelessWidget {
  final int count;
  final Color blockColor;

  const _PlayCountBadge(this.count, {required this.blockColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingS,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.textOnColor.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Text(
        '${AppStrings.playedTimes} $count×',
        style: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: AppTypography.bodySmall,
          fontWeight: AppTypography.bold,
          color: context.palette.onBlock(blockColor),
        ),
      ),
    );
  }
}
