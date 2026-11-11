import 'package:hive/hive.dart';
import 'package:mesmots/features/parental/domain/entities/parental_settings.dart';

part 'parental_settings_model.g.dart';

@HiveType(typeId: 1)
class ParentalSettingsModel extends HiveObject {
  @HiveField(0)
  String? pinHash;

  @HiveField(1)
  String? recoveryQuestion;

  @HiveField(2)
  String? recoveryAnswerHash;

  @HiveField(3)
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
