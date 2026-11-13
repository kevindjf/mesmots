import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/core/extensions/palette_context.dart';
import 'package:mesmots/features/appearance/domain/entities/appearance_settings.dart';
import 'package:mesmots/features/appearance/presentation/extensions/theme_choice_presentation.dart';
import 'package:mesmots/features/appearance/presentation/widgets/theme_preview.dart';

/// One theme to pick: a preview of it and its name, outlined when selected.
class ThemeChoiceCard extends StatelessWidget {
  final ThemeChoice choice;
  final bool isSelected;
  final VoidCallback onTap;

  const ThemeChoiceCard({
    super.key,
    required this.choice,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    const radius = AppDimensions.radiusM;
    return Semantics(
      button: true,
      selected: isSelected,
      label: choice.label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(AppDimensions.spacingXs),
          decoration: BoxDecoration(
            color: palette.panel,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: isSelected ? AppColors.primary : palette.panelBorder,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: palette.panelShadow,
                blurRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(radius - 4),
                    child: SizedBox(
                      height: 64,
                      width: double.infinity,
                      child: ThemePreview(palette: choice.previewPalette),
                    ),
                  ),
                  if (isSelected)
                    const Positioned(
                      right: 2,
                      bottom: 2,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle_rounded,
                          size: AppDimensions.iconS,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingXs),
              Text(
                choice.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: AppTypography.bodySmall,
                  fontWeight: AppTypography.bold,
                  color: palette.panelText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
