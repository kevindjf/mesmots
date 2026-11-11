import 'package:mesmots/features/word_lists/domain/entities/game_type.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_status.dart';

/// Word list entity (the words of the week)
class WordList {
  /// Unique identifier
  final String id;

  /// List name
  final String name;

  /// Creation timestamp
  final DateTime createdAt;

  /// Last update timestamp
  final DateTime updatedAt;

  /// List of words
  final List<String> words;

  /// Global mastery for each word (key: word)
  final Map<String, WordStatus> mastery;

  /// Number of completed games per game type
  final Map<GameType, int> playCount;

  const WordList({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.words,
    required this.mastery,
    required this.playCount,
  });

  /// Create a new word list
  factory WordList.create({
    required String id,
    required String name,
    required List<String> words,
  }) {
    final now = DateTime.now();
    return WordList(
      id: id,
      name: name,
      createdAt: now,
      updatedAt: now,
      words: words,
      mastery: {for (final word in words) word: WordStatus.initial()},
      playCount: const {},
    );
  }

  /// Mastery status of a word
  WordStatus statusOf(String word) => mastery[word] ?? WordStatus.initial();

  /// Number of mastered words
  int get masteredCount => words.where((w) => statusOf(w).isMastered).length;

  /// Mastery ratio (0.0 to 1.0)
  double get masteryRatio =>
      words.isEmpty ? 0.0 : masteredCount / words.length;

  /// Whether every word of the list is mastered
  bool get isMastered => words.isNotEmpty && masteredCount == words.length;

  /// Number of completed games for a game type
  int playCountOf(GameType type) => playCount[type] ?? 0;

  /// Update word list name
  WordList updateName(String newName) {
    return copyWith(name: newName, updatedAt: DateTime.now());
  }

  /// Update words, keeping mastery of words still present
  WordList updateWords(List<String> newWords) {
    return copyWith(
      words: newWords,
      mastery: {for (final word in newWords) word: statusOf(word)},
      updatedAt: DateTime.now(),
    );
  }

  /// Record an attempt on a word, from any game
  WordList recordAttempt(String word, {required bool success}) {
    if (!words.contains(word)) return this;

    final current = statusOf(word);
    return copyWith(
      mastery: {
        ...mastery,
        word: success ? current.recordSuccess() : current.recordError(),
      },
      updatedAt: DateTime.now(),
    );
  }

  /// Record a completed game
  WordList recordGamePlayed(GameType type) {
    return copyWith(
      playCount: {...playCount, type: playCountOf(type) + 1},
      updatedAt: DateTime.now(),
    );
  }

  /// Reset mastery and play counts
  WordList resetAllProgress() {
    return copyWith(
      mastery: {for (final word in words) word: WordStatus.initial()},
      playCount: const {},
      updatedAt: DateTime.now(),
    );
  }

  WordList copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? words,
    Map<String, WordStatus>? mastery,
    Map<GameType, int>? playCount,
  }) {
    return WordList(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      words: words ?? this.words,
      mastery: mastery ?? this.mastery,
      playCount: playCount ?? this.playCount,
    );
  }

  @override
  String toString() => 'WordList(id: $id, name: $name, words: ${words.length})';
}
