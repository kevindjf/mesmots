import 'package:mesmots/core/utils/audio_service.dart';
import 'package:mesmots/core/utils/haptic_service.dart';
import 'package:mesmots/core/utils/string_utils.dart';
import 'package:mesmots/core/utils/tts_service.dart';
import 'package:mesmots/features/games/domain/entities/letter_puzzle.dart';
import 'package:mesmots/features/games/presentation/providers/progress_recorder.dart';
import 'package:mesmots/features/games/presentation/providers/puzzle_game_engine.dart';
import 'package:mesmots/features/word_lists/data/repositories/word_list_repository_impl.dart';
import 'package:mesmots/features/word_lists/domain/entities/game_type.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'scramble_game_provider.g.dart';

/// "Lettres mélangées": every letter is a blank, the tiles are the word's
/// letters shuffled (spaces and hyphens of compound words stay given).
LetterPuzzle scramblePuzzle(String word) {
  final letters = word.graphemes;
  final blanks = [
    for (var i = 0; i < letters.length; i++)
      if (LetterPuzzle.isFillable(letters[i])) i,
  ];
  final tiles = [for (final b in blanks) letters[b]];
  final ordered = tiles.join();
  // Shuffle until the tiles don't already spell the word.
  for (var i = 0; i < 10; i++) {
    tiles.shuffle();
    if (tiles.join() != ordered) break;
  }
  return LetterPuzzle(word: word, blanks: blanks, tiles: tiles);
}

@riverpod
class ScrambleGame extends _$ScrambleGame {
  late PuzzleGameEngine _engine;

  /// Actions of the game (place, remove, help…).
  PuzzleGameEngine get engine => _engine;

  @override
  Future<PuzzleGameState> build(String listId) async {
    final repository = ref.read(wordListRepositoryProvider);
    final wordList = await repository.getById(listId);
    if (wordList == null) throw Exception('Word list not found');

    _engine = PuzzleGameEngine(
      wordList: wordList,
      type: GameType.scramble,
      makePuzzle: scramblePuzzle,
      tts: ref.read(ttsServiceProvider),
      audio: ref.read(audioServiceProvider),
      haptic: ref.read(hapticServiceProvider),
      recorder: ProgressRecorder(repository, listId),
      onChange: (s) => state = AsyncData(s),
    );
    ref.onDispose(_engine.dispose);
    return _engine.state;
  }
}
