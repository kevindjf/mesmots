import 'package:isar/isar.dart';
import 'package:mesmots/features/word_lists/data/models/level_progress_model.dart';
import 'package:mesmots/features/word_lists/domain/entities/game_level.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_list.dart';

part 'word_list_model.g.dart';

@collection
class WordListModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late String name;
  late DateTime createdAt;
  late DateTime updatedAt;
  late List<String> words;

  // Progress for each level (order: qcm, scramble, fillBlanks, writing)
  late LevelProgressModel qcmProgress;
  late LevelProgressModel scrambleProgress;
  late LevelProgressModel fillBlanksProgress;
  late LevelProgressModel writingProgress;

  WordListModel();

  WordListModel.fromEntity(WordList entity) {
    uuid = entity.id;
    name = entity.name;
    createdAt = entity.createdAt;
    updatedAt = entity.updatedAt;
    words = entity.words;

    qcmProgress = LevelProgressModel.fromEntity(
      entity.progress[GameLevel.qcm]!,
    );
    scrambleProgress = LevelProgressModel.fromEntity(
      entity.progress[GameLevel.scramble]!,
    );
    fillBlanksProgress = LevelProgressModel.fromEntity(
      entity.progress[GameLevel.fillBlanks]!,
    );
    writingProgress = LevelProgressModel.fromEntity(
      entity.progress[GameLevel.writing]!,
    );
  }

  WordList toEntity() {
    return WordList(
      id: uuid,
      name: name,
      createdAt: createdAt,
      updatedAt: updatedAt,
      words: words,
      progress: {
        GameLevel.qcm: qcmProgress.toEntity(),
        GameLevel.scramble: scrambleProgress.toEntity(),
        GameLevel.fillBlanks: fillBlanksProgress.toEntity(),
        GameLevel.writing: writingProgress.toEntity(),
      },
    );
  }
}
