import 'package:isar/isar.dart';
import 'package:mesmots/features/word_lists/data/models/word_status_model.dart';
import 'package:mesmots/features/word_lists/domain/entities/level_progress.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_status.dart';

part 'level_progress_model.g.dart';

@embedded
class LevelProgressModel {
  /// Words in this level
  late List<String> words;

  /// Corresponding statuses (same order as words)
  late List<WordStatusModel> statuses;

  late bool isCompleted;
  DateTime? completedAt;

  LevelProgressModel();

  LevelProgressModel.fromEntity(LevelProgress entity) {
    words = entity.wordStatuses.keys.toList();
    statuses = entity.wordStatuses.values
        .map((status) => WordStatusModel.fromEntity(status))
        .toList();
    isCompleted = entity.isCompleted;
    completedAt = entity.completedAt;
  }

  LevelProgress toEntity() {
    final wordStatuses = <String, WordStatus>{};

    for (var i = 0; i < words.length; i++) {
      wordStatuses[words[i]] = statuses[i].toEntity();
    }

    return LevelProgress(
      wordStatuses: wordStatuses,
      isCompleted: isCompleted,
      completedAt: completedAt,
    );
  }
}
