import 'package:flutter/material.dart';
import 'package:mesmots/core/extensions/palette_context.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_list.dart';
import 'package:mesmots/features/word_lists/presentation/screens/list_detail_screen.dart';

/// Color scheme for card variations
class _CardColorScheme {
  final Color cardColor;
  final Color shadowColor;

  const _CardColorScheme({
    required this.cardColor,
    required this.shadowColor,
  });
}

/// Available color schemes for cards (style Mr. Square)
const _colorSchemes = [
  _CardColorScheme(
    cardColor: AppColors.buttonOrange,
    shadowColor: AppColors.buttonOrangeShadow,
  ),
  _CardColorScheme(
    cardColor: AppColors.buttonPink,
    shadowColor: AppColors.buttonPinkShadow,
  ),
  _CardColorScheme(
    cardColor: AppColors.buttonBlue,
    shadowColor: AppColors.buttonBlueShadow,
  ),
  _CardColorScheme(
    cardColor: AppColors.buttonMagenta,
    shadowColor: AppColors.buttonMagentaShadow,
  ),
  _CardColorScheme(
    cardColor: AppColors.buttonCoral,
    shadowColor: AppColors.buttonCoralShadow,
  ),
];

/// Card widget displaying a word list with progress
class WordListCard extends StatefulWidget {
  final WordList wordList;
  final VoidCallback? onTap;
  final int colorIndex;

  const WordListCard({
    super.key,
    required this.wordList,
    this.onTap,
    this.colorIndex = 0,
  });

  @override
  State<WordListCard> createState() => _WordListCardState();
}

class _WordListCardState extends State<WordListCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final wordList = widget.wordList;
    final isCompleted = wordList.isMastered;
    final progress = wordList.masteryRatio;
    final colorScheme = _colorSchemes[widget.colorIndex % _colorSchemes.length];

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        final onTap = widget.onTap;
        if (onTap != null) {
          onTap();
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ListDetailScreen(listId: widget.wordList.id),
            ),
          );
        }
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.only(bottom: AppDimensions.spacingL),
        padding: const EdgeInsets.all(20),
        transform: Matrix4.translationValues(0, _isPressed ? 3 : 0, 0),
        decoration: BoxDecoration(
          color: colorScheme.cardColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
          boxShadow: [
            // Ombre 3D colorée (style Mr. Square)
            BoxShadow(
              color: colorScheme.shadowColor,
              blurRadius: 0,
              offset: Offset(0, _isPressed ? 3 : 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Title, subtitle and progress
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.wordList.name,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: AppTypography.bodyLarge,
                      fontWeight: AppTypography.bold,
                      color: context.palette.onBlock(colorScheme.cardColor),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // Subtitle
                  Text(
                    '${wordList.masteredCount}/${wordList.words.length} ${AppStrings.masteredWords}',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: AppTypography.bodySmall,
                      fontWeight: AppTypography.semiBold,
                      color: context.palette
                          .onBlock(colorScheme.cardColor)
                          .withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingM),

                  // Progress bar
                  WordListProgressBar(
                    progress: progress,
                    isCompleted: isCompleted,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.spacingM),

            // Arrow
            Text(
              '→',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: context.palette.onBlock(colorScheme.cardColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Progress bar for word list card
class WordListProgressBar extends StatelessWidget {
  final double progress;
  final bool isCompleted;
  final double height;

  const WordListProgressBar({
    super.key,
    required this.progress,
    this.isCompleted = false,
    this.height = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.textOnColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: constraints.maxWidth * progress.clamp(0.0, 1.0),
                decoration: BoxDecoration(
                  color: AppColors.textOnColor,
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
