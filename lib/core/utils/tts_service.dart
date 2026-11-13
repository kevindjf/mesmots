import 'package:flutter_tts/flutter_tts.dart';
import 'package:mesmots/core/extensions/letter_name.dart';
import 'package:mesmots/core/utils/string_utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tts_service.g.dart';

/// Text-to-Speech service for reading words aloud
class TtsService {
  /// Silence between two spelled letters.
  static const letterPause = Duration(milliseconds: 350);

  /// Safety net when the engine never reports the end of a speech
  /// (seen on some emulators).
  static const _speechTimeout = Duration(seconds: 4);

  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;

  /// Bumped by every new speech: a spelling in progress stops as soon as
  /// something else is said.
  int _utterance = 0;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _tts.setLanguage('fr-FR');
      await _tts.setSpeechRate(0.5); // Moderate speed for children
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      // Spelling waits for each letter to be said before the next one.
      await _tts.awaitSpeakCompletion(true);

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

    _utterance++;
    try {
      await _tts.speak(word);
    } catch (e) {
      print('TTS speak error: $e');
    }
  }

  /// Say [word], then spell it letter by letter with the French letter
  /// names ("sept": "èss", "eu", "pé", "té").
  ///
  /// [onLetter] gets the position (grapheme index) of the letter being
  /// said, then null when the spelling ends or is interrupted by another
  /// speech.
  Future<void> spell(
    String word, {
    bool sayWordFirst = true,
    void Function(int? position)? onLetter,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final utterance = ++_utterance;
    bool interrupted() => utterance != _utterance;
    try {
      await _tts.stop();
      if (sayWordFirst) {
        await _sayToEnd(word);
        await Future.delayed(letterPause * 2);
      }
      final letters = word.graphemes;
      for (var i = 0; i < letters.length; i++) {
        final name = letters[i].letterName;
        if (interrupted()) return;
        if (name == null) continue;
        onLetter?.call(i);
        await _sayToEnd(name);
        if (interrupted()) return;
        await Future.delayed(letterPause);
      }
    } catch (e) {
      print('TTS spell error: $e');
    } finally {
      onLetter?.call(null);
    }
  }

  Future<void> _sayToEnd(String text) async {
    await _tts.speak(text).timeout(_speechTimeout, onTimeout: () => null);
  }

  /// Stop speaking
  Future<void> stop() async {
    _utterance++;
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
