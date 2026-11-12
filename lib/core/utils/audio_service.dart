import 'package:audioplayers/audioplayers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_service.g.dart';

/// Audio service for playing sound effects
///
/// One player per sound, so a sound never cuts another one
/// (e.g. the word fanfare right after the success chime).
class AudioService {
  final _players = <String, AudioPlayer>{};

  Future<void> _play(String asset) async {
    try {
      final player = _players.putIfAbsent(
        asset,
        () => AudioPlayer()..setPlayerMode(PlayerMode.lowLatency),
      );
      await player.stop();
      await player.play(AssetSource(asset));
    } catch (_) {
      // Sound is a bonus: never break the game for it.
    }
  }

  /// Play success sound
  Future<void> playSuccess() => _play('sounds/success.mp3');

  /// Play error sound
  Future<void> playError() => _play('sounds/error.mp3');

  /// Play word validation sound
  Future<void> playWordComplete() => _play('sounds/word_complete.mp3');

  /// Play level completion sound
  Future<void> playLevelComplete() => _play('sounds/level_complete.mp3');

  /// Play tap/click sound
  Future<void> playTap() => _play('sounds/tap.mp3');

  /// Play star earned sound
  Future<void> playStar() => _play('sounds/star.mp3');

  void dispose() {
    for (final player in _players.values) {
      player.dispose();
    }
  }
}

@riverpod
AudioService audioService(AudioServiceRef ref) {
  final service = AudioService();
  ref.onDispose(() => service.dispose());
  return service;
}
