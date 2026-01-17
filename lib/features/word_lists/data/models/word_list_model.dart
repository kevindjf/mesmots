import 'package:isar/isar.dart';
import 'package:mesmots/features/word_lists/domain/entities/game_level.dart';
import 'package:mesmots/features/word_lists/domain/entities/level_progress.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_list.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_status.dart';

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

  // QCM Level Progress (flattened structure)
  late List<int> qcmSuccessCounts;
  late List<int> qcmConsecutiveErrors;
  late List<bool> qcmIsValidated;
  late bool qcmCompleted;
  DateTime? qcmCompletedAt;

  // Scramble Level Progress
  late List<int> scrambleSuccessCounts;
  late List<int> scrambleConsecutiveErrors;
  late List<bool> scrambleIsValidated;
  late bool scrambleCompleted;
  DateTime? scrambleCompletedAt;

  // Fill Blanks Level Progress
  late List<int> fillBlanksSuccessCounts;
  late List<int> fillBlanksConsecutiveErrors;
  late List<bool> fillBlanksIsValidated;
  late bool fillBlanksCompleted;
  DateTime? fillBlanksCompletedAt;

  // Writing Level Progress
  late List<int> writingSuccessCounts;
  late List<int> writingConsecutiveErrors;
  late List<bool> writingIsValidated;
  late bool writingCompleted;
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
