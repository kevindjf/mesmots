import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/features/word_lists/presentation/providers/word_list_providers.dart';
import 'package:mesmots/shared/widgets/app_button.dart';

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
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _wordsController = TextEditingController();
  bool _isLoading = false;

  bool get _isEditing => widget.listId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadExistingList();
    }
  }

  Future<void> _loadExistingList() async {
    final repository = ref.read(wordListRepositoryProvider);
    final wordList = await repository.getById(widget.listId!);

    if (wordList != null) {
      _nameController.text = wordList.name;
      _wordsController.text = wordList.words.join('\n');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _wordsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? AppStrings.editList : AppStrings.createList),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: AppStrings.listName,
                hintText: 'Semaine du 20 janvier',
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.errorEmptyListName;
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.spacingXl),
            TextFormField(
              controller: _wordsController,
              decoration: const InputDecoration(
                labelText: AppStrings.addWords,
                hintText: 'maison\nchien\nchat\n...',
                alignLabelWithHint: true,
              ),
              maxLines: 15,
              textCapitalization: TextCapitalization.none,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.errorEmptyWords;
                }
                final words = _parseWords(value);
                if (words.isEmpty) {
                  return AppStrings.errorEmptyWords;
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.spacingXl),
            AppButton(
              text: _isEditing ? AppStrings.save : AppStrings.createList,
              onPressed: _isLoading ? null : _saveList,
              isLoading: _isLoading,
              isFullWidth: true,
            ),
            if (_isEditing) ...[
              const SizedBox(height: AppDimensions.spacingM),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(
                    double.infinity,
                    AppDimensions.buttonMinHeight,
                  ),
                ),
                child: const Text(AppStrings.cancel),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<String> _parseWords(String input) {
    return input
        .split('\n')
        .map((w) => w.trim())
        .where((w) => w.isNotEmpty)
        .toList();
  }

  Future<void> _saveList() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      final words = _parseWords(_wordsController.text);

      final operations = ref.read(wordListOperationsProvider.notifier);

      if (_isEditing) {
        await operations.updateList(
          id: widget.listId!,
          name: name,
          words: words,
        );
      } else {
        await operations.createList(
          name: name,
          words: words,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Liste modifiée avec succès'
                  : 'Liste créée avec succès',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.errorSavingList}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
