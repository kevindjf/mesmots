import 'package:isar/isar.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_status.dart';

@embedded
class WordStatusModel {
  late int successCount;
  late int consecutiveErrors;
  late bool isValidated;

  WordStatusModel();

  WordStatusModel.fromEntity(WordStatus entity) {
    successCount = entity.successCount;
    consecutiveErrors = entity.consecutiveErrors;
    isValidated = entity.isValidated;
  }

  WordStatus toEntity() {
    return WordStatus(
      successCount: successCount,
      consecutiveErrors: consecutiveErrors,
      isValidated: isValidated,
    );
  }
}
