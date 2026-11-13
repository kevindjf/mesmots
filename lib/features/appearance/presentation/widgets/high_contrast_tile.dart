import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/core/extensions/palette_context.dart';

/// Panel row to turn the high contrast text on colored blocks on or off.
class HighContrastTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const HighContrastTile({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingS,
        ),
        decoration: BoxDecoration(
          color: palette.panel,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          border: palette.panelOutline,
          boxShadow: [
            BoxShadow(
              color: palette.panelShadow,
              blurRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.contrast_rounded, color: palette.panelText),
            const SizedBox(width: AppDimensions.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.highContrast,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: AppTypography.bodyLarge,
                      fontWeight: AppTypography.bold,
                      color: palette.panelText,
                    ),
                  ),
                  Text(
                    AppStrings.highContrastHint,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: AppTypography.bodySmall,
                      fontWeight: AppTypography.semiBold,
                      color: palette.panelTextMuted,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppColors.surface,
              activeTrackColor: AppColors.success,
              inactiveThumbColor: AppColors.surface,
              inactiveTrackColor: palette.panelHint,
              trackOutlineColor:
                  const WidgetStatePropertyAll(Colors.transparent),
            ),
          ],
        ),
      ),
    );
  }
}
