import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/shared/widgets/pop_in.dart';

/// One page of the onboarding tour: an animated illustration, a title
/// and a short explanation.
class OnboardingSlide extends StatelessWidget {
  final Widget illustration;
  final String title;
  final String text;

  const OnboardingSlide({
    super.key,
    required this.illustration,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingXl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 220, child: Center(child: illustration)),
          const SizedBox(height: AppDimensions.spacingXl),
          PopIn.rise(
            delay: const Duration(milliseconds: 100),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: AppTypography.headingLarge,
                fontWeight: AppTypography.bold,
                color: AppColors.textOnColor,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          PopIn.rise(
            delay: const Duration(milliseconds: 200),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: AppTypography.bodyLarge,
                fontWeight: AppTypography.semiBold,
                color: AppColors.textOnColor,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
