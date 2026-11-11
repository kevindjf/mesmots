import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_typography.dart';

/// Mascot widget displaying the app's dinosaur character
class MascotWidget extends StatelessWidget {
  final String name;
  final double size;
  final bool showName;

  const MascotWidget({
    super.key,
    this.name = 'MOTI LE DINO',
    this.size = 100,
    this.showName = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Mascot icon placeholder (replace with actual asset later)
        Icon(
          Icons.pets,
          size: size * 0.8,
          color: AppColors.primary,
        ),
        if (showName) ...[
          const SizedBox(height: AppDimensions.spacingS),
          MascotNameBadge(name: name),
        ],
      ],
    );
  }
}

/// Badge displaying the mascot's name
class MascotNameBadge extends StatelessWidget {
  final String name;

  const MascotNameBadge({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.spacingS,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D4A90E2), // AppColors.primary with 30% opacity
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        name,
        style: const TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: AppTypography.bodySmall,
          fontWeight: AppTypography.bold,
          color: Colors.white,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
