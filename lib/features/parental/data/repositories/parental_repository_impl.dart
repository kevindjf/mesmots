import 'package:mesmots/features/parental/data/datasources/parental_local_datasource.dart';
import 'package:mesmots/features/parental/data/models/parental_settings_model.dart';
import 'package:mesmots/features/parental/domain/entities/parental_settings.dart';
import 'package:mesmots/features/parental/domain/repositories/parental_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'parental_repository_impl.g.dart';

/// Implementation of ParentalRepository using local data source
class ParentalRepositoryImpl implements ParentalRepository {
  final ParentalLocalDataSource _dataSource;

  ParentalRepositoryImpl(this._dataSource);

  @override
  Future<ParentalSettings> get() async {
    final model = await _dataSource.get();
    return model?.toEntity() ?? ParentalSettings.initial();
  }

  @override
  Future<void> save(ParentalSettings settings) async {
    final model = ParentalSettingsModel.fromEntity(settings);
    await _dataSource.save(model);
  }

  @override
  Future<void> reset() async {
    await _dataSource.delete();
  }

  @override
  Stream<ParentalSettings> watch() {
    return _dataSource.watch().map(
          (model) => model?.toEntity() ?? ParentalSettings.initial(),
        );
  }
}

@riverpod
ParentalRepository parentalRepository(ParentalRepositoryRef ref) {
  final dataSource = ref.watch(parentalLocalDataSourceProvider);
  return ParentalRepositoryImpl(dataSource);
}
