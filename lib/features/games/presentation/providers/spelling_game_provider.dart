import 'package:mesmots/core/utils/audio_service.dart';
import 'package:mesmots/core/utils/haptic_service.dart';
import 'package:mesmots/core/utils/string_utils.dart';
import 'package:mesmots/core/utils/tts_service.dart';
import 'package:mesmots/features/games/domain/entities/letter_puzzle.dart';
import 'package:mesmots/features/games/domain/usecases/generate_blanks.dart';
import 'package:mesmots/features/games/presentation/providers/progress_recorder.dart';
import 'package:mesmots/features/games/presentation/providers/puzzle_game_engine.dart';
import 'package:mesmots/features/word_lists/data/repositories/word_list_repository_impl.dart';
import 'package:mesmots/features/word_lists/domain/entities/game_type.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'spelling_game_provider.g.dart';

/// "Écoute et épelle": every letter is a blank, the tiles are the word's
/// letters with a few letters children confuse them with. The child
/// listens to the letter names to find them.
LetterPuzzle spellingPuzzle(String word, [GenerateBlanks? blanks]) {
  final letters = word.graphemes;
  final positions = [
    for (var i = 0; i < letters.length; i++)
      if (LetterPuzzle.isFillable(letters[i])) i,
  ];
  final needed = [for (final p in positions) letters[p]];
  final tiles = [...needed, ...(blanks ?? GenerateBlanks()).decoysFor(needed)]
    ..shuffle();
  return LetterPuzzle(word: word, blanks: positions, tiles: tiles);
}

@riverpod
class SpellingGame extends _$SpellingGame {
  late PuzzleGameEngine _engine;

  /// Actions of the game (place, remove, help, spell again…).
  PuzzleGameEngine get engine => _engine;

  @override
  Future<PuzzleGameState> build(String listId) async {
    final repository = ref.read(wordListRepositoryProvider);
    final wordList = await repository.getById(listId);
    if (wordList == null) throw Exception('Word list not found');

    _engine = PuzzleGameEngine(
      wordList: wordList,
      type: GameType.spelling,
      spellAloud: true,
      makePuzzle: spellingPuzzle,
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
