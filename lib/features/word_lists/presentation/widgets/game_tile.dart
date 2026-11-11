import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/features/games/presentation/extensions/game_type_presentation.dart';
import 'package:mesmots/features/word_lists/domain/entities/game_type.dart';

/// Game tile (Mr. Square style). Every game is always playable.
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
      onTapCancel:
          _isEnabled ? () => setState(() => _isPressed = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        transform: Matrix4.translationValues(0, _isPressed ? 3 : 0, 0),
        decoration: BoxDecoration(
          color: _isEnabled ? type.color : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
          boxShadow: [
            BoxShadow(
              color: _isEnabled ? type.shadowColor : AppColors.primaryDark,
              blurRadius: 0,
              offset: Offset(0, _isPressed ? 3 : 6),
            ),
          ],
        ),
        child: Opacity(
          opacity: _isEnabled ? 1 : 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.textOnColor.withValues(alpha: 0.25),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusM),
                    ),
                    child: Icon(
                      type.icon,
                      color: _isEnabled
                          ? AppColors.textOnColor
                          : AppColors.textLight,
                    ),
                  ),
                  const Spacer(),
                  if (widget.playCount > 0) _PlayCountBadge(widget.playCount),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingM),
              Text(
                type.label,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: AppTypography.bodyLarge,
                  fontWeight: AppTypography.bold,
                  color:
                      _isEnabled ? AppColors.textOnColor : AppColors.textLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
                      ? AppColors.textOnColor.withValues(alpha: 0.85)
                      : AppColors.textLight,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayCountBadge extends StatelessWidget {
  final int count;

  const _PlayCountBadge(this.count);

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
        style: const TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: AppTypography.bodySmall,
          fontWeight: AppTypography.bold,
          color: AppColors.textOnColor,
        ),
      ),
    );
  }
}
