import 'package:mesmots/features/appearance/domain/entities/appearance_settings.dart';

/// Storage of the appearance preferences.
abstract class AppearanceRepository {
  /// Saved preferences, [AppearanceSettings.initial] when none.
  ///
  /// Synchronous: the theme is needed for the very first frame.
  AppearanceSettings load();

  Future<void> save(AppearanceSettings settings);
}
