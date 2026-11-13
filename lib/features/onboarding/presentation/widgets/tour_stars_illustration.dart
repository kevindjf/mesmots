import 'package:flutter/material.dart';
import 'package:mesmots/core/extensions/palette_context.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/shared/widgets/pop_in.dart';

/// A word card earning its 3 stars one by one.
class TourStarsIllustration extends StatelessWidget {
  const TourStarsIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++)
              PopIn(
                delay: Duration(milliseconds: 300 + 350 * i),
                fromScale: 0,
                child: Transform.translate(
                  // The middle star sits higher, like a podium.
                  offset: Offset(0, i == 1 ? -14 : 0),
                  child: const Icon(
                    Icons.star_rounded,
                    size: 64,
                    color: AppColors.accent,
                    shadows: [
                      Shadow(
                          color: AppColors.buttonOrangeShadow,
                          offset: Offset(0, 3)),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingM),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingXl,
            vertical: AppDimensions.paddingM,
          ),
          decoration: BoxDecoration(
            color: context.palette.panel,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            border: context.palette.panelOutline,
            boxShadow: [
              BoxShadow(
                color: context.palette.panelShadow,
                blurRadius: 0,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Text(
            AppStrings.tourExampleWords.first,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: AppTypography.headingMedium,
              fontWeight: AppTypography.bold,
              color: context.palette.panelText,
            ),
          ),
        ),
      ],
    );
  }
}
