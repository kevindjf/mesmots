import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';

/// Standard application card
class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final double? elevation;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.backgroundColor,
    this.padding,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(AppDimensions.shadowOpacity),
            blurRadius: AppDimensions.shadowBlur,
            offset: const Offset(0, AppDimensions.elevationM),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppDimensions.paddingL),
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        child: card,
      );
    }

    return card;
  }
}

/// Cream-colored card for game elements
class GameCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isCorrect;
  final bool isIncorrect;
  final EdgeInsetsGeometry? padding;

  const GameCard({
    super.key,
    required this.child,
    this.onTap,
    this.isSelected = false,
    this.isCorrect = false,
    this.isIncorrect = false,
    this.padding,
  });

  Color get _backgroundColor {
    if (isCorrect) return AppColors.success;
    if (isIncorrect) return AppColors.error;
    if (isSelected) return AppColors.primary.withOpacity(0.2);
    return AppColors.cardBackground;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : isCorrect
                  ? AppColors.success
                  : isIncorrect
                      ? AppColors.error
                      : Colors.transparent,
          width: isSelected || isCorrect || isIncorrect ? 3 : 0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(AppDimensions.shadowOpacity),
            blurRadius: AppDimensions.shadowBlur,
            offset: const Offset(0, AppDimensions.elevationS),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          child: Padding(
            padding: padding ??
                const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                  vertical: AppDimensions.paddingM,
                ),
            child: child,
          ),
        ),
      ),
    );
  }
}
