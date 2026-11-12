import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/features/parental/presentation/screens/parent_space_screen.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_list.dart';
import 'package:mesmots/features/word_lists/presentation/providers/word_list_providers.dart';
import 'package:mesmots/features/word_lists/presentation/widgets/word_list_card.dart';
import 'package:mesmots/shared/widgets/app_header.dart';
import 'package:mesmots/shared/widgets/gradient_background.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordListsAsync = ref.watch(wordListsProvider);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              AppHeader(
                title: AppStrings.appName,
                subtitle: 'MES MOTS DE DICTÉE',
                trailing: LockIconButton(
                  onTap: () => ParentSpaceScreen.open(context),
                ),
              ),

              // Content
              Expanded(
                child: wordListsAsync.when(
                  data: (lists) => _buildContent(lists),
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
    );
  }

  Widget _buildContent(List<WordList> lists) {
    // Sort lists: active first, then completed
    final activeLists = lists.where((list) => !list.isMastered).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    final completedLists = lists.where((list) => list.isMastered).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      children: [
        // Mascot section
        const SizedBox(height: AppDimensions.spacingL),

        // Word lists
        if (lists.isEmpty)
          _buildEmptyState()
        else ...[
          // Active lists
          if (activeLists.isNotEmpty) ...[
            for (int i = 0; i < activeLists.length; i++)
              WordListCard(wordList: activeLists[i], colorIndex: i),
          ],

          // Completed lists section
          if (completedLists.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingL),
            const Text(
              AppStrings.previousLists,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: AppTypography.bodyMedium,
                fontWeight: AppTypography.bold,
                color: AppColors.textOnColor,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            for (int i = 0; i < completedLists.length; i++)
              WordListCard(
                  wordList: completedLists[i],
                  colorIndex: i + activeLists.length),
          ],
        ],

        const SizedBox(height: AppDimensions.spacingXxl),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        const SizedBox(height: AppDimensions.spacingXxl),
        // Cute book emoji container
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.shapeLight,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
          ),
          child: const Center(
            child: Icon(
              Icons.menu_book,
              size: 48,
              color: AppColors.textOnColor,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingL),
        const Text(
          'Aucune liste de mots',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: AppTypography.headingSmall,
            fontWeight: AppTypography.bold,
            color: AppColors.textOnColor,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        Text(
          AppStrings.askAdultForList,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: AppTypography.bodyMedium,
            color: AppColors.textOnColor.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
