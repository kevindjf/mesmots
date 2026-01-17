import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/features/word_lists/domain/entities/game_level.dart';
import 'package:mesmots/features/word_lists/presentation/providers/word_list_providers.dart';
import 'package:mesmots/features/word_lists/presentation/widgets/level_card.dart';
import 'package:mesmots/features/parental/presentation/providers/parental_providers.dart';
import 'package:mesmots/features/word_lists/presentation/screens/list_edit_screen.dart';

class ListDetailScreen extends ConsumerWidget {
  final String listId;

  const ListDetailScreen({
    super.key,
    required this.listId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordListAsync = ref.watch(wordListProvider(listId));
    final isParentalMode = ref.watch(parentalModeProvider);

    return wordListAsync.when(
      data: (wordList) {
        if (wordList == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: Text('Liste non trouvée'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(wordList.name),
            actions: isParentalMode
                ? [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ListEditScreen(listId: listId),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _confirmDelete(context, ref),
                    ),
                  ]
                : null,
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            children: [
              // List info
              Text(
                '${wordList.words.length} ${AppStrings.words}',
                style: const TextStyle(
                  fontSize: AppTypography.bodyLarge,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingXl),

              // Level cards
              ...GameLevel.values.map((level) {
                final progress = wordList.progress[level]!;
                final isUnlocked = wordList.isLevelUnlocked(level);

                return LevelCard(
                  level: level,
                  progress: progress,
                  isUnlocked: isUnlocked,
                  listId: listId,
                );
              }),

              const SizedBox(height: AppDimensions.spacingXl),

              // View words button
              OutlinedButton.icon(
                onPressed: () {
                  _showWordsDialog(context, wordList.words);
                },
                icon: const Icon(Icons.list),
                label: const Text(AppStrings.viewWords),
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
      },
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Erreur: $error')),
      ),
    );
  }

  void _showWordsDialog(BuildContext context, List<String> words) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Liste des mots',
                style: TextStyle(
                  fontSize: AppTypography.headingMedium,
                  fontWeight: AppTypography.semiBold,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingL),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: AppDimensions.spacingS,
                    runSpacing: AppDimensions.spacingS,
                    children: words.map((word) {
                      return Chip(
                        label: Text(word),
                        backgroundColor: AppColors.cardBackground,
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.spacingL),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(AppStrings.close),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteList),
        content: const Text(AppStrings.confirmDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(wordListOperationsProvider.notifier).deleteList(listId);
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }
}
