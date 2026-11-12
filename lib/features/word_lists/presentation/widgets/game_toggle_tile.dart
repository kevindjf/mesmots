import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/features/games/presentation/extensions/game_type_presentation.dart';
import 'package:mesmots/features/word_lists/domain/entities/game_type.dart';

/// Toggleable game row used by the adult to allow a game for a list.
class GameToggleTile extends StatelessWidget {
  final GameType type;
  final bool isEnabled;
  final ValueChanged<bool> onChanged;

  const GameToggleTile({
    super.key,
    required this.type,
    required this.isEnabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: GestureDetector(
        onTap: () => onChanged(!isEnabled),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
            vertical: AppDimensions.paddingS,
          ),
          decoration: BoxDecoration(
            color: isEnabled ? type.color : AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            boxShadow: [
              BoxShadow(
                color: isEnabled ? type.shadowColor : AppColors.primaryDark,
                blurRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                type.icon,
                color: isEnabled ? AppColors.textOnColor : AppColors.textLight,
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: Text(
                  type.label,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: AppTypography.bodyLarge,
                    fontWeight: AppTypography.bold,
                    color:
                        isEnabled ? AppColors.textOnColor : AppColors.textLight,
                  ),
                ),
              ),
              Switch(
                value: isEnabled,
                onChanged: onChanged,
                activeThumbColor: AppColors.surface,
                activeTrackColor: type.shadowColor,
                inactiveThumbColor: AppColors.surface,
                inactiveTrackColor: AppColors.textLight,
                trackOutlineColor:
                    const WidgetStatePropertyAll(Colors.transparent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
