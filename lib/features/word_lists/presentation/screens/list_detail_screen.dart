import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/features/games/domain/usecases/generate_crossword.dart';
import 'package:mesmots/features/games/presentation/extensions/game_type_presentation.dart';
import 'package:mesmots/features/word_lists/domain/entities/game_type.dart';
import 'package:mesmots/features/word_lists/presentation/providers/word_list_providers.dart';
import 'package:mesmots/features/word_lists/presentation/widgets/game_tile.dart';
import 'package:mesmots/features/word_lists/presentation/widgets/word_mastery_chip.dart';
import 'package:mesmots/features/parental/presentation/providers/parental_providers.dart';
import 'package:mesmots/features/parental/presentation/widgets/pin_input_dialog.dart';
import 'package:mesmots/features/word_lists/presentation/screens/list_edit_screen.dart';
import 'package:mesmots/shared/widgets/app_header.dart';
import 'package:mesmots/shared/widgets/circle_icon_button.dart';
import 'package:mesmots/shared/widgets/colorful_button.dart';
import 'package:mesmots/shared/widgets/gradient_background.dart';

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

                        const _SectionTitle(AppStrings.chooseGame),
                        const SizedBox(height: AppDimensions.spacingL),
                        GridView.count(
                          crossAxisCount:
                              MediaQuery.sizeOf(context).width >= 600 ? 3 : 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: AppDimensions.spacingL,
                          crossAxisSpacing: AppDimensions.spacingL,
                          childAspectRatio: 0.82,
                          children: [
                            for (final type in GameType.values)
                              GameTile(
                                type: type,
                                playCount: wordList.playCountOf(type),
                                unavailableReason:
                                    AppStrings.crosswordUnavailable,
                                onTap: type == GameType.crossword &&
                                        !_canPlayCrossword(wordList.words)
                                    ? null
                                    : () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                type.buildScreen(listId),
                                          ),
                                        ),
                              ),
                          ],
                        ),

                        const SizedBox(height: AppDimensions.spacingXl),
                        _SectionTitle(
                          '${AppStrings.myWords} • ${wordList.masteredCount}/${wordList.words.length} ${AppStrings.masteredWords}',
                        ),
                        const SizedBox(height: AppDimensions.spacingL),
                        Wrap(
                          spacing: AppDimensions.spacingS,
                          runSpacing: AppDimensions.spacingM,
                          children: [
                            for (final word in wordList.words)
                              WordMasteryChip(
                                word: word,
                                status: wordList.statusOf(word),
                              ),
                          ],
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

  /// Whether the words cross into a playable crossword (deterministic check)
  bool _canPlayCrossword(List<String> words) =>
      GenerateCrossword(random: Random(0))(words).isPlayable;

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

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: AppTypography.bodySmall,
        fontWeight: AppTypography.bold,
        color: AppColors.textOnColor,
        letterSpacing: 1.0,
      ),
    );
  }
}
