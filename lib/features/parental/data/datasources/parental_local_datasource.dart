import 'package:isar/isar.dart';
import 'package:mesmots/features/parental/data/models/parental_settings_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mesmots/core/utils/database_provider.dart';

part 'parental_local_datasource.g.dart';

/// Local data source for parental settings using Isar
class ParentalLocalDataSource {
  final Isar _isar;

  ParentalLocalDataSource(this._isar);

  /// Get parental settings (singleton)
  Future<ParentalSettingsModel?> get() async {
    return await _isar.parentalSettingsModels.get(1);
  }

  /// Save parental settings
  Future<void> save(ParentalSettingsModel model) async {
    await _isar.writeTxn(() async {
      model.id = 1; // Ensure singleton ID
      await _isar.parentalSettingsModels.put(model);
    });
  }

  /// Delete parental settings (reset)
  Future<void> delete() async {
    await _isar.writeTxn(() async {
      await _isar.parentalSettingsModels.delete(1);
    });
  }

  /// Watch parental settings (stream)
  Stream<ParentalSettingsModel?> watch() {
    return _isar.parentalSettingsModels
        .watchObject(1, fireImmediately: true);
  }
}

@riverpod
ParentalLocalDataSource parentalLocalDataSource(
  ParentalLocalDataSourceRef ref,
) {
  final isar = ref.watch(isarProvider).requireValue;
  return ParentalLocalDataSource(isar);
}
