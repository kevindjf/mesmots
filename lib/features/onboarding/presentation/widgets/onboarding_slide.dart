import 'package:flutter/material.dart';
import 'package:mesmots/core/extensions/palette_context.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/core/extensions/responsive_context.dart';
import 'package:mesmots/shared/widgets/centered_scroll_view.dart';
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

  /// Box the illustration is drawn in.
  static const _illustrationHeight = 220.0;
  static const _illustrationWidth = 240.0;

  @override
  Widget build(BuildContext context) {
    final texts = [
      PopIn.rise(
        delay: const Duration(milliseconds: 100),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: AppTypography.headingLarge,
            fontWeight: AppTypography.bold,
            color: context.palette.onBackground,
          ),
        ),
      ),
      const SizedBox(height: AppDimensions.spacingM),
      PopIn.rise(
        delay: const Duration(milliseconds: 200),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: AppTypography.bodyLarge,
            fontWeight: AppTypography.semiBold,
            color: context.palette.onBackground,
            height: 1.35,
          ),
        ),
      ),
    ];

    // Held sideways: the illustration, shrunk to the height left, next to
    // the texts.
    if (context.isLandscape) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingXl,
        ),
        child: Row(
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: _illustrationWidth,
                  height: _illustrationHeight,
                  child: Center(child: illustration),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingXl),
            Expanded(
              child: CenteredScrollView(
                alwaysCenter: true,
                child: Column(children: texts),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingXl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: _illustrationHeight,
            child: Center(child: illustration),
          ),
          const SizedBox(height: AppDimensions.spacingXl),
          ...texts,
        ],
      ),
    );
  }
}
