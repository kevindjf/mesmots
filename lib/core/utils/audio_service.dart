import 'package:audioplayers/audioplayers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_service.g.dart';

/// Audio service for playing sound effects
class AudioService {
  final AudioPlayer _player = AudioPlayer();

  /// Play success sound
  Future<void> playSuccess() async {
    try {
      await _player.play(AssetSource('sounds/success.mp3'));
    } catch (e) {
      print('Audio play error (success): $e');
    }
  }

  /// Play error sound
  Future<void> playError() async {
    try {
      await _player.play(AssetSource('sounds/error.mp3'));
    } catch (e) {
      print('Audio play error (error): $e');
    }
  }

  /// Play word validation sound
  Future<void> playWordComplete() async {
    try {
      await _player.play(AssetSource('sounds/word_complete.mp3'));
    } catch (e) {
      print('Audio play error (word_complete): $e');
    }
  }

  /// Play level completion sound
  Future<void> playLevelComplete() async {
    try {
      await _player.play(AssetSource('sounds/level_complete.mp3'));
    } catch (e) {
      print('Audio play error (level_complete): $e');
    }
  }

  /// Play tap/click sound
  Future<void> playTap() async {
    try {
      await _player.play(AssetSource('sounds/tap.mp3'));
    } catch (e) {
      print('Audio play error (tap): $e');
    }
  }

  /// Play star earned sound
  Future<void> playStar() async {
    try {
      await _player.play(AssetSource('sounds/star.mp3'));
    } catch (e) {
      print('Audio play error (star): $e');
    }
  }

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
