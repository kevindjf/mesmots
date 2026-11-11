import 'package:flutter/material.dart';
import 'package:jerevise/core/constants/app_colors.dart';
import 'package:jerevise/core/constants/app_dimensions.dart';
import 'package:jerevise/core/constants/app_typography.dart';

class NumberLine extends StatelessWidget {
  final List<int?> placedNumbers;
  final int? selectedNumber;
  final ValueChanged<int> onPositionTap;

  const NumberLine({
    super.key,
    required this.placedNumbers,
    required this.selectedNumber,
    required this.onPositionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(placedNumbers.length, (i) {
        final value = placedNumbers[i];
        final hasValue = value != null;
        final isHighlighted = selectedNumber != null && !hasValue;

        return Padding(
          padding: EdgeInsets.only(
            right: i < placedNumbers.length - 1 ? AppDimensions.spacingS : 0,
          ),
          child: GestureDetector(
            onTap: () => onPositionTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 56,
              height: 64,
              decoration: BoxDecoration(
                color: hasValue
                    ? AppColors.sectionMaths
                    : isHighlighted
                        ? AppColors.sectionMaths.withValues(alpha: 0.2)
                        : AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                border: hasValue
                    ? null
                    : Border.all(
                        color: isHighlighted
                            ? AppColors.sectionMaths
                            : AppColors.borderLight,
                        width: 2,
                        strokeAlign: BorderSide.strokeAlignInside,
                      ),
                boxShadow: [
                  BoxShadow(
                    color: hasValue
                        ? AppColors.sectionMathsShadow
                        : AppColors.primaryDark,
                    blurRadius: 0,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: hasValue
                    ? Text(
                        '$value',
                        style: const TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: AppTypography.headingSmall,
                          fontWeight: AppTypography.bold,
                          color: AppColors.textOnColor,
                        ),
                      )
                    : Text(
                        '${i + 1}',
                        style: const TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: AppTypography.bodySmall,
                          fontWeight: AppTypography.regular,
                          color: AppColors.textLight,
                        ),
                      ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
