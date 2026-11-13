import 'package:hive/hive.dart';
import 'package:mesmots/features/appearance/domain/entities/appearance_settings.dart';
import 'package:mesmots/features/appearance/domain/repositories/appearance_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'appearance_repository_impl.g.dart';

/// Appearance preferences stored as plain values in a Hive box.
class AppearanceRepositoryImpl implements AppearanceRepository {
  /// Opened at startup (see `initializeDatabase`), so reads are synchronous.
  static const boxName = 'appearance';
  static const _highContrastKey = 'highContrast';

  final Box<dynamic> _box;

  AppearanceRepositoryImpl(this._box);

  @override
  AppearanceSettings load() {
    return AppearanceSettings(
      highContrast: _box.get(_highContrastKey) as bool? ??
          AppearanceSettings.initial.highContrast,
    );
  }

  @override
  Future<void> save(AppearanceSettings settings) => _box.putAll({
        _highContrastKey: settings.highContrast,
      });
}

@Riverpod(keepAlive: true)
AppearanceRepository appearanceRepository(AppearanceRepositoryRef ref) =>
    AppearanceRepositoryImpl(
        Hive.box<dynamic>(AppearanceRepositoryImpl.boxName));
