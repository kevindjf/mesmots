import 'package:isar/isar.dart';
import 'package:mesmots/features/parental/domain/entities/parental_settings.dart';

part 'parental_settings_model.g.dart';

@collection
class ParentalSettingsModel {
  Id id = 1; // Singleton - always ID 1

  String? pinHash;
  String? recoveryQuestion;
  String? recoveryAnswerHash;
  late bool isPinConfigured;

  ParentalSettingsModel();

  ParentalSettingsModel.fromEntity(ParentalSettings entity) {
    pinHash = entity.pinHash;
    recoveryQuestion = entity.recoveryQuestion;
    recoveryAnswerHash = entity.recoveryAnswerHash;
    isPinConfigured = entity.isPinConfigured;
  }

  ParentalSettings toEntity() {
    return ParentalSettings(
      pinHash: pinHash,
      recoveryQuestion: recoveryQuestion,
      recoveryAnswerHash: recoveryAnswerHash,
      isPinConfigured: isPinConfigured,
    );
  }
}
