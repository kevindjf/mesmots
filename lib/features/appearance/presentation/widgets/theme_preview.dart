import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/theme/app_palette.dart';

/// Tiny screen drawn with [palette]: background, a colored card and a tile.
class ThemePreview extends StatelessWidget {
  final AppPalette palette;

  const ThemePreview({super.key, required this.palette});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: palette.backgroundGradient,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingS),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 4,
              width: 24,
              decoration: BoxDecoration(
                color: palette.onBackground,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            Container(
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.buttonOrange,
                borderRadius: BorderRadius.circular(4),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.buttonOrangeShadow,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Container(
              height: 12,
              width: 12,
              decoration: BoxDecoration(
                color: palette.tile,
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                      color: palette.tileShadow, offset: const Offset(0, 2)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
