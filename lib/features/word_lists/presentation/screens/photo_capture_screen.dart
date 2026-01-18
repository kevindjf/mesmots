import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/core/utils/ocr_service.dart';
import 'package:mesmots/shared/widgets/app_button.dart';

class PhotoCaptureScreen extends ConsumerStatefulWidget {
  const PhotoCaptureScreen({super.key});

  @override
  ConsumerState<PhotoCaptureScreen> createState() =>
      _PhotoCaptureScreenState();
}

class _PhotoCaptureScreenState extends ConsumerState<PhotoCaptureScreen> {
  File? _imageFile;
  List<String> _detectedWords = [];
  bool _isProcessing = false;
  int _currentStep = 0; // 0 = capture, 1 = crop, 2 = edit words

  final _wordControllers = <TextEditingController>[];

  @override
  void dispose() {
    for (final controller in _wordControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détecter les mots'),
        actions: _currentStep == 2 && _detectedWords.isNotEmpty
            ? [
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: _saveWords,
                ),
              ]
            : null,
      ),
      body: _isProcessing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: AppDimensions.spacingL),
                  Text('Détection des mots en cours...'),
                ],
              ),
            )
          : _buildCurrentStep(),
    );
  }

  Widget _buildCurrentStep() {
    if (_imageFile == null) {
      return _buildCaptureStep();
    } else if (_currentStep == 2) {
      return _buildEditWordsStep();
    } else {
      return _buildPreviewStep();
    }
  }

  /// Step 1: Capture photo
  Widget _buildCaptureStep() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingXl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.camera_alt,
            size: 100,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppDimensions.spacingXl),
          const Text(
            'Prenez en photo une liste de mots',
            style: TextStyle(
              fontSize: AppTypography.headingMedium,
              fontWeight: AppTypography.semiBold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingM),
          const Text(
            'L\'application va détecter automatiquement les mots écrits sur la photo',
            style: TextStyle(
              fontSize: AppTypography.bodyMedium,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingXxl),
          AppButton(
            text: 'Prendre une photo',
            icon: const Icon(Icons.camera_alt),
            onPressed: () => _pickImage(fromCamera: true),
            isFullWidth: true,
          ),
          const SizedBox(height: AppDimensions.spacingM),
          OutlinedButton.icon(
            onPressed: () => _pickImage(fromCamera: false),
            icon: const Icon(Icons.photo_library),
            label: const Text('Choisir depuis la galerie'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(
                double.infinity,
                AppDimensions.buttonMinHeight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Step 2: Preview and crop
  Widget _buildPreviewStep() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: _imageFile != null
                ? Image.file(
                    _imageFile!,
                    fit: BoxFit.contain,
                  )
                : const SizedBox(),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                text: 'Recadrer la photo',
                icon: const Icon(Icons.crop),
                onPressed: _cropImage,
                isFullWidth: true,
              ),
              const SizedBox(height: AppDimensions.spacingM),
              AppButton(
                text: 'Détecter les mots',
                icon: const Icon(Icons.text_fields),
                onPressed: _recognizeText,
                isFullWidth: true,
              ),
              const SizedBox(height: AppDimensions.spacingM),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _imageFile = null;
                    _currentStep = 0;
                  });
                },
                icon: const Icon(Icons.close),
                label: const Text('Annuler'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(
                    double.infinity,
                    AppDimensions.buttonMinHeight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Step 3: Edit detected words
  Widget _buildEditWordsStep() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          color: AppColors.primary.withOpacity(0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_detectedWords.length} mots détectés',
                style: const TextStyle(
                  fontSize: AppTypography.headingMedium,
                  fontWeight: AppTypography.semiBold,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingS),
              const Text(
                'Vérifiez et corrigez si nécessaire',
                style: TextStyle(
                  fontSize: AppTypography.bodyMedium,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _detectedWords.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 64,
                        color: AppColors.warning,
                      ),
                      const SizedBox(height: AppDimensions.spacingL),
                      const Text(
                        'Aucun mot détecté',
                        style: TextStyle(
                          fontSize: AppTypography.headingMedium,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingM),
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: AppDimensions.paddingXl),
                        child: Text(
                          'Essayez de prendre une photo plus nette avec un bon éclairage',
                          style: TextStyle(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXl),
                      AppButton(
                        text: 'Réessayer',
                        icon: const Icon(Icons.camera_alt),
                        onPressed: () {
                          setState(() {
                            _imageFile = null;
                            _currentStep = 0;
                            _detectedWords = [];
                          });
                        },
                      ),
                    ],
                  ),
                )
              : ReorderableListView.builder(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  itemCount: _detectedWords.length + 1,
                  onReorder: _onReorder,
                  itemBuilder: (context, index) {
                    // Add button at the end
                    if (index == _detectedWords.length) {
                      return ListTile(
                        key: const ValueKey('add_button'),
                        leading: const Icon(Icons.add_circle_outline),
                        title: const Text('Ajouter un mot'),
                        onTap: _addNewWord,
                      );
                    }

                    // Ensure we have a controller for this index
                    while (_wordControllers.length <= index) {
                      _wordControllers.add(TextEditingController());
                    }

                    if (_wordControllers[index].text.isEmpty) {
                      _wordControllers[index].text = _detectedWords[index];
                    }

                    return ListTile(
                      key: ValueKey(_detectedWords[index] + index.toString()),
                      leading: const Icon(Icons.drag_handle),
                      title: TextField(
                        controller: _wordControllers[index],
                        decoration: const InputDecoration(
                          hintText: 'Mot',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          _detectedWords[index] = value;
                        },
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: AppColors.error,
                        onPressed: () => _removeWord(index),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _pickImage({required bool fromCamera}) async {
    final ocrService = ref.read(ocrServiceProvider);
    final image = await ocrService.pickImage(fromCamera: fromCamera);

    if (image != null) {
      setState(() {
        _imageFile = image;
        _currentStep = 1;
      });
    }
  }

  Future<void> _cropImage() async {
    if (_imageFile == null) return;

    final ocrService = ref.read(ocrServiceProvider);
    final croppedImage = await ocrService.cropImage(_imageFile!.path);

    if (croppedImage != null) {
      setState(() {
        _imageFile = croppedImage;
      });
    }
  }

  Future<void> _recognizeText() async {
    if (_imageFile == null) return;

    setState(() => _isProcessing = true);

    try {
      final ocrService = ref.read(ocrServiceProvider);
      final words = await ocrService.recognizeText(_imageFile!);

      setState(() {
        _detectedWords = words;
        _currentStep = 2;
        _isProcessing = false;

        // Reset controllers
        for (final controller in _wordControllers) {
          controller.dispose();
        }
        _wordControllers.clear();
      });
    } catch (e) {
      setState(() => _isProcessing = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la détection: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final word = _detectedWords.removeAt(oldIndex);
      _detectedWords.insert(newIndex, word);

      final controller = _wordControllers.removeAt(oldIndex);
      _wordControllers.insert(newIndex, controller);
    });
  }

  void _addNewWord() {
    setState(() {
      _detectedWords.add('');
      _wordControllers.add(TextEditingController());
    });
  }

  void _removeWord(int index) {
    setState(() {
      _detectedWords.removeAt(index);
      _wordControllers[index].dispose();
      _wordControllers.removeAt(index);
    });
  }

  void _saveWords() {
    // Get final words from controllers
    final finalWords = _wordControllers
        .map((c) => c.text.trim())
        .where((w) => w.isNotEmpty)
        .toList();

    if (finalWords.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez ajouter au moins un mot'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Return the words to the previous screen
    Navigator.pop(context, finalWords);
  }
}
