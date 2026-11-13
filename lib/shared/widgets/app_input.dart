import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/core/extensions/palette_context.dart';

/// Reusable text input with 3D shadow effect
class AppInput extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  const AppInput({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.textCapitalization = TextCapitalization.none,
    this.onSubmitted,
    this.onChanged,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final idleBorder = palette.panelBorder.a == 0
        ? BorderSide.none
        : BorderSide(color: palette.panelBorder, width: 2);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: palette.panelShadow,
            blurRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        style: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: AppTypography.bodyLarge,
          fontWeight: AppTypography.semiBold,
          color: palette.panelText,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: AppTypography.bodyLarge,
            fontWeight: AppTypography.regular,
            color: palette.panelHint,
          ),
          filled: true,
          fillColor: palette.panel,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: AppDimensions.paddingM,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            borderSide: idleBorder,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            borderSide: idleBorder,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            borderSide: const BorderSide(
              color: AppColors.buttonBlue,
              width: 2,
            ),
          ),
        ),
        textCapitalization: textCapitalization,
        onSubmitted: onSubmitted,
        onChanged: onChanged,
      ),
    );
  }
}
