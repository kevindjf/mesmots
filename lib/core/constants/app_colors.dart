import 'package:flutter/material.dart';

/// Application color palette - Pastel theme for children
class AppColors {
  AppColors._();

  // Primary colors
  static const Color primary = Color(0xFF7EC8E3); // Bleu pastel
  static const Color secondary = Color(0xFFB4E197); // Vert pastel
  static const Color accent = Color(0xFFFFB347); // Orange pastel

  // Background colors
  static const Color background = Color(0xFFF5F5F5); // Gris très clair
  static const Color surface = Color(0xFFFFFFFF); // Blanc
  static const Color cardBackground = Color(0xFFFFFBF0); // Crème

  // Semantic colors
  static const Color success = Color(0xFF98D9A8); // Vert succès pastel
  static const Color error = Color(0xFFFFAAAA); // Rouge erreur pastel
  static const Color warning = Color(0xFFFFE5A0); // Jaune warning pastel

  // Text colors
  static const Color textPrimary = Color(0xFF4A4A4A); // Gris foncé
  static const Color textSecondary = Color(0xFF7A7A7A); // Gris moyen
  static const Color textLight = Color(0xFFAAAAAA); // Gris clair

  // Level colors
  static const Color level1 = Color(0xFF7EC8E3); // Bleu - QCM
  static const Color level2 = Color(0xFFB4E197); // Vert - Mélangé
  static const Color level3 = Color(0xFFFFB347); // Orange - Trous
  static const Color level4 = Color(0xFFDDA0DD); // Violet - Écriture
}
