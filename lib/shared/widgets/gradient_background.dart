import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_colors.dart';

/// Widget providing a colorful gradient background with floating shapes
class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final bool showShapes;

  const GradientBackground({
    super.key,
    required this.child,
    this.colors,
    this.showShapes = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors ??
              [
                AppColors.backgroundGradientStart,
                AppColors.backgroundGradientEnd,
              ],
        ),
      ),
      child: showShapes
          ? Stack(
              children: [
                // Floating shapes
                const Positioned.fill(child: FloatingShapes()),
                // Content
                child,
              ],
            )
          : child,
    );
  }
}

/// Floating geometric shapes for background decoration
class FloatingShapes extends StatelessWidget {
  const FloatingShapes({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final random = Random(42); // Fixed seed for consistent layout

    return IgnorePointer(
      child: Stack(
        children: List.generate(12, (index) {
          final shapeSize = 30.0 + random.nextDouble() * 60;
          final left = random.nextDouble() * size.width;
          final top = random.nextDouble() * size.height;
          final isLight = random.nextBool();
          final borderRadius = random.nextDouble() * 8 + 4;

          return Positioned(
            left: left,
            top: top,
            child: Transform.rotate(
              angle: random.nextDouble() * pi / 4,
              child: Container(
                width: shapeSize,
                height: shapeSize,
                decoration: BoxDecoration(
                  color: isLight ? AppColors.shapeLight : AppColors.shapeDark,
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
