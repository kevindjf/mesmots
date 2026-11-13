import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_colors.dart';

/// The colors that change with the theme the parent picks.
///
/// Colored blocks (game cards, colored buttons, ABC button…) never change:
/// they keep using [AppColors] directly. Only what sits on the background
/// changes:
/// - [onBackground]: text and icons drawn right on the background.
/// - tiles: white elements on the background (letters, round and control
///   buttons, keys), anthracite with white content.
/// - panels: content cards and dialogs (progress header, boards, inputs).
/// - slots: boxes still to fill in letter games.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Brightness brightness;

  /// Plain background, behind screens without [backgroundGradient].
  final Color background;
  final List<Color> backgroundGradient;

  /// Floating shapes colors, cycled through.
  final List<Color> shapeTints;

  final Color onBackground;

  final Color tile;
  final Color tileShadow;

  /// Icons and button labels on a tile: the inverse of the tile.
  final Color tileIcon;

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
    required this.shapeTints,
    required this.onBackground,
    required this.tile,
    required this.tileShadow,
    required this.tileIcon,
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

  /// White background, dark text, anthracite tiles.
  static final light = AppPalette(
    brightness: Brightness.light,
    background: AppColors.surface,
    backgroundGradient: const [AppColors.surface, AppColors.surface],
    shapeTints: _tints(0.13),
    onBackground: AppColors.textPrimary,
    tile: AppColors.anthracite,
    tileShadow: AppColors.anthraciteShadow,
    tileIcon: AppColors.textOnColor,
    tileText: AppColors.textOnColor,
    tileDisabled: AppColors.lightDisabled,
    tileDisabledContent: AppColors.textLight,
    panel: AppColors.surface,
    panelShadow: AppColors.dashedBorder,
    panelBorder: AppColors.dashedBorder,
    panelText: AppColors.textPrimary,
    panelTextMuted: AppColors.textSecondary,
    panelHint: AppColors.textLight,
    panelHighlight: AppColors.lightHighlight,
    slot: AppColors.lightSlot,
    slotBorder: AppColors.lightSlotBorder,
    starInactive: AppColors.textLight,
  );

  static List<Color> _tints(double alpha) => [
        for (final color in const [
          AppColors.buttonOrange,
          AppColors.buttonPink,
          AppColors.buttonBlue,
          AppColors.buttonCoral,
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

  /// Outline of an element that is a panel, or a block of [blockColor]
  /// when given: same width either way, so switching never resizes it.
  BoxBorder? outlineOf(Color? blockColor) => blockColor == null
      ? panelOutline
      : Border.all(color: blockColor, width: 2);

  /// Color of the floating shape number [index].
  Color shapeColor(int index) => shapeTints[index % shapeTints.length];

  @override
  AppPalette copyWith({bool? highContrast}) => AppPalette(
        brightness: brightness,
        background: background,
        backgroundGradient: backgroundGradient,
        shapeTints: shapeTints,
        onBackground: onBackground,
        tile: tile,
        tileShadow: tileShadow,
        tileIcon: tileIcon,
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
