import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/theme/app_palette.dart';

/// Application theme configuration
class AppTheme {
  AppTheme._();

  /// The default theme, light.
  static ThemeData get lightTheme => of(AppPalette.light);

  /// Theme built on [palette], which widgets read via `context.palette`.
  static ThemeData of(AppPalette palette) {
    final isDark = palette.brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: palette.brightness,
      fontFamily: AppTypography.fontFamily,
      scaffoldBackgroundColor: palette.background,
      extensions: [palette],

      // Color scheme
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: AppColors.buttonBlue,
              secondary: AppColors.secondary,
              tertiary: AppColors.accent,
              surface: palette.panel,
              error: AppColors.error,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: palette.panelText,
              onError: Colors.white,
            )
          : ColorScheme.light(
              primary: AppColors.buttonBlue,
              secondary: AppColors.secondary,
              tertiary: AppColors.accent,
              surface: palette.panel,
              error: AppColors.error,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: palette.panelText,
              onError: Colors.white,
            ),

      // Text theme
      textTheme: const TextTheme(
        headlineLarge: AppTypography.headingLargeStyle,
        headlineMedium: AppTypography.headingMediumStyle,
        headlineSmall: AppTypography.headingSmallStyle,
        bodyLarge: AppTypography.bodyLargeStyle,
        bodyMedium: AppTypography.bodyMediumStyle,
        bodySmall: AppTypography.bodySmallStyle,
      ).apply(
        bodyColor: palette.panelText,
        displayColor: palette.panelText,
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: palette.panel,
        elevation: AppDimensions.elevationM,
        shadowColor: Colors.black.withOpacity(AppDimensions.shadowOpacity),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        ),
        margin: const EdgeInsets.symmetric(
          vertical: AppDimensions.spacingM,
          horizontal: AppDimensions.spacingL,
        ),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonMinHeight,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingXl,
            vertical: AppDimensions.buttonPaddingVertical,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          ),
          textStyle: AppTypography.bodyLargeStyle.copyWith(
            fontWeight: AppTypography.semiBold,
          ),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: AppTypography.bodyMediumStyle.copyWith(
            fontWeight: AppTypography.semiBold,
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.panel,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          borderSide: const BorderSide(color: AppColors.buttonBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.all(AppDimensions.paddingL),
      ),

      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: palette.panelText),
        titleTextStyle: AppTypography.headingMediumStyle,
      ),

      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.success,
        linearTrackColor: AppColors.textLight,
      ),

      // Icon theme
      iconTheme: IconThemeData(
        color: palette.panelText,
        size: AppDimensions.iconM,
      ),
    );
  }
}
