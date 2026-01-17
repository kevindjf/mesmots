import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/shared/widgets/app_button.dart';

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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.success.withOpacity(0.1),
            AppColors.surface,
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingXxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Celebration emoji
              const Text(
                '🎉',
                style: TextStyle(fontSize: 80),
              ),
              const SizedBox(height: AppDimensions.spacingXxl),

              // Title
              const Text(
                AppStrings.congratulations,
                style: TextStyle(
                  fontSize: AppTypography.headingLarge,
                  fontWeight: AppTypography.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingL),

              // Message
              const Text(
                AppStrings.allWordsValidated,
                style: TextStyle(
                  fontSize: AppTypography.bodyLarge,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spacingXxl),

              // Stars
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star,
                    color: AppColors.accent,
                    size: 48,
                  ),
                  SizedBox(width: AppDimensions.spacingM),
                  Icon(
                    Icons.star,
                    color: AppColors.accent,
                    size: 48,
                  ),
                  SizedBox(width: AppDimensions.spacingM),
                  Icon(
                    Icons.star,
                    color: AppColors.accent,
                    size: 48,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingXxl),

              // Buttons
              if (onNextLevel != null) ...[
                AppButton(
                  text: AppStrings.nextLevel,
                  onPressed: onNextLevel,
                  icon: const Icon(Icons.arrow_forward),
                  isFullWidth: true,
                  backgroundColor: AppColors.success,
                ),
                const SizedBox(height: AppDimensions.spacingL),
              ],
              AppButton(
                text: AppStrings.backToList,
                onPressed: onBackToList,
                isFullWidth: true,
                backgroundColor: AppColors.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
