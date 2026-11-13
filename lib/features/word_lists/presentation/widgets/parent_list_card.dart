import 'package:flutter/material.dart';
import 'package:mesmots/core/extensions/palette_context.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/features/games/presentation/extensions/game_type_presentation.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_list.dart';
import 'package:mesmots/shared/widgets/circle_icon_button.dart';

/// Word list card of the parent space, with edit and delete actions.
class ParentListCard extends StatefulWidget {
  final WordList wordList;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ParentListCard({
    super.key,
    required this.wordList,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<ParentListCard> createState() => _ParentListCardState();
}

class _ParentListCardState extends State<ParentListCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final list = widget.wordList;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onEdit();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.only(bottom: AppDimensions.spacingL),
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        transform: Matrix4.translationValues(0, _isPressed ? 2 : 0, 0),
        decoration: BoxDecoration(
          color: context.palette.panel,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          border: context.palette.panelOutline,
          boxShadow: [
            BoxShadow(
              color: context.palette.panelShadow,
              blurRadius: 0,
              offset: Offset(0, _isPressed ? 2 : 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    list.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: AppTypography.bodyLarge,
                      fontWeight: AppTypography.bold,
                      color: context.palette.panelText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${list.words.length} ${AppStrings.words} • '
                    '${list.masteredCount}/${list.words.length} '
                    '${AppStrings.masteredWords}',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: AppTypography.bodySmall,
                      fontWeight: AppTypography.semiBold,
                      color: context.palette.panelTextMuted,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingS),
                  Wrap(
                    spacing: AppDimensions.spacingXs,
                    runSpacing: AppDimensions.spacingXs,
                    children: [
                      for (final type in list.availableGames)
                        Tooltip(
                          message: type.label,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: type.color,
                              borderRadius:
                                  BorderRadius.circular(AppDimensions.radiusS),
                            ),
                            child: Icon(
                              type.icon,
                              size: 16,
                              color: context.palette.onBlock(type.color),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.spacingM),
            CircleIconButton.colored(
              icon: Icons.edit,
              onTap: widget.onEdit,
              color: AppColors.buttonBlue,
              shadowColor: AppColors.buttonBlueShadow,
            ),
            const SizedBox(width: AppDimensions.spacingS),
            CircleIconButton.colored(
              icon: Icons.delete,
              onTap: widget.onDelete,
              color: AppColors.buttonCoral,
              shadowColor: AppColors.buttonCoralShadow,
            ),
          ],
        ),
      ),
    );
  }
}
