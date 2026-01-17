import 'package:hive/hive.dart';
import 'package:mesmots/features/parental/data/models/parental_settings_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mesmots/core/utils/database_provider.dart';

part 'parental_local_datasource.g.dart';

/// Local data source for parental settings using Hive
class ParentalLocalDataSource {
  final Box<ParentalSettingsModel> _box;
  static const String _settingsKey = 'settings';

  ParentalLocalDataSource(this._box);

  /// Get parental settings (singleton)
  Future<ParentalSettingsModel?> get() async {
    return _box.get(_settingsKey);
  }

  /// Save parental settings
  Future<void> save(ParentalSettingsModel model) async {
    await _box.put(_settingsKey, model);
  }

  /// Delete parental settings (reset)
  Future<void> delete() async {
    await _box.delete(_settingsKey);
  }

  /// Watch parental settings (stream)
  Stream<ParentalSettingsModel?> watch() async* {
    // Emit initial value
    yield _box.get(_settingsKey);

    // Then watch for changes
    await for (final _ in _box.watch(key: _settingsKey)) {
      yield _box.get(_settingsKey);
    }
  }
}

@riverpod
ParentalLocalDataSource parentalLocalDataSource(
  ParentalLocalDataSourceRef ref,
) {
  final box = ref.watch(parentalSettingsBoxProvider).requireValue;
  return ParentalLocalDataSource(box);
}
