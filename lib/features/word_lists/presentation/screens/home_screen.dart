import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmots/core/extensions/palette_context.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/features/parental/presentation/screens/parent_space_screen.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_list.dart';
import 'package:mesmots/features/word_lists/presentation/providers/word_list_providers.dart';
import 'package:mesmots/features/word_lists/presentation/widgets/word_list_card.dart';
import 'package:mesmots/shared/widgets/adaptive_grid.dart';
import 'package:mesmots/shared/widgets/bounded_content.dart';
import 'package:mesmots/shared/widgets/letter_tiles_title.dart';
import 'package:mesmots/shared/widgets/gradient_background.dart';
import 'package:mesmots/shared/widgets/parent_space_button.dart';
import 'package:mesmots/shared/widgets/section_title.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordListsAsync = ref.watch(wordListsProvider);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: BoundedContent.wide(
            child: Column(
              children: [
                // Header: the app name in letter tiles that drop in, then wave
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingL,
                    vertical: AppDimensions.paddingM,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          // "MES MOTS": the space puts MOTS on a second row.
                          child: LetterTilesTitle(
                            text: AppStrings.welcomeTiles,
                            tileSize: 36,
                            rowAlignment: CrossAxisAlignment.start,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacingM),
                      ParentSpaceButton(
                        onTap: () => ParentSpaceScreen.open(context),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: wordListsAsync.when(
                    data: (lists) => _buildContent(context, lists),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(
                      child: Text('${AppStrings.errorLoadingLists}: $error'),
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

  Widget _buildContent(BuildContext context, List<WordList> lists) {
    // Last played first, then never played ones, newest first.
    final sorted = [...lists]..sort(_byLastPlayed);
    final current = sorted.isNotEmpty && sorted.first.lastPlayedAt != null
        ? sorted.first
        : null;
    final others = current == null ? sorted : sorted.sublist(1);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      children: [
        const SizedBox(height: AppDimensions.spacingL),
        if (sorted.isEmpty) _buildEmptyState(context),
        if (current != null) ...[
          const SectionTitle(AppStrings.currentList),
          const SizedBox(height: AppDimensions.spacingM),
          WordListCard(wordList: current),
          if (others.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingS),
            const SectionTitle(AppStrings.otherLists),
            const SizedBox(height: AppDimensions.spacingM),
          ],
        ],
        // Before any game, every list goes under one title.
        if (current == null && others.isNotEmpty) ...[
          const SectionTitle(AppStrings.yourLists),
          const SizedBox(height: AppDimensions.spacingM),
        ],
        // One list per row; two or three columns on tablets.
        AdaptiveGrid(
          spacing: AppDimensions.spacingL,
          children: [
            for (var i = 0; i < others.length; i++)
              WordListCard(
                wordList: others[i],
                colorIndex: current == null ? i : i + 1,
              ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingXxl),
      ],
    );
  }

  static int _byLastPlayed(WordList a, WordList b) {
    final playedA = a.lastPlayedAt;
    final playedB = b.lastPlayedAt;
    if (playedA != null && playedB != null) return playedB.compareTo(playedA);
    if (playedA != null) return -1;
    if (playedB != null) return 1;
    return b.createdAt.compareTo(a.createdAt);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppDimensions.spacingXxl),
        // Cute book emoji container
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: context.palette.onBackground.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
          ),
          child: Center(
            child: Icon(
              Icons.menu_book,
              size: 48,
              color: context.palette.onBackground,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingL),
        Text(
          'Aucune liste de mots',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: AppTypography.headingSmall,
            fontWeight: AppTypography.bold,
            color: context.palette.onBackground,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        Text(
          AppStrings.askAdultForList,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: AppTypography.bodyMedium,
            color: context.palette.onBackground.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
