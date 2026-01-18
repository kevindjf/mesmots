import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
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
        imageQuality: 70, // Reduced from 85 for faster processing
        maxWidth: 1920, // Limit image size
        maxHeight: 1920,
      );

      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  /// Crop an image (currently disabled due to compatibility issues)
  /// Returns the original image without cropping
  Future<File?> cropImage(String imagePath) async {
    // Image cropping temporarily disabled due to Android compatibility issues
    // Return the original image as-is
    return File(imagePath);
  }

  /// Recognize text from an image
  Future<List<String>> recognizeText(File imageFile) async {
    try {
      print('OCR: Starting text recognition...');
      final inputImage = InputImage.fromFile(imageFile);

      print('OCR: Processing image...');
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      print('OCR: Found ${recognizedText.blocks.length} text blocks');

      // Extract words line by line
      final words = <String>[];

      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          print('OCR: Processing line: ${line.text}');
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

      print('OCR: Extracted ${words.length} words');
      return words;
    } catch (e, stackTrace) {
      print('Error recognizing text: $e');
      print('Stack trace: $stackTrace');
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
