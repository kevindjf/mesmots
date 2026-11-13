import 'package:flutter/material.dart';

/// Application color palette - Colorful theme for children
class AppColors {
  AppColors._();

  // Primary colors
  static const Color primary = Color(0xFF4ECDC4); // Turquoise principal
  static const Color primaryDark = Color(0xFF3DB4AC); // Turquoise foncé
  static const Color primaryLight = Color(0xFF7EDED8); // Turquoise clair
  static const Color secondary = Color(0xFFFF7B9C); // Rose - couleur secondaire
  static const Color accent = Color(0xFFFFA726); // Orange - couleur d'accent

  // Button colors (colorful palette)
  static const Color buttonOrange = Color(0xFFFFA726); // Orange vif
  static const Color buttonOrangeShadow = Color(0xFFE69500); // Ombre orange
  static const Color buttonCoral = Color(0xFFFF8A65); // Coral/Saumon
  static const Color buttonCoralShadow = Color(0xFFE5704D); // Ombre coral
  static const Color buttonPink = Color(0xFFFF7B9C); // Rose
  static const Color buttonPinkShadow = Color(0xFFE66384); // Ombre rose
  static const Color buttonMagenta = Color(0xFFE040FB); // Magenta
  static const Color buttonMagentaShadow = Color(0xFFC626E0); // Ombre magenta
  static const Color buttonBlue = Color(0xFF42A5F5); // Bleu
  static const Color buttonBlueShadow = Color(0xFF2889D9); // Ombre bleu
  static const Color buttonPurple = Color(0xFF7E57C2); // Violet
  static const Color buttonPurpleShadow = Color(0xFF6440A8); // Ombre violet

  // Background colors
  static const Color background = Color(0xFF4ECDC4); // Fond turquoise
  static const Color backgroundGradientStart = Color(0xFF56D4CB); // Gradient haut
  static const Color backgroundGradientEnd = Color(0xFF44B8B0); // Gradient bas
  static const Color surface = Color(0xFFFFFFFF); // Blanc
  static const Color cardBackground = Color(0xFFFFFFFF); // Carte blanche

  // Floating shapes colors
  static const Color shapeLight = Color(0x30FFFFFF); // Forme claire
  static const Color shapeDark = Color(0x15000000); // Forme foncée

  // Semantic colors
  static const Color success = Color(0xFF4CAF50); // Vert succès
  static const Color successShadow = Color(0xFF3D8B40); // Ombre vert succès
  static const Color successDark = Color(0xFF2E7D32); // Vert succès foncé (texte)
  static const Color successLight = Color(0xFF98D9A8); // Vert succès pastel
  static const Color error = Color(0xFFFF5252); // Rouge erreur
  static const Color errorShadow = Color(0xFFCC3B3B); // Ombre rouge erreur
  static const Color errorDark = Color(0xFFB71C1C); // Rouge erreur foncé (texte)
  static const Color errorLight = Color(0xFFFFAAAA); // Rouge erreur pastel
  static const Color warning = Color(0xFFFFE5A0); // Jaune warning pastel

  // Text colors
  static const Color textPrimary = Color(0xFF2D3142); // Gris foncé bleuté
  static const Color textSecondary = Color(0xFF9094A6); // Gris moyen
  static const Color textLight = Color(0xFFBEC2D0); // Gris clair
  static const Color textOnColor = Color(0xFFFFFFFF); // Texte sur couleur

  // Border colors
  static const Color borderLight = Color(0xFFE5E7EB); // Bordure claire
  static const Color dashedBorder = Color(0xFFD1D5DB); // Bordure pointillée

  // Icon colors
  static const Color iconBlue = Color(0xFF4ECDC4); // Icône turquoise
  static const Color iconBackground = Color(0xFFE0F7F5); // Fond icône turquoise clair

  // Shadow
  static const Color shadowColor = Color(0x25000000); // Ombre légère

  // Light theme (white background)
  static const Color anthracite = Color(0xFF3A3D4A); // Tuile anthracite
  static const Color anthraciteShadow = Color(0xFF1F2129); // Ombre anthracite
  static const Color lightSlot = Color(0xFFF3F4F7); // Case vide claire
  static const Color lightSlotBorder = Color(0xFFD1D5DB); // Bord case vide
  static const Color lightDisabled = Color(0xFFECEDF1); // Tuile désactivée

  // Dark theme (night blue background)
  static const Color nightGradientStart = Color(0xFF232739); // Gradient haut
  static const Color nightGradientEnd = Color(0xFF1B1E2B); // Gradient bas
  static const Color nightCard = Color(0xFF2A2E40); // Carte sombre
  static const Color nightLine = Color(0xFF3A3F55); // Bordure sombre
  static const Color nightText = Color(0xFFF2F3F7); // Texte clair
  static const Color nightTextMuted = Color(0xFFA9AEC2); // Texte clair atténué
  static const Color nightMuted = Color(0xFF555B75); // Bord / désactivé sombre
  static const Color nightStar = Color(0xFF6E7390); // Étoile vide sombre
  static const Color offWhiteShadow = Color(0xFFD9DBE3); // Ombre blanc cassé
}
