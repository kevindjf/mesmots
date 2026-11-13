import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/core/extensions/motion_context.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_list.dart';
import 'package:mesmots/features/word_lists/presentation/widgets/word_mastery_chip.dart';
import 'package:mesmots/features/word_lists/presentation/widgets/word_preview_sheet.dart';

/// The words of a list, folded under a "4 mots • 1/4 maîtrisés" bar at the
/// top of the list screen. Unfolded, each word shows its stars; tapping it
/// opens [WordPreviewSheet], where buttons say it or spell it.
class WordListPanel extends StatefulWidget {
  final WordList wordList;

  const WordListPanel({super.key, required this.wordList});

  @override
  State<WordListPanel> createState() => _WordListPanelState();
}

class _WordListPanelState extends State<WordListPanel> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final list = widget.wordList;
    final duration = context.motion(const Duration(milliseconds: 250));

    return Container(
      decoration: BoxDecoration(
        color: AppColors.textOnColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            expanded: _isExpanded,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: AppDimensions.minTouchTarget,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingM,
                    vertical: AppDimensions.paddingS,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.menu_book,
                        color: AppColors.textOnColor,
                        size: AppDimensions.iconS,
                      ),
                      const SizedBox(width: AppDimensions.spacingS),
                      Expanded(
                        child: Text(
                          '${list.words.length} ${AppStrings.words} • '
                          '${list.masteredCount}/${list.words.length} '
                          '${AppStrings.mastered}',
                          style: const TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: AppTypography.bodyMedium,
                            fontWeight: AppTypography.semiBold,
                            color: AppColors.textOnColor,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: duration,
                        child: const Icon(
                          Icons.expand_more_rounded,
                          color: AppColors.textOnColor,
                          size: AppDimensions.iconM,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: duration,
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: _isExpanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.paddingM,
                      AppDimensions.spacingXs,
                      AppDimensions.paddingM,
                      AppDimensions.paddingM,
                    ),
                    child: Wrap(
                      spacing: AppDimensions.spacingS,
                      runSpacing: AppDimensions.spacingM,
                      children: [
                        for (final word in list.words)
                          WordMasteryChip(
                            word: word,
                            status: list.statusOf(word),
                            onTap: () => WordPreviewSheet.show(
                              context,
                              word: word,
                              status: list.statusOf(word),
                            ),
                          ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
