import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmots/core/extensions/palette_context.dart';
import 'package:mesmots/core/constants/app_breakpoints.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/features/games/domain/usecases/generate_crossword.dart';
import 'package:mesmots/features/games/presentation/extensions/game_type_presentation.dart';
import 'package:mesmots/features/word_lists/domain/entities/game_type.dart';
import 'package:mesmots/features/word_lists/presentation/providers/word_list_providers.dart';
import 'package:mesmots/features/word_lists/presentation/widgets/game_tile.dart';
import 'package:mesmots/features/word_lists/presentation/widgets/word_list_panel.dart';
import 'package:mesmots/shared/widgets/bounded_content.dart';
import 'package:mesmots/shared/widgets/circle_icon_button.dart';
import 'package:mesmots/shared/widgets/gradient_background.dart';
import 'package:mesmots/shared/widgets/section_title.dart';

class ListDetailScreen extends ConsumerWidget {
  final String listId;

  const ListDetailScreen({
    super.key,
    required this.listId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordListAsync = ref.watch(wordListProvider(listId));

    return wordListAsync.when(
      data: (wordList) {
        if (wordList == null) {
          return Scaffold(
            body: GradientBackground(
              child: SafeArea(
                child: Column(
                  children: [
                    _buildHeader(context, 'Liste'),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Liste non trouvée',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: AppTypography.bodyLarge,
                            color: context.palette.onBackground,
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
              child: BoundedContent.wide(
                child: Column(
                  children: [
                    _buildHeader(context, wordList.name),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(AppDimensions.paddingL),
                        children: [
                          WordListPanel(wordList: wordList),
                          const SizedBox(height: AppDimensions.spacingXl),

                          const SectionTitle(AppStrings.chooseGame),
                          const SizedBox(height: AppDimensions.spacingL),
                          // One game per row; two or three columns on tablets.
                          LayoutBuilder(
                            builder: (context, constraints) => GridView(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: AppBreakpoints.columnsFor(
                                  constraints.maxWidth,
                                  spacing: AppDimensions.spacingL,
                                ),
                                mainAxisSpacing: AppDimensions.spacingL,
                                crossAxisSpacing: AppDimensions.spacingL,
                                mainAxisExtent: AppDimensions.gameTileHeight,
                              ),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                for (final type in wordList.availableGames)
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
                          ),

                          const SizedBox(height: AppDimensions.spacingXxl),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        body: GradientBackground(
          child: Center(
              child: CircularProgressIndicator(
                  color: context.palette.onBackground)),
        ),
      ),
      error: (error, stack) => Scaffold(
        body: GradientBackground(
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, 'Erreur'),
                Expanded(
                  child: Center(
                    child: Text(
                      'Erreur: $error',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        color: context.palette.onBackground,
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

  Widget _buildHeader(BuildContext context, String title) {
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
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: AppTypography.headingMedium,
                fontWeight: AppTypography.bold,
                color: context.palette.onBackground,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Whether the words cross into a playable crossword (deterministic check)
  bool _canPlayCrossword(List<String> words) =>
      GenerateCrossword(random: Random(0))(words).isPlayable;
}
