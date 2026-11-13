import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/features/word_lists/domain/entities/game_type.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_list.dart';
import 'package:mesmots/features/word_lists/presentation/providers/word_list_providers.dart';
import 'package:mesmots/features/word_lists/presentation/widgets/game_toggle_tile.dart';
import 'package:mesmots/shared/widgets/app_input.dart';
import 'package:mesmots/shared/widgets/circle_icon_button.dart';
import 'package:mesmots/core/utils/string_utils.dart';
import 'package:mesmots/shared/widgets/colorful_button.dart';
import 'package:mesmots/shared/widgets/gradient_background.dart';

class ListEditScreen extends ConsumerStatefulWidget {
  final String? listId;

  const ListEditScreen({
    super.key,
    this.listId,
  });

  @override
  ConsumerState<ListEditScreen> createState() => _ListEditScreenState();
}

class _ListEditScreenState extends ConsumerState<ListEditScreen> {
  final _nameController = TextEditingController();
  final _wordController = TextEditingController();
  final _wordFocusNode = FocusNode();
  final List<String> _words = [];
  final Set<GameType> _enabledGames = {...WordList.allGames};
  bool _isLoading = false;
  bool _dataLoaded = false;

  bool get _isEditing => widget.listId != null;

  @override
  void dispose() {
    _nameController.dispose();
    _wordController.dispose();
    _wordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Load existing list data if editing
    if (_isEditing && !_dataLoaded) {
      final wordListAsync = ref.watch(wordListProvider(widget.listId!));
      wordListAsync.whenData((wordList) {
        if (wordList != null && !_dataLoaded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_dataLoaded) {
              _nameController.text = wordList.name;
              setState(() {
                _words.addAll(wordList.words);
                _enabledGames
                  ..clear()
                  ..addAll(wordList.enabledGames);
                _dataLoaded = true;
              });
            }
          });
        }
      });
    }

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  children: [
                    // List name input
                    AppInput(
                      controller: _nameController,
                      hintText: 'Nom de la liste (ex: Semaine 1)',
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: AppDimensions.spacingXl),

                    // Word input section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: AppInput(
                            controller: _wordController,
                            focusNode: _wordFocusNode,
                            hintText: 'Ajouter un mot...',
                            onSubmitted: (_) => _addWord(),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spacingM),
                        ColorfulIconButton(
                          icon: Icons.add,
                          onTap: _addWord,
                          color: AppColors.success,
                          shadowColor: const Color(0xFF3D8B40),
                          size: 56,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingL),

                    // Words list
                    if (_words.isNotEmpty) ...[
                      _buildWordsHeader(),
                      const SizedBox(height: AppDimensions.spacingM),
                      _buildWordsList(),
                    ],

                    const SizedBox(height: AppDimensions.spacingXl),
                    _buildAllowedGames(),
                    const SizedBox(height: AppDimensions.spacingXl),

                    // Save button
                    if (_words.isNotEmpty)
                      ColorfulButton.orange(
                        text: _isEditing ? 'Enregistrer' : 'Créer la liste',
                        icon: Icons.check,
                        width: double.infinity,
                        onTap: _isLoading ? null : _saveList,
                      ),
                    const SizedBox(height: AppDimensions.spacingXxl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.paddingM,
      ),
      child: Row(
        children: [
          CircleIconButton.surface(
            icon: Icons.arrow_back,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Text(
              _isEditing ? 'Modifier la liste' : 'Nouvelle liste',
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: AppTypography.headingMedium,
                fontWeight: AppTypography.bold,
                color: AppColors.textOnColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllowedGames() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.allowedGames,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: AppTypography.bodySmall,
            fontWeight: AppTypography.bold,
            color: AppColors.textOnColor,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        Text(
          AppStrings.allowedGamesHint,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: AppTypography.bodySmall,
            fontWeight: AppTypography.semiBold,
            color: AppColors.textOnColor.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingM),
        for (final type in GameType.values)
          GameToggleTile(
            type: type,
            isEnabled: _enabledGames.contains(type),
            onChanged: (enabled) => _toggleGame(type, enabled),
          ),
      ],
    );
  }

  void _toggleGame(GameType type, bool enabled) {
    if (!enabled && _enabledGames.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.atLeastOneGame),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() {
      enabled ? _enabledGames.add(type) : _enabledGames.remove(type);
    });
  }

  Widget _buildWordsHeader() {
    return Row(
      children: [
        Text(
          '${_words.length} mot${_words.length > 1 ? 's' : ''}',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: AppTypography.bodyMedium,
            fontWeight: AppTypography.bold,
            color: AppColors.textOnColor.withValues(alpha: 0.9),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: _clearAllWords,
          child: Text(
            'Tout effacer',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: AppTypography.bodySmall,
              fontWeight: AppTypography.semiBold,
              color: AppColors.textOnColor.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWordsList() {
    return Column(
      children: _words.asMap().entries.map((entry) {
        final index = entry.key;
        final word = entry.value;
        return _WordItem(
          word: word,
          colorIndex: index,
          onDelete: () => _removeWord(index),
        );
      }).toList(),
    );
  }

  void _addWord() {
    final word = _wordController.text.trim().toLowerCase().nfc;
    if (word.isNotEmpty && !_words.contains(word)) {
      setState(() {
        _words.add(word);
      });
      _wordController.clear();
      _wordFocusNode.requestFocus();
    }
  }

  void _removeWord(int index) {
    setState(() {
      _words.removeAt(index);
    });
  }

  void _clearAllWords() {
    setState(() {
      _words.clear();
    });
  }

  Future<void> _saveList() async {
    if (_isLoading) return;

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Entre un nom pour la liste'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_words.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ajoute au moins un mot'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final operations = ref.read(wordListOperationsProvider.notifier);

      if (_isEditing) {
        await operations.updateList(
          id: widget.listId!,
          name: name,
          words: _words,
          enabledGames: _enabledGames,
        );
      } else {
        await operations.createList(
          name: name,
          words: _words,
          enabledGames: _enabledGames,
        );
      }

      if (mounted) {
        final message = _isEditing
            ? 'Liste modifiée avec succès'
            : 'Liste créée avec succès';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.errorSavingList}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

/// Word item with delete button
class _WordItem extends StatefulWidget {
  final String word;
  final int colorIndex;
  final VoidCallback onDelete;

  const _WordItem({
    required this.word,
    required this.colorIndex,
    required this.onDelete,
  });

  @override
  State<_WordItem> createState() => _WordItemState();
}

class _WordItemState extends State<_WordItem> {
  bool _isPressed = false;

  static const _colors = [
    (AppColors.buttonOrange, AppColors.buttonOrangeShadow),
    (AppColors.buttonPink, AppColors.buttonPinkShadow),
    (AppColors.buttonBlue, AppColors.buttonBlueShadow),
    (AppColors.buttonMagenta, AppColors.buttonMagentaShadow),
    (AppColors.buttonCoral, AppColors.buttonCoralShadow),
  ];

  @override
  Widget build(BuildContext context) {
    final colorPair = _colors[widget.colorIndex % _colors.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(0, _isPressed ? 2 : 0, 0),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingL,
          vertical: AppDimensions.paddingM,
        ),
        decoration: BoxDecoration(
          color: colorPair.$1,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          boxShadow: [
            BoxShadow(
              color: colorPair.$2,
              blurRadius: 0,
              offset: Offset(0, _isPressed ? 2 : 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.word,
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: AppTypography.headingSmall,
                  fontWeight: AppTypography.bold,
                  color: AppColors.textOnColor,
                ),
              ),
            ),
            GestureDetector(
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) {
                setState(() => _isPressed = false);
                widget.onDelete();
              },
              onTapCancel: () => setState(() => _isPressed = false),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.textOnColor.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.close,
                  color: AppColors.textOnColor,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
