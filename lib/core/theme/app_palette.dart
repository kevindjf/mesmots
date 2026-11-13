import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_colors.dart';

/// The colors that change with the theme the parent picks.
///
/// Colored blocks (game cards, colored buttons, ABC button…) never change:
/// they keep using [AppColors] directly. Only what sits on the background
/// changes:
/// - [onBackground]: text and icons drawn right on the background.
/// - tiles: white elements on the background (letters, round and control
///   buttons, keys). White on turquoise and dark, anthracite on white.
/// - panels: content cards and dialogs (progress header, boards, inputs).
/// - slots: boxes still to fill in letter games.
///
/// [AppPalette.turquoise] holds the original colors, so the app looks exactly
/// as before when it is selected.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Brightness brightness;

  /// Plain background, behind screens without [backgroundGradient].
  final Color background;
  final List<Color> backgroundGradient;

  /// Floating shapes: [shapeLight]/[shapeDark] picked at random, unless
  /// [shapeTints] is set, then cycled through.
  final Color shapeLight;
  final Color shapeDark;
  final List<Color>? shapeTints;

  final Color onBackground;

  final Color tile;
  final Color tileShadow;

  /// Icons and free letters on a tile.
  final Color tileAccent;

  /// Placed letters and key labels on a tile.
  final Color tileText;
  final Color tileDisabled;
  final Color tileDisabledContent;

  final Color panel;
  final Color panelShadow;

  /// Panel outline, transparent when the panel stands out on its own.
  final Color panelBorder;
  final Color panelText;
  final Color panelTextMuted;
  final Color panelHint;

  /// Selected or highlighted area inside a panel.
  final Color panelHighlight;

  final Color slot;
  final Color slotBorder;

  final Color starInactive;

  /// Text on colored blocks switches to dark when white reads badly.
  final bool highContrast;

  const AppPalette({
    required this.brightness,
    required this.background,
    required this.backgroundGradient,
    required this.shapeLight,
    required this.shapeDark,
    this.shapeTints,
    required this.onBackground,
    required this.tile,
    required this.tileShadow,
    required this.tileAccent,
    required this.tileText,
    required this.tileDisabled,
    required this.tileDisabledContent,
    required this.panel,
    required this.panelShadow,
    required this.panelBorder,
    required this.panelText,
    required this.panelTextMuted,
    required this.panelHint,
    required this.panelHighlight,
    required this.slot,
    required this.slotBorder,
    required this.starInactive,
    this.highContrast = false,
  });

  /// The original look: turquoise background, white text.
  static final turquoise = AppPalette(
    brightness: Brightness.light,
    background: AppColors.background,
    backgroundGradient: const [
      AppColors.backgroundGradientStart,
      AppColors.backgroundGradientEnd,
    ],
    shapeLight: AppColors.shapeLight,
    shapeDark: AppColors.shapeDark,
    onBackground: AppColors.textOnColor,
    tile: AppColors.surface,
    tileShadow: AppColors.primaryDark,
    tileAccent: AppColors.primary,
    tileText: AppColors.textPrimary,
    tileDisabled: AppColors.textLight.withValues(alpha: 0.3),
    tileDisabledContent: AppColors.textLight,
    panel: AppColors.surface,
    panelShadow: AppColors.primaryDark,
    panelBorder: Colors.transparent,
    panelText: AppColors.textPrimary,
    panelTextMuted: AppColors.textSecondary,
    panelHint: AppColors.textLight,
    panelHighlight: AppColors.iconBackground,
    slot: AppColors.surface.withValues(alpha: 0.35),
    slotBorder: AppColors.surface,
    starInactive: AppColors.textLight,
  );

  /// White background, dark text, anthracite tiles.
  static final light = AppPalette(
    brightness: Brightness.light,
    background: AppColors.surface,
    backgroundGradient: const [AppColors.surface, AppColors.surface],
    shapeLight: AppColors.shapeLight,
    shapeDark: AppColors.shapeDark,
    shapeTints: _tints(0.13),
    onBackground: AppColors.textPrimary,
    tile: AppColors.anthracite,
    tileShadow: AppColors.anthraciteShadow,
    tileAccent: AppColors.primary,
    tileText: AppColors.textOnColor,
    tileDisabled: AppColors.lightDisabled,
    tileDisabledContent: AppColors.textLight,
    panel: AppColors.surface,
    panelShadow: AppColors.borderLight,
    panelBorder: AppColors.borderLight,
    panelText: AppColors.textPrimary,
    panelTextMuted: AppColors.textSecondary,
    panelHint: AppColors.textLight,
    panelHighlight: AppColors.iconBackground,
    slot: AppColors.lightSlot,
    slotBorder: AppColors.lightSlotBorder,
    starInactive: AppColors.textLight,
  );

  /// Night blue background, light text, white tiles.
  static final dark = AppPalette(
    brightness: Brightness.dark,
    background: AppColors.nightGradientEnd,
    backgroundGradient: const [
      AppColors.nightGradientStart,
      AppColors.nightGradientEnd,
    ],
    shapeLight: AppColors.shapeLight,
    shapeDark: AppColors.shapeDark,
    shapeTints: _tints(0.1),
    onBackground: AppColors.nightText,
    tile: AppColors.surface,
    tileShadow: AppColors.offWhiteShadow,
    tileAccent: AppColors.primary,
    tileText: AppColors.textPrimary,
    tileDisabled: AppColors.surface.withValues(alpha: 0.08),
    tileDisabledContent: AppColors.nightMuted,
    panel: AppColors.nightCard,
    panelShadow: AppColors.nightLine,
    panelBorder: AppColors.nightLine,
    panelText: AppColors.nightText,
    panelTextMuted: AppColors.nightTextMuted,
    panelHint: AppColors.nightMuted,
    panelHighlight: AppColors.nightLine,
    slot: AppColors.surface.withValues(alpha: 0.06),
    slotBorder: AppColors.nightMuted,
    starInactive: AppColors.nightStar,
  );

  static List<Color> _tints(double alpha) => [
        for (final color in const [
          AppColors.buttonOrange,
          AppColors.buttonPink,
          AppColors.buttonBlue,
          AppColors.primary,
          AppColors.buttonMagenta,
        ])
          color.withValues(alpha: alpha),
      ];

  /// Minimum contrast ratio for normal text (WCAG AA).
  static const minContrast = 4.5;

  /// Text color on a colored [block]: white, unless [highContrast] is on and
  /// dark text reads better than a white one that misses [minContrast].
  Color onBlock(Color block) {
    if (!highContrast) return AppColors.textOnColor;
    final white = contrastRatio(block, AppColors.textOnColor);
    if (white >= minContrast) return AppColors.textOnColor;
    final dark = contrastRatio(block, AppColors.textPrimary);
    return dark > white ? AppColors.textPrimary : AppColors.textOnColor;
  }

  /// WCAG contrast ratio between two opaque colors, from 1 to 21.
  static double contrastRatio(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    final (high, low) = la > lb ? (la, lb) : (lb, la);
    return (high + 0.05) / (low + 0.05);
  }

  /// Outline of a panel, null when [panelBorder] is transparent so the
  /// original panels keep their exact size.
  BoxBorder? get panelOutline =>
      panelBorder.a == 0 ? null : Border.all(color: panelBorder, width: 2);

  /// Floating shape color: tints cycle by [index], else light or dark.
  Color shapeColor(int index, {required bool isLight}) {
    final tints = shapeTints;
    if (tints != null) return tints[index % tints.length];
    return isLight ? shapeLight : shapeDark;
  }

  @override
  AppPalette copyWith({bool? highContrast}) => AppPalette(
        brightness: brightness,
        background: background,
        backgroundGradient: backgroundGradient,
        shapeLight: shapeLight,
        shapeDark: shapeDark,
        shapeTints: shapeTints,
        onBackground: onBackground,
        tile: tile,
        tileShadow: tileShadow,
        tileAccent: tileAccent,
        tileText: tileText,
        tileDisabled: tileDisabled,
        tileDisabledContent: tileDisabledContent,
        panel: panel,
        panelShadow: panelShadow,
        panelBorder: panelBorder,
        panelText: panelText,
        panelTextMuted: panelTextMuted,
        panelHint: panelHint,
        panelHighlight: panelHighlight,
        slot: slot,
        slotBorder: slotBorder,
        starInactive: starInactive,
        highContrast: highContrast ?? this.highContrast,
      );

  /// Themes switch at once: there is no in-between palette.
  @override
  AppPalette lerp(AppPalette? other, double t) =>
      other == null || t < 0.5 ? this : other;
}
