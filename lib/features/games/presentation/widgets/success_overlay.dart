import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/shared/widgets/colorful_button.dart';

class SuccessOverlay extends StatelessWidget {
  final VoidCallback? onNextLevel;
  final VoidCallback onBackToList;

  const SuccessOverlay({
    super.key,
    this.onNextLevel,
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
            const Text(
              AppStrings.congratulations,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: AppTypography.headingLarge,
                fontWeight: AppTypography.bold,
                color: AppColors.textOnColor,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),

            // Message
            const Text(
              AppStrings.allWordsValidated,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: AppTypography.bodyLarge,
                fontWeight: AppTypography.regular,
                color: AppColors.textOnColor,
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
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingS),
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
            if (onNextLevel != null) ...[
              ColorfulButton(
                text: AppStrings.nextLevel,
                icon: Icons.arrow_forward,
                color: AppColors.success,
                shadowColor: const Color(0xFF3D8B40),
                width: double.infinity,
                onTap: onNextLevel,
              ),
              const SizedBox(height: AppDimensions.spacingL),
            ],
            ColorfulButton(
              text: AppStrings.backToList,
              icon: Icons.arrow_back,
              color: AppColors.surface,
              shadowColor: AppColors.primaryDark,
              textColor: AppColors.primary,
              width: double.infinity,
              onTap: onBackToList,
            ),
          ],
        ),
      ),
    );
  }
}
