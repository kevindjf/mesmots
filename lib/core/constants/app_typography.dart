import 'package:flutter/material.dart';

/// Application typography - Adapted for children (larger sizes)
class AppTypography {
  AppTypography._();

  // Font family
  static const String fontFamily = 'Fredoka';
  static const List<String> fontFamilyFallback = ['sans-serif'];

  // Font sizes
  static const double headingLarge = 32.0;
  static const double headingMedium = 24.0;
  static const double headingSmall = 20.0;
  static const double bodyLarge = 18.0;
  static const double bodyMedium = 16.0;
  static const double bodySmall = 12.0;

  // Font weights
  static const FontWeight bold = FontWeight.w800;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight regular = FontWeight.w400;

  // Text styles
  static const TextStyle headingLargeStyle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: headingLarge,
    fontWeight: bold,
  );

  static const TextStyle headingMediumStyle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: headingMedium,
    fontWeight: semiBold,
  );

  static const TextStyle headingSmallStyle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: headingSmall,
    fontWeight: semiBold,
  );

  static const TextStyle bodyLargeStyle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: bodyLarge,
    fontWeight: regular,
  );

  static const TextStyle bodyMediumStyle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: bodyMedium,
    fontWeight: regular,
  );

  static const TextStyle bodySmallStyle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: bodySmall,
    fontWeight: regular,
  );
}
