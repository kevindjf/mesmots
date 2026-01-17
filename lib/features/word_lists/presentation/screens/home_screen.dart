import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/features/word_lists/presentation/providers/word_list_providers.dart';
import 'package:mesmots/features/word_lists/presentation/widgets/word_list_card.dart';
import 'package:mesmots/features/word_lists/presentation/screens/list_edit_screen.dart';
import 'package:mesmots/features/parental/presentation/providers/parental_providers.dart';
import 'package:mesmots/features/parental/presentation/widgets/pin_input_dialog.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordListsAsync = ref.watch(wordListsProvider);
    final parentalSettings = ref.watch(parentalSettingsProvider);
    final isParentalMode = ref.watch(parentalModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text(AppStrings.appEmoji),
            const SizedBox(width: AppDimensions.spacingS),
            const Text(AppStrings.appName),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              isParentalMode ? Icons.lock_open : Icons.lock_outline,
              color: isParentalMode ? AppColors.success : AppColors.textPrimary,
            ),
            onPressed: () => _handleParentalMode(context, ref, parentalSettings),
          ),
        ],
      ),
      body: wordListsAsync.when(
        data: (lists) => _buildContent(context, ref, lists, isParentalMode),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('${AppStrings.errorLoadingLists}: $error'),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List lists,
    bool isParentalMode,
  ) {
    // Sort lists: active first, then completed
    final activeLists = lists.where((list) => !list.isFullyCompleted).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    final completedLists =
        lists.where((list) => list.isFullyCompleted).toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    if (lists.isEmpty) {
      return _buildEmptyState(context, ref, isParentalMode);
    }

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      children: [
        // Active lists
        if (activeLists.isNotEmpty) ...[
          ...activeLists.map((list) => WordListCard(wordList: list)),
          const SizedBox(height: AppDimensions.spacingL),
        ],

        // Completed lists section
        if (completedLists.isNotEmpty) ...[
          const Text(
            AppStrings.previousLists,
            style: TextStyle(
              fontSize: AppTypography.headingSmall,
              fontWeight: AppTypography.semiBold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          ...completedLists.map((list) => WordListCard(wordList: list)),
          const SizedBox(height: AppDimensions.spacingL),
        ],

        // Add new list button (only in parental mode)
        if (isParentalMode)
          _buildAddListButton(context)
        else
          _buildLockedAddButton(context, ref),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    WidgetRef ref,
    bool isParentalMode,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.book_outlined,
              size: 80,
              color: AppColors.textLight,
            ),
            const SizedBox(height: AppDimensions.spacingXl),
            const Text(
              'Aucune liste de mots',
              style: TextStyle(
                fontSize: AppTypography.headingMedium,
                fontWeight: AppTypography.semiBold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            const Text(
              'Demande à un adulte de créer ta première liste !',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppTypography.bodyLarge,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXxl),
            if (isParentalMode) _buildAddListButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAddListButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ListEditScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primary,
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: AppColors.primary),
            const SizedBox(width: AppDimensions.spacingM),
            Text(
              AppStrings.newList,
              style: const TextStyle(
                fontSize: AppTypography.bodyLarge,
                fontWeight: AppTypography.semiBold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedAddButton(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demande à un adulte pour créer une liste'),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.textLight,
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: AppColors.textLight),
            const SizedBox(width: AppDimensions.spacingM),
            Text(
              AppStrings.newList,
              style: const TextStyle(
                fontSize: AppTypography.bodyLarge,
                fontWeight: AppTypography.semiBold,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingS),
            const Icon(Icons.lock_outline, size: 20, color: AppColors.textLight),
          ],
        ),
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
      // Deactivate parental mode
      ref.read(parentalModeProvider.notifier).deactivate();
      return;
    }

    // Need to activate - check if PIN is configured
    parentalSettingsAsync.whenData((settings) async {
      if (!settings.isPinConfigured) {
        // TODO: Navigate to PIN setup screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configure le code PIN d\'abord'),
          ),
        );
        return;
      }

      // Show PIN dialog
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => const PinInputDialog(),
      );

      if (result == true) {
        ref.read(parentalModeProvider.notifier).activate();
      }
    });
  }
}
