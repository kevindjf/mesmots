import 'package:mesmots/features/parental/domain/entities/parental_settings.dart';

/// Repository interface for parental settings
abstract class ParentalRepository {
  /// Get parental settings
  Future<ParentalSettings> get();

  /// Save parental settings
  Future<void> save(ParentalSettings settings);

  /// Delete parental settings (reset)
  Future<void> reset();

  /// Watch parental settings (stream)
  Stream<ParentalSettings> watch();
}
