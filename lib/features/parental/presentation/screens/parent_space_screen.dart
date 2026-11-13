import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmots/core/extensions/palette_context.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/features/appearance/presentation/widgets/appearance_section.dart';
import 'package:mesmots/features/parental/presentation/widgets/pin_input_dialog.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_list.dart';
import 'package:mesmots/features/word_lists/presentation/providers/word_list_providers.dart';
import 'package:mesmots/features/word_lists/presentation/screens/list_edit_screen.dart';
import 'package:mesmots/features/word_lists/presentation/widgets/parent_list_card.dart';
import 'package:mesmots/shared/widgets/circle_icon_button.dart';
import 'package:mesmots/shared/widgets/colorful_button.dart';
import 'package:mesmots/shared/widgets/confirm_delete_dialog.dart';
import 'package:mesmots/shared/widgets/gradient_background.dart';

/// Adult area, reached with the PIN: create, edit and delete word lists.
///
/// Leaving the screen leaves the parent space: the child screens never show
/// management actions.
class ParentSpaceScreen extends ConsumerWidget {
  const ParentSpaceScreen({super.key});

  /// Asks for the PIN, then opens the parent space
  static Future<void> open(BuildContext context) async {
    final granted = await showDialog<bool>(
      context: context,
      builder: (_) => const PinInputDialog(),
    );
    if (granted == true && context.mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ParentSpaceScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(wordListsProvider);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                  vertical: AppDimensions.paddingM,
                ),
                child: Row(
                  children: [
                    CircleIconButton.surface(
                      icon: Icons.close,
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: AppDimensions.spacingM),
                    Expanded(
                      child: Text(
                        AppStrings.parentSpace,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: AppTypography.headingMedium,
                          fontWeight: AppTypography.bold,
                          color: context.palette.onBackground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: listsAsync.when(
                  data: (lists) => _buildContent(context, ref, lists),
                  loading: () => Center(
                    child: CircularProgressIndicator(
                      color: context.palette.onBackground,
                    ),
                  ),
                  error: (error, _) => Center(
                    child: Text(
                      '${AppStrings.errorLoadingLists}: $error',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        color: context.palette.onBackground,
                      ),
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

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<WordList> lists,
  ) {
    final sorted = [...lists]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      children: [
        Text(
          AppStrings.parentSpaceIntro,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: AppTypography.bodyMedium,
            fontWeight: AppTypography.semiBold,
            color: context.palette.onBackground.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingL),
        ColorfulButton.orange(
          text: AppStrings.newList,
          icon: Icons.add,
          width: double.infinity,
          onTap: () => _openEditor(context),
        ),
        const SizedBox(height: AppDimensions.spacingXl),
        Text(
          AppStrings.parentLists,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: AppTypography.bodySmall,
            fontWeight: AppTypography.bold,
            color: context.palette.onBackground,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingL),
        if (sorted.isEmpty)
          Text(
            AppStrings.parentNoList,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: AppTypography.bodyMedium,
              color: context.palette.onBackground.withValues(alpha: 0.8),
            ),
          )
        else
          for (final list in sorted)
            ParentListCard(
              key: ValueKey(list.id),
              wordList: list,
              onEdit: () => _openEditor(context, listId: list.id),
              onDelete: () => _confirmDelete(context, ref, list),
            ),
        const SizedBox(height: AppDimensions.spacingXl),
        const AppearanceSection(),
        const SizedBox(height: AppDimensions.spacingXxl),
      ],
    );
  }

  void _openEditor(BuildContext context, {String? listId}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ListEditScreen(listId: listId)),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    WordList list,
  ) async {
    final operations = ref.read(wordListOperationsProvider.notifier);
    final confirmed = await ConfirmDeleteDialog.show(
      context,
      title: AppStrings.deleteList,
      message: '« ${list.name} »\n${AppStrings.confirmDelete}',
    );
    if (confirmed) await operations.deleteList(list.id);
  }
}
