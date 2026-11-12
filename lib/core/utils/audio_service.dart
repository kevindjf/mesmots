import 'package:audioplayers/audioplayers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_service.g.dart';

/// Audio service for playing sound effects.
///
/// Every sound is loaded when the service is created: a sound loaded on
/// its first play is often silent on Android (it isn't ready yet), which
/// lost the first success sound of a game. One player per sound, so a
/// sound never cuts another one, and sounds mix with the voice reading
/// the words instead of interrupting it.
class AudioService {
  static const _sounds = [
    'success',
    'error',
    'word_complete',
    'level_complete',
    'tap',
    'star',
  ];

  static final _context = AudioContextConfig(
    focus: AudioContextConfigFocus.mixWithOthers,
  ).build();

  final _players = <String, Future<AudioPlayer?>>{};

  AudioService() {
    for (final sound in _sounds) {
      _players[sound] = _load(sound);
    }
  }

  Future<AudioPlayer?> _load(String sound) async {
    try {
      final player = AudioPlayer();
      await player.setAudioContext(_context);
      await player.setReleaseMode(ReleaseMode.stop);
      await player.setSource(AssetSource('sounds/$sound.mp3'));
      return player;
    } catch (_) {
      // Sound is a bonus: never break the game for it.
      return null;
    }
  }

  Future<void> _play(String sound) async {
    try {
      final player = await _players[sound];
      if (player == null) return;
      await player.stop();
      await player.resume();
    } catch (_) {
      // Sound is a bonus: never break the game for it.
    }
  }

  /// Play success sound
  Future<void> playSuccess() => _play('success');

  /// Play error sound
  Future<void> playError() => _play('error');

  /// Play word validation sound
  Future<void> playWordComplete() => _play('word_complete');

  /// Play level completion sound
  Future<void> playLevelComplete() => _play('level_complete');

  /// Play tap/click sound
  Future<void> playTap() => _play('tap');

  /// Play star earned sound
  Future<void> playStar() => _play('star');

  void dispose() {
    for (final player in _players.values) {
      player.then((p) => p?.dispose());
    }
  }
}

@Riverpod(keepAlive: true)
AudioService audioService(AudioServiceRef ref) {
  final service = AudioService();
  ref.onDispose(service.dispose);
  return service;
}
