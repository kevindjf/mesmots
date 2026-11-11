import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jerevise/core/constants/app_colors.dart';
import 'package:jerevise/core/constants/app_dimensions.dart';
import 'package:jerevise/core/constants/app_strings.dart';
import 'package:jerevise/core/constants/app_typography.dart';
import 'package:jerevise/features/parental/presentation/providers/parental_providers.dart';
import 'package:jerevise/features/parental/presentation/widgets/pin_input_dialog.dart';
import 'package:jerevise/features/word_lists/presentation/providers/word_list_providers.dart';
import 'package:jerevise/features/word_lists/presentation/screens/list_edit_screen.dart';
import 'package:jerevise/features/word_lists/presentation/widgets/word_list_card.dart';
import 'package:jerevise/shared/widgets/app_header.dart';
import 'package:jerevise/shared/widgets/dashed_border_button.dart';
import 'package:jerevise/shared/widgets/gradient_background.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordListsAsync = ref.watch(wordListsProvider);
    final parentalSettings = ref.watch(parentalSettingsProvider);
    final isParentalMode = ref.watch(parentalModeProvider);

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
                  isUnlocked: isParentalMode,
                  onTap: () =>
                      _handleParentalMode(context, ref, parentalSettings),
                ),
              ),

              // Content
              Expanded(
                child: wordListsAsync.when(
                  data: (lists) =>
                      _buildContent(context, ref, lists, isParentalMode),
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

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List lists,
    bool isParentalMode,
  ) {
    // Sort lists: active first, then completed
    final activeLists = lists.where((list) => !list.isFullyCompleted).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    final completedLists = lists.where((list) => list.isFullyCompleted).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      children: [
        // Mascot section
        const SizedBox(height: AppDimensions.spacingL),

        // Word lists
        if (lists.isEmpty)
          _buildEmptyState(context, isParentalMode)
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
              WordListCard(wordList: completedLists[i], colorIndex: i + activeLists.length),
          ],
        ],

        // Add new list button
        const SizedBox(height: AppDimensions.spacingL),
        _buildAddListButton(context, isParentalMode),
        const SizedBox(height: AppDimensions.spacingXxl),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isParentalMode) {
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
          isParentalMode
              ? 'Créez votre première liste !'
              : 'Demande à un adulte de créer ta première liste !',
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

  Widget _buildAddListButton(BuildContext context, bool isParentalMode) {
    return DashedBorderButton(
      text: AppStrings.newList,
      icon: Icons.add,
      isLocked: !isParentalMode,
      onTap: isParentalMode
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ListEditScreen(),
                ),
              );
            }
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Demande à un adulte pour créer une liste'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configure le code PIN d\'abord'),
            behavior: SnackBarBehavior.floating,
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
