import 'package:flutter_tts/flutter_tts.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tts_service.g.dart';

/// Text-to-Speech service for reading words aloud
class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _tts.setLanguage('fr-FR');
      await _tts.setSpeechRate(0.5); // Moderate speed for children
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      // Set iOS-specific settings
      await _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
        ],
        IosTextToSpeechAudioMode.defaultMode,
      );

      _isInitialized = true;
    } catch (e) {
      // Log error but don't throw
      print('TTS initialization error: $e');
    }
  }

  /// Speak a word
  Future<void> speak(String word) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await _tts.speak(word);
    } catch (e) {
      print('TTS speak error: $e');
    }
  }

  /// Stop speaking
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (e) {
      print('TTS stop error: $e');
    }
  }

  /// Check if TTS is available
  Future<bool> isAvailable() async {
    try {
      final languages = await _tts.getLanguages;
      return languages != null && languages.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _tts.stop();
  }
}

@riverpod
TtsService ttsService(TtsServiceRef ref) {
  final service = TtsService();
  ref.onDispose(() => service.dispose());
  return service;
}
