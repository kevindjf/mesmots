import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/shared/widgets/icon_badge.dart';
import 'package:mesmots/shared/widgets/pop_in.dart';

/// A paper word list whose words appear one by one, with a camera badge.
class TourListIllustration extends StatelessWidget {
  const TourListIllustration({super.key});

  static const _bulletColors = [
    AppColors.buttonOrange,
    AppColors.buttonPink,
    AppColors.buttonBlue,
  ];

  @override
  Widget build(BuildContext context) {
    const words = AppStrings.tourExampleWords;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Transform.rotate(
          angle: -0.04,
          child: Container(
            width: 190,
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.primaryDark,
                  blurRadius: 0,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < words.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: PopIn.rise(
                      delay: Duration(milliseconds: 250 + 250 * i),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _bulletColors[i % _bulletColors.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spacingM),
                          Text(
                            words[i],
                            style: const TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: AppTypography.headingSmall,
                              fontWeight: AppTypography.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const Positioned(
          right: -18,
          bottom: -14,
          child: PopIn(
            delay: Duration(milliseconds: 1000),
            child: IconBadge.orange(icon: Icons.photo_camera_rounded),
          ),
        ),
      ],
    );
  }
}
