import 'package:flutter/material.dart';
import 'package:mesmots/core/extensions/palette_context.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/shared/widgets/colorful_button.dart';

class SuccessOverlay extends StatelessWidget {
  final VoidCallback onReplay;
  final VoidCallback onBackToList;

  const SuccessOverlay({
    super.key,
    required this.onReplay,
    required this.onBackToList,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            Text(
              AppStrings.congratulations,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: AppTypography.headingLarge,
                fontWeight: AppTypography.bold,
                color: context.palette.onBackground,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),

            // Message
            Text(
              AppStrings.allWordsValidated,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: AppTypography.bodyLarge,
                fontWeight: AppTypography.regular,
                color: context.palette.onBackground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingXxl),

            // Stars with 3D containers
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final colors = [
                  AppColors.buttonOrange,
                  AppColors.buttonPink,
                  AppColors.buttonBlue,
                ];
                final shadows = [
                  AppColors.buttonOrangeShadow,
                  AppColors.buttonPinkShadow,
                  AppColors.buttonBlueShadow,
                ];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingS),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: colors[index],
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: shadows[index],
                          blurRadius: 0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.star,
                      color: AppColors.textOnColor,
                      size: 32,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppDimensions.spacingXxl),

            // Buttons
            ColorfulButton(
              text: AppStrings.playAgain,
              icon: Icons.replay,
              color: AppColors.success,
              shadowColor: AppColors.successShadow,
              width: double.infinity,
              onTap: onReplay,
            ),
            const SizedBox(height: AppDimensions.spacingL),
            ColorfulButton(
              text: AppStrings.otherGame,
              icon: Icons.grid_view_rounded,
              color: context.palette.tile,
              shadowColor: context.palette.tileShadow,
              textColor: context.palette.tileAccent,
              width: double.infinity,
              onTap: onBackToList,
            ),
          ],
        ),
      ),
    );
  }
}
