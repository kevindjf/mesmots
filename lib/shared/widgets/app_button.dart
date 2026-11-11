import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_typography.dart';

/// Primary application button
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? icon;
  final bool isLoading;
  final bool isFullWidth;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        minimumSize: isFullWidth
            ? const Size(double.infinity, AppDimensions.buttonMinHeight)
            : null,
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  icon!,
                  const SizedBox(width: AppDimensions.spacingM),
                ],
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: AppTypography.bodyLarge,
                    fontWeight: AppTypography.semiBold,
                  ),
                ),
              ],
            ),
    );

    return isFullWidth ? button : button;
  }
}

/// Secondary/outline button
class AppOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? borderColor;
  final Color? textColor;
  final Widget? icon;

  const AppOutlineButton({
    super.key,
    required this.text,
    this.onPressed,
    this.borderColor,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: textColor,
        side: BorderSide(
          color: borderColor ?? Theme.of(context).colorScheme.primary,
          width: 2,
        ),
        minimumSize: const Size(
          AppDimensions.buttonMinWidth,
          AppDimensions.buttonMinHeight,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: AppDimensions.spacingM),
          ],
          Text(
            text,
            style: const TextStyle(
              fontSize: AppTypography.bodyLarge,
              fontWeight: AppTypography.semiBold,
            ),
          ),
        ],
      ),
    );
  }
}
