import 'package:flutter/material.dart';
import 'package:jerevise/core/constants/app_colors.dart';
import 'package:jerevise/core/constants/app_dimensions.dart';
import 'package:jerevise/core/constants/app_typography.dart';

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
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: AppTypography.headingMedium,
                    fontWeight: AppTypography.bold,
                    color: AppColors.textOnColor,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: AppTypography.bodySmall,
                      fontWeight: AppTypography.bold,
                      color: AppColors.textOnColor.withValues(alpha: 0.85),
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
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surface,
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
          color: AppColors.primary,
        ),
      ),
    );
  }
}

/// Lock icon button for parental mode with 3D style
class LockIconButton extends StatefulWidget {
  final bool isUnlocked;
  final VoidCallback? onTap;

  const LockIconButton({
    super.key,
    this.isUnlocked = false,
    this.onTap,
  });

  @override
  State<LockIconButton> createState() => _LockIconButtonState();
}

class _LockIconButtonState extends State<LockIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 44,
        height: 44,
        transform: Matrix4.translationValues(0, _isPressed ? 2 : 0, 0),
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: [
            // Ombre 3D simple
            BoxShadow(
              color: AppColors.primaryDark,
              blurRadius: 0,
              offset: Offset(0, _isPressed ? 2 : 4),
            ),
          ],
        ),
        child: Icon(
          widget.isUnlocked ? Icons.lock_open_outlined : Icons.lock_outline,
          color: widget.isUnlocked ? AppColors.success : AppColors.primary,
          size: AppDimensions.iconM,
        ),
      ),
    );
  }
}
