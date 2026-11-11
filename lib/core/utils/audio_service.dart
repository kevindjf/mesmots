import 'package:audioplayers/audioplayers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_service.g.dart';

/// Audio service for playing sound effects
class AudioService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> _play(String asset) async {
    try {
      await _player.stop();
      await _player.play(AssetSource(asset));
    } catch (_) {
      // Silently ignore - sound files may be empty placeholders
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

  /// Play brick pick sound (verb builder)
  Future<void> playPick() => _play('sounds/pick.mp3');

  /// Play brick snap sound (verb builder)
  Future<void> playSnap() => _play('sounds/snap.mp3');

  /// Play time up sound (conjugation timer)
  Future<void> playTimeUp() => _play('sounds/time_up.mp3');

  void dispose() {
    _player.dispose();
  }
}

@riverpod
AudioService audioService(AudioServiceRef ref) {
  final service = AudioService();
  ref.onDispose(() => service.dispose());
  return service;
}
