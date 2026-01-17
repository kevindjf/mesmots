import 'package:flutter/material.dart';

/// Application typography - Adapted for children (larger sizes)
class AppTypography {
  AppTypography._();

  // Font family
  static const String fontFamily = 'Nunito';

  // Font sizes
  static const double headingLarge = 32.0;
  static const double headingMedium = 24.0;
  static const double headingSmall = 20.0;
  static const double bodyLarge = 18.0;
  static const double bodyMedium = 16.0;
  static const double bodySmall = 14.0;

  // Font weights
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight regular = FontWeight.w400;

  // Text styles
  static const TextStyle headingLargeStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: headingLarge,
    fontWeight: bold,
  );

  static const TextStyle headingMediumStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: headingMedium,
    fontWeight: semiBold,
  );

  static const TextStyle headingSmallStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: headingSmall,
    fontWeight: semiBold,
  );

  static const TextStyle bodyLargeStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: bodyLarge,
    fontWeight: regular,
  );

  static const TextStyle bodyMediumStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: bodyMedium,
    fontWeight: regular,
  );

  static const TextStyle bodySmallStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: bodySmall,
    fontWeight: regular,
  );
}
