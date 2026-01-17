import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_list.dart';
import 'package:mesmots/features/word_lists/presentation/screens/list_detail_screen.dart';
import 'package:mesmots/shared/widgets/app_progress_bar.dart';

class WordListCard extends StatelessWidget {
  final WordList wordList;

  const WordListCard({
    super.key,
    required this.wordList,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = wordList.isFullyCompleted;
    final currentLevel = wordList.currentLevel;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ListDetailScreen(listId: wordList.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.spacingL),
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(AppDimensions.shadowOpacity),
              blurRadius: AppDimensions.shadowBlur,
              offset: const Offset(0, AppDimensions.elevationM),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  isCompleted ? '✅' : '📘',
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: AppDimensions.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wordList.name,
                        style: const TextStyle(
                          fontSize: AppTypography.headingSmall,
                          fontWeight: AppTypography.semiBold,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXs),
                      Text(
                        '${wordList.words.length} ${AppStrings.words}',
                        style: const TextStyle(
                          fontSize: AppTypography.bodySmall,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCompleted)
                  const Text(
                    '100%',
                    style: TextStyle(
                      fontSize: AppTypography.bodyLarge,
                      fontWeight: AppTypography.bold,
                      color: AppColors.success,
                    ),
                  ),
              ],
            ),
            if (!isCompleted) ...[
              const SizedBox(height: AppDimensions.spacingL),
              AppProgressBar(
                progress: wordList.progress[currentLevel]?.percentage ?? 0.0,
                color: _getLevelColor(currentLevel),
              ),
              const SizedBox(height: AppDimensions.spacingM),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${currentLevel.emoji} ${currentLevel.name}',
                    style: const TextStyle(
                      fontSize: AppTypography.bodyMedium,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${wordList.progress[currentLevel]?.percentageInt ?? 0}%',
                    style: const TextStyle(
                      fontSize: AppTypography.bodyMedium,
                      fontWeight: AppTypography.semiBold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getLevelColor(level) {
    switch (level.index) {
      case 0:
        return AppColors.level1;
      case 1:
        return AppColors.level2;
      case 2:
        return AppColors.level3;
      case 3:
        return AppColors.level4;
      default:
        return AppColors.primary;
    }
  }
}
