import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jerevise/core/constants/app_colors.dart';
import 'package:jerevise/core/constants/app_dimensions.dart';
import 'package:jerevise/core/constants/app_strings.dart';
import 'package:jerevise/core/constants/app_typography.dart';
import 'package:jerevise/features/word_lists/domain/entities/game_level.dart';
import 'package:jerevise/features/word_lists/presentation/providers/word_list_providers.dart';
import 'package:jerevise/features/word_lists/presentation/widgets/level_card.dart';
import 'package:jerevise/features/parental/presentation/providers/parental_providers.dart';
import 'package:jerevise/features/parental/presentation/widgets/pin_input_dialog.dart';
import 'package:jerevise/features/word_lists/presentation/screens/list_edit_screen.dart';
import 'package:jerevise/shared/widgets/app_header.dart';
import 'package:jerevise/shared/widgets/circle_icon_button.dart';
import 'package:jerevise/shared/widgets/colorful_button.dart';
import 'package:jerevise/shared/widgets/gradient_background.dart';

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
    final parentalSettings = ref.watch(parentalSettingsProvider);

    return wordListAsync.when(
      data: (wordList) {
        if (wordList == null) {
          return Scaffold(
            body: GradientBackground(
              child: SafeArea(
                child: Column(
                  children: [
                    _buildHeader(context, 'Liste', isParentalMode, parentalSettings, ref),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Liste non trouvée',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: AppTypography.bodyLarge,
                            color: AppColors.textOnColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          body: GradientBackground(
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(context, wordList.name, isParentalMode, parentalSettings, ref),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      children: [
                        // List info badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingM,
                            vertical: AppDimensions.paddingS,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.textOnColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.menu_book, color: AppColors.textOnColor, size: 18),
                              const SizedBox(width: AppDimensions.spacingS),
                              Text(
                                '${wordList.words.length} ${AppStrings.words}',
                                style: const TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: AppTypography.bodyMedium,
                                  fontWeight: AppTypography.semiBold,
                                  color: AppColors.textOnColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingXl),

                        const Text(
                          'CHOISIS TON ENTRAÎNEMENT',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: AppTypography.bodySmall,
                            fontWeight: AppTypography.bold,
                            color: AppColors.textOnColor,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingL),

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

                        const SizedBox(height: AppDimensions.spacingL),

                        // View words button
                        ColorfulButton(
                          text: AppStrings.viewWords,
                          icon: Icons.list,
                          color: AppColors.surface,
                          shadowColor: AppColors.primaryDark,
                          textColor: AppColors.primary,
                          width: double.infinity,
                          onTap: () => _showWordsDialog(context, wordList.words),
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
      },
      loading: () => const Scaffold(
        body: GradientBackground(
          child: Center(child: CircularProgressIndicator(color: AppColors.textOnColor)),
        ),
      ),
      error: (error, stack) => Scaffold(
        body: GradientBackground(
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, 'Erreur', false, parentalSettings, ref),
                Expanded(
                  child: Center(
                    child: Text(
                      'Erreur: $error',
                      style: const TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        color: AppColors.textOnColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title, bool isParentalMode, AsyncValue<dynamic> parentalSettings, WidgetRef ref) {
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
              title,
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: AppTypography.headingMedium,
                fontWeight: AppTypography.bold,
                color: AppColors.textOnColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isParentalMode) ...[
            CircleIconButton.colored(
              icon: Icons.edit,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListEditScreen(listId: listId),
                  ),
                );
              },
              color: AppColors.buttonBlue,
              shadowColor: AppColors.buttonBlueShadow,
            ),
            const SizedBox(width: AppDimensions.spacingS),
            CircleIconButton.colored(
              icon: Icons.delete,
              onTap: () => _confirmDelete(context, ref),
              color: AppColors.buttonCoral,
              shadowColor: AppColors.buttonCoralShadow,
            ),
            const SizedBox(width: AppDimensions.spacingS),
          ],
          LockIconButton(
            isUnlocked: isParentalMode,
            onTap: () => _handleParentalMode(context, ref, parentalSettings),
          ),
        ],
      ),
    );
  }

  Future<void> _handleParentalMode(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<dynamic> parentalSettingsAsync,
  ) async {
    final isParentalMode = ref.read(parentalModeProvider);

    if (isParentalMode) {
      ref.read(parentalModeProvider.notifier).deactivate();
      return;
    }

    parentalSettingsAsync.whenData((settings) async {
      if (!settings.isPinConfigured) {
        return;
      }

      final result = await showDialog<bool>(
        context: context,
        builder: (context) => const PinInputDialog(),
      );

      if (result == true) {
        ref.read(parentalModeProvider.notifier).activate();
      }
    });
  }

  void _showWordsDialog(BuildContext context, List<String> words) {
    final colors = [
      AppColors.buttonOrange,
      AppColors.buttonPink,
      AppColors.buttonBlue,
      AppColors.buttonMagenta,
      AppColors.buttonCoral,
    ];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
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
                  fontFamily: AppTypography.fontFamily,
                  fontSize: AppTypography.headingMedium,
                  fontWeight: AppTypography.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingL),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: AppDimensions.spacingS,
                    runSpacing: AppDimensions.spacingS,
                    children: words.asMap().entries.map((entry) {
                      final color = colors[entry.key % colors.length];
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingM,
                          vertical: AppDimensions.paddingS,
                        ),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                        ),
                        child: Text(
                          entry.value,
                          style: const TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: AppTypography.bodyMedium,
                            fontWeight: AppTypography.semiBold,
                            color: AppColors.textOnColor,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.spacingL),
              ColorfulButton(
                text: AppStrings.close,
                color: AppColors.primary,
                shadowColor: AppColors.primaryDark,
                width: double.infinity,
                onTap: () => Navigator.pop(context),
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
      builder: (context) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline, color: AppColors.error, size: 32),
              ),
              const SizedBox(height: AppDimensions.spacingL),
              const Text(
                AppStrings.deleteList,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: AppTypography.headingMedium,
                  fontWeight: AppTypography.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingS),
              const Text(
                AppStrings.confirmDelete,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: AppTypography.bodyMedium,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingXl),
              Row(
                children: [
                  Expanded(
                    child: ColorfulButton(
                      text: AppStrings.cancel,
                      color: AppColors.surface,
                      shadowColor: AppColors.primaryDark,
                      textColor: AppColors.primary,
                      onTap: () => Navigator.pop(context, false),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingM),
                  Expanded(
                    child: ColorfulButton.coral(
                      text: AppStrings.delete,
                      onTap: () => Navigator.pop(context, true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
