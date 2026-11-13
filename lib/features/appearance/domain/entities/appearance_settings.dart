/// Look of the app, picked by the parent.
enum ThemeChoice {
  /// Original turquoise background.
  turquoise,

  /// White background, dark text.
  light,

  /// Night blue background, light text.
  dark,

  /// Light or dark, following the device setting.
  system,
}

/// Appearance preferences of the app.
class AppearanceSettings {
  final ThemeChoice theme;

  /// Dark text on colored blocks where white text reads badly.
  final bool highContrast;

  const AppearanceSettings({
    this.theme = ThemeChoice.turquoise,
    this.highContrast = false,
  });

  /// Preferences of a fresh install: the original look.
  static const initial = AppearanceSettings();

  AppearanceSettings copyWith({ThemeChoice? theme, bool? highContrast}) =>
      AppearanceSettings(
        theme: theme ?? this.theme,
        highContrast: highContrast ?? this.highContrast,
      );

  @override
  bool operator ==(Object other) =>
      other is AppearanceSettings &&
      other.theme == theme &&
      other.highContrast == highContrast;

  @override
  int get hashCode => Object.hash(theme, highContrast);
}
