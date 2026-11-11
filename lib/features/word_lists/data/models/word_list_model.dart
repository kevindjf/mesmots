import 'package:hive/hive.dart';
import 'package:mesmots/features/word_lists/domain/entities/game_level.dart';
import 'package:mesmots/features/word_lists/domain/entities/level_progress.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_list.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_status.dart';

part 'word_list_model.g.dart';

@HiveType(typeId: 0)
class WordListModel extends HiveObject {
  @HiveField(0)
  late String uuid;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late DateTime createdAt;

  @HiveField(3)
  late DateTime updatedAt;

  @HiveField(4)
  late List<String> words;

  // QCM Level Progress (flattened structure)
  @HiveField(5)
  late List<int> qcmSuccessCounts;

  @HiveField(6)
  late List<int> qcmConsecutiveErrors;

  @HiveField(7)
  late List<bool> qcmIsValidated;

  @HiveField(8)
  late bool qcmCompleted;

  @HiveField(9)
  DateTime? qcmCompletedAt;

  // Scramble Level Progress
  @HiveField(10)
  late List<int> scrambleSuccessCounts;

  @HiveField(11)
  late List<int> scrambleConsecutiveErrors;

  @HiveField(12)
  late List<bool> scrambleIsValidated;

  @HiveField(13)
  late bool scrambleCompleted;

  @HiveField(14)
  DateTime? scrambleCompletedAt;

  // Fill Blanks Level Progress
  @HiveField(15)
  late List<int> fillBlanksSuccessCounts;

  @HiveField(16)
  late List<int> fillBlanksConsecutiveErrors;

  @HiveField(17)
  late List<bool> fillBlanksIsValidated;

  @HiveField(18)
  late bool fillBlanksCompleted;

  @HiveField(19)
  DateTime? fillBlanksCompletedAt;

  // Writing Level Progress
  @HiveField(20)
  late List<int> writingSuccessCounts;

  @HiveField(21)
  late List<int> writingConsecutiveErrors;

  @HiveField(22)
  late List<bool> writingIsValidated;

  @HiveField(23)
  late bool writingCompleted;

  @HiveField(24)
  DateTime? writingCompletedAt;

  WordListModel();

  WordListModel.fromEntity(WordList entity) {
    uuid = entity.id;
    name = entity.name;
    createdAt = entity.createdAt;
    updatedAt = entity.updatedAt;
    words = entity.words;

    // Convert QCM progress
    final qcmProgress = entity.progress[GameLevel.qcm]!;
    qcmSuccessCounts = words.map((w) => qcmProgress.wordStatuses[w]?.successCount ?? 0).toList();
    qcmConsecutiveErrors = words.map((w) => qcmProgress.wordStatuses[w]?.consecutiveErrors ?? 0).toList();
    qcmIsValidated = words.map((w) => qcmProgress.wordStatuses[w]?.isValidated ?? false).toList();
    qcmCompleted = qcmProgress.isCompleted;
    qcmCompletedAt = qcmProgress.completedAt;

    // Convert Scramble progress
    final scrambleProgress = entity.progress[GameLevel.scramble]!;
    scrambleSuccessCounts = words.map((w) => scrambleProgress.wordStatuses[w]?.successCount ?? 0).toList();
    scrambleConsecutiveErrors = words.map((w) => scrambleProgress.wordStatuses[w]?.consecutiveErrors ?? 0).toList();
    scrambleIsValidated = words.map((w) => scrambleProgress.wordStatuses[w]?.isValidated ?? false).toList();
    scrambleCompleted = scrambleProgress.isCompleted;
    scrambleCompletedAt = scrambleProgress.completedAt;

    // Convert Fill Blanks progress
    final fillBlanksProgress = entity.progress[GameLevel.fillBlanks]!;
    fillBlanksSuccessCounts = words.map((w) => fillBlanksProgress.wordStatuses[w]?.successCount ?? 0).toList();
    fillBlanksConsecutiveErrors = words.map((w) => fillBlanksProgress.wordStatuses[w]?.consecutiveErrors ?? 0).toList();
    fillBlanksIsValidated = words.map((w) => fillBlanksProgress.wordStatuses[w]?.isValidated ?? false).toList();
    fillBlanksCompleted = fillBlanksProgress.isCompleted;
    fillBlanksCompletedAt = fillBlanksProgress.completedAt;

    // Convert Writing progress
    final writingProgress = entity.progress[GameLevel.writing]!;
    writingSuccessCounts = words.map((w) => writingProgress.wordStatuses[w]?.successCount ?? 0).toList();
    writingConsecutiveErrors = words.map((w) => writingProgress.wordStatuses[w]?.consecutiveErrors ?? 0).toList();
    writingIsValidated = words.map((w) => writingProgress.wordStatuses[w]?.isValidated ?? false).toList();
    writingCompleted = writingProgress.isCompleted;
    writingCompletedAt = writingProgress.completedAt;
  }

  WordList toEntity() {
    // Reconstruct QCM progress
    final qcmWordStatuses = <String, WordStatus>{};
    for (var i = 0; i < words.length; i++) {
      qcmWordStatuses[words[i]] = WordStatus(
        successCount: qcmSuccessCounts[i],
        consecutiveErrors: qcmConsecutiveErrors[i],
        isValidated: qcmIsValidated[i],
      );
    }
    final qcmProgress = LevelProgress(
      wordStatuses: qcmWordStatuses,
      isCompleted: qcmCompleted,
      completedAt: qcmCompletedAt,
    );

    // Reconstruct Scramble progress
    final scrambleWordStatuses = <String, WordStatus>{};
    for (var i = 0; i < words.length; i++) {
      scrambleWordStatuses[words[i]] = WordStatus(
        successCount: scrambleSuccessCounts[i],
        consecutiveErrors: scrambleConsecutiveErrors[i],
        isValidated: scrambleIsValidated[i],
      );
    }
    final scrambleProgress = LevelProgress(
      wordStatuses: scrambleWordStatuses,
      isCompleted: scrambleCompleted,
      completedAt: scrambleCompletedAt,
    );

    // Reconstruct Fill Blanks progress
    final fillBlanksWordStatuses = <String, WordStatus>{};
    for (var i = 0; i < words.length; i++) {
      fillBlanksWordStatuses[words[i]] = WordStatus(
        successCount: fillBlanksSuccessCounts[i],
        consecutiveErrors: fillBlanksConsecutiveErrors[i],
        isValidated: fillBlanksIsValidated[i],
      );
    }
    final fillBlanksProgress = LevelProgress(
      wordStatuses: fillBlanksWordStatuses,
      isCompleted: fillBlanksCompleted,
      completedAt: fillBlanksCompletedAt,
    );

    // Reconstruct Writing progress
    final writingWordStatuses = <String, WordStatus>{};
    for (var i = 0; i < words.length; i++) {
      writingWordStatuses[words[i]] = WordStatus(
        successCount: writingSuccessCounts[i],
        consecutiveErrors: writingConsecutiveErrors[i],
        isValidated: writingIsValidated[i],
      );
    }
    final writingProgress = LevelProgress(
      wordStatuses: writingWordStatuses,
      isCompleted: writingCompleted,
      completedAt: writingCompletedAt,
    );

    return WordList(
      id: uuid,
      name: name,
      createdAt: createdAt,
      updatedAt: updatedAt,
      words: words,
      progress: {
        GameLevel.qcm: qcmProgress,
        GameLevel.scramble: scrambleProgress,
        GameLevel.fillBlanks: fillBlanksProgress,
        GameLevel.writing: writingProgress,
      },
    );
  }
}
