import 'package:mesmots/core/utils/audio_service.dart';
import 'package:mesmots/core/utils/haptic_service.dart';
import 'package:mesmots/core/utils/tts_service.dart';
import 'package:mesmots/features/games/domain/usecases/generate_blanks.dart';
import 'package:mesmots/features/games/presentation/providers/progress_recorder.dart';
import 'package:mesmots/features/games/presentation/providers/puzzle_game_engine.dart';
import 'package:mesmots/features/word_lists/data/repositories/word_list_repository_impl.dart';
import 'package:mesmots/features/word_lists/domain/entities/game_type.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fill_blanks_game_provider.g.dart';

/// "Mots à trous": the blanks are on the word's spelling difficulties and
/// the tiles mix the right letters with decoys.
@riverpod
class FillBlanksGame extends _$FillBlanksGame {
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
      type: GameType.fillBlanks,
      makePuzzle: GenerateBlanks().call,
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
