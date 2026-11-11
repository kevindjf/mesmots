import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:jerevise/core/constants/app_colors.dart';
import 'package:jerevise/core/constants/app_dimensions.dart';
import 'package:jerevise/core/constants/app_typography.dart';

class BalanceWidget extends StatelessWidget {
  final int targetValue;
  final int currentSum;

  const BalanceWidget({
    super.key,
    required this.targetValue,
    required this.currentSum,
  });

  @override
  Widget build(BuildContext context) {
    // Rotation angle based on ratio: balanced = 0, tilts based on difference
    final diff = currentSum - targetValue;
    const maxAngle = 0.15; // ~8.5 degrees max tilt
    final ratio = targetValue == 0
        ? 0.0
        : (diff / targetValue).clamp(-1.0, 1.0);
    final angle = ratio * maxAngle;

    return SizedBox(
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Base / Pivot
          Positioned(
            bottom: 0,
            child: Container(
              width: 40,
              height: 60,
              decoration: const BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),

          // Beam
          Positioned(
            bottom: 55,
            child: AnimatedRotation(
              turns: angle / (2 * math.pi),
              duration: const Duration(milliseconds: 300),
              child: Container(
                width: 280,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.buttonOrange,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.buttonOrangeShadow,
                      blurRadius: 0,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Left plate — target
                    Positioned(
                      left: 10,
                      top: -50,
                      child: _Plate(
                        label: '$targetValue',
                        color: AppColors.sectionMaths,
                      ),
                    ),
                    // Right plate — current sum
                    Positioned(
                      right: 10,
                      top: -50,
                      child: _Plate(
                        label: '$currentSum',
                        color: currentSum == targetValue
                            ? AppColors.success
                            : AppColors.buttonBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Plate extends StatelessWidget {
  final String label;
  final Color color;

  const _Plate({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 44,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 0,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: AppTypography.headingSmall,
                fontWeight: AppTypography.bold,
                color: AppColors.textOnColor,
              ),
            ),
          ),
        ),
        // String
        Container(
          width: 2,
          height: 6,
          color: AppColors.textSecondary,
        ),
      ],
    );
  }
}
