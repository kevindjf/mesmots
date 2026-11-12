import 'package:hive/hive.dart';
import 'package:mesmots/features/word_lists/domain/entities/game_type.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_list.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_status.dart';

part 'word_list_model.g.dart';

/// Hive model for a word list.
///
/// Fields 5 to 24 held the former per-level progress and are no longer read.
/// Records saved before free play have null mastery fields and start fresh.
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

  /// Mastery success count per word (same order as [words])
  @HiveField(25)
  List<int>? masterySuccess;

  /// Mastery consecutive errors per word (same order as [words])
  @HiveField(26)
  List<int>? masteryErrors;

  /// Completed games per game type name
  @HiveField(27)
  Map<String, int>? playCounts;

  /// Allowed game type names. Null means every game (records saved before
  /// this field existed).
  @HiveField(28)
  List<String>? enabledGames;

  WordListModel();

  WordListModel.fromEntity(WordList entity) {
    uuid = entity.id;
    name = entity.name;
    createdAt = entity.createdAt;
    updatedAt = entity.updatedAt;
    words = List.of(entity.words);
    masterySuccess = words.map((w) => entity.statusOf(w).successCount).toList();
    masteryErrors =
        words.map((w) => entity.statusOf(w).consecutiveErrors).toList();
    playCounts = {
      for (final entry in entity.playCount.entries) entry.key.name: entry.value,
    };
    enabledGames = entity.enabledGames.length == GameType.values.length
        ? null
        : [
            for (final type in GameType.values)
              if (entity.isGameEnabled(type)) type.name,
          ];
  }

  WordList toEntity() {
    final success = masterySuccess;
    final errors = masteryErrors;
    final hasMastery = success != null &&
        errors != null &&
        success.length == words.length &&
        errors.length == words.length;

    return WordList(
      id: uuid,
      name: name,
      createdAt: createdAt,
      updatedAt: updatedAt,
      words: words,
      mastery: {
        for (var i = 0; i < words.length; i++)
          words[i]: hasMastery
              ? WordStatus(
                  successCount: success[i],
                  consecutiveErrors: errors[i],
                )
              : WordStatus.initial(),
      },
      playCount: {
        for (final type in GameType.values)
          if (playCounts?[type.name] != null) type: playCounts![type.name]!,
      },
      enabledGames: _decodeEnabledGames(),
    );
  }

  Set<GameType> _decodeEnabledGames() {
    final names = enabledGames;
    if (names == null) return WordList.allGames;
    final games = {
      for (final type in GameType.values)
        if (names.contains(type.name)) type,
    };
    return games.isEmpty ? WordList.allGames : games;
  }
}
