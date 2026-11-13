import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/core/extensions/palette_context.dart';

/// Custom app header with logo, title, subtitle, and action button
class AppHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTrailingTap;

  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.leading,
    this.trailing,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    final onBackground = context.palette.onBackground;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.paddingM,
      ),
      child: Row(
        children: [
          // Leading (logo or custom widget)
          if (leading != null)
            leading!
          else if (icon != null)
            AppLogo(icon: icon!),
          const SizedBox(width: AppDimensions.spacingM),

          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: AppTypography.headingMedium,
                    fontWeight: AppTypography.bold,
                    color: onBackground,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: AppTypography.bodySmall,
                      fontWeight: AppTypography.bold,
                      color: onBackground.withValues(alpha: 0.85),
                      letterSpacing: 1.0,
                    ),
                  ),
              ],
            ),
          ),

          // Trailing action
          if (trailing != null)
            GestureDetector(
              onTap: onTrailingTap,
              child: trailing!,
            ),
        ],
      ),
    );
  }
}

/// App logo widget with icon
class AppLogo extends StatelessWidget {
  final IconData icon;
  final double size;

  const AppLogo({
    super.key,
    required this.icon,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: palette.tile,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          icon,
          size: size * 0.55,
          color: palette.tileIcon,
        ),
      ),
    );
  }
}
