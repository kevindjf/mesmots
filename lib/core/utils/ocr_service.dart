import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ocr_service.g.dart';

/// Service for OCR (Optical Character Recognition) using Google ML Kit
class OcrService {
  final _textRecognizer = TextRecognizer();
  final _imagePicker = ImagePicker();

  /// Pick an image from camera or gallery
  Future<File?> pickImage({required bool fromCamera}) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  /// Crop an image
  Future<File?> cropImage(String imagePath) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 85,
        androidUiSettings: const AndroidUiSettings(
          toolbarTitle: 'Recadrer',
          toolbarColor: Color(0xFF7EC8E3),
          toolbarWidgetColor: Color(0xFFFFFFFF),
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        iosUiSettings: const IOSUiSettings(
          title: 'Recadrer',
        ),
      );

      return croppedFile;
    } catch (e) {
      print('Error cropping image: $e');
      return null;
    }
  }

  /// Recognize text from an image
  Future<List<String>> recognizeText(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      // Extract words line by line
      final words = <String>[];

      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          // Split line text by spaces and filter
          final lineWords = line.text
              .split(RegExp(r'[\s,;]+')) // Split by space, comma, semicolon
              .map((w) => w.trim())
              .where((w) => w.isNotEmpty)
              .where((w) => _isValidWord(w))
              .map((w) => _cleanWord(w))
              .toList();

          words.addAll(lineWords);
        }
      }

      return words;
    } catch (e) {
      print('Error recognizing text: $e');
      return [];
    }
  }

  /// Check if a word is valid (contains mostly letters)
  bool _isValidWord(String word) {
    if (word.length < 2) return false;

    // Count letters
    final letterCount = word.runes.where((rune) {
      final char = String.fromCharCode(rune);
      return RegExp(r'[a-zA-ZàâäéèêëïîôùûüÿæœçÀÂÄÉÈÊËÏÎÔÙÛÜŸÆŒÇ]').hasMatch(char);
    }).length;

    // Word should be at least 70% letters
    return letterCount >= (word.length * 0.7);
  }

  /// Clean word by removing trailing punctuation
  String _cleanWord(String word) {
    // Remove leading/trailing punctuation but keep accents and hyphens
    word = word.replaceAll(RegExp(r'^[^\w\-àâäéèêëïîôùûüÿæœç]+'), '');
    word = word.replaceAll(RegExp(r'[^\w\-àâäéèêëïîôùûüÿæœç]+$'), '');

    // Convert to lowercase
    return word.toLowerCase();
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
