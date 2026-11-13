/// Appearance preferences of the app.
class AppearanceSettings {
  /// Dark text on colored blocks where white text reads badly.
  final bool highContrast;

  const AppearanceSettings({this.highContrast = false});

  /// Preferences of a fresh install.
  static const initial = AppearanceSettings();

  AppearanceSettings copyWith({bool? highContrast}) =>
      AppearanceSettings(highContrast: highContrast ?? this.highContrast);

  @override
  bool operator ==(Object other) =>
      other is AppearanceSettings && other.highContrast == highContrast;

  @override
  int get hashCode => highContrast.hashCode;
}
