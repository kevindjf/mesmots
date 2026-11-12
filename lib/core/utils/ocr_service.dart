import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mesmots/features/word_lists/domain/usecases/parse_word_list_text.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ocr_service.g.dart';

/// Service for OCR (Optical Character Recognition) using Google ML Kit
class OcrService {
  final _textRecognizer = TextRecognizer();
  final _imagePicker = ImagePicker();
  final _parseWordListText = const ParseWordListText();

  /// Pick an image from camera or gallery.
  ///
  /// Text recognition needs sharp letters: the photo is kept large
  /// (a page of handwriting shrunk to 800 px is mostly unreadable).
  Future<File?> pickImage({required bool fromCamera}) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 90,
        maxWidth: 2400,
        maxHeight: 2400,
      );
      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      debugPrint('OCR: error picking image: $e');
      return null;
    }
  }

  /// Recognize the words of a word list in an image.
  Future<List<String>> recognizeText(File imageFile) async {
    try {
      final recognizedText = await _textRecognizer.processImage(
        InputImage.fromFile(imageFile),
      );
      final lines = [
        for (final block in recognizedText.blocks)
          for (final line in block.lines) line.text,
      ];
      return _parseWordListText(lines);
    } catch (e) {
      debugPrint('OCR: error recognizing text: $e');
      return [];
    }
  }

  /// Dispose resources
  void dispose() {
    _textRecognizer.close();
  }
}

@riverpod
OcrService ocrService(OcrServiceRef ref) {
  final service = OcrService();
  ref.onDispose(() => service.dispose());
  return service;
}
