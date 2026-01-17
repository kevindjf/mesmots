import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/features/word_lists/domain/entities/game_level.dart';
import 'package:mesmots/features/word_lists/domain/entities/level_progress.dart';
import 'package:mesmots/shared/widgets/app_progress_bar.dart';
import 'package:mesmots/shared/widgets/app_button.dart';
import 'package:mesmots/features/games/presentation/screens/qcm_game_screen.dart';
import 'package:mesmots/features/games/presentation/screens/scramble_game_screen.dart';
import 'package:mesmots/features/games/presentation/screens/fill_blanks_game_screen.dart';
import 'package:mesmots/features/games/presentation/screens/writing_game_screen.dart';

class LevelCard extends StatelessWidget {
  final GameLevel level;
  final LevelProgress progress;
  final bool isUnlocked;
  final String listId;

  const LevelCard({
    super.key,
    required this.level,
    required this.progress,
    required this.isUnlocked,
    required this.listId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingL),
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: isUnlocked
            ? AppColors.surface
            : AppColors.textLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(
          color: _getLevelColor(),
          width: 2,
        ),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(AppDimensions.shadowOpacity),
                  blurRadius: AppDimensions.shadowBlur,
                  offset: const Offset(0, AppDimensions.elevationM),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                level.emoji,
                style: TextStyle(
                  fontSize: 32,
                  color: isUnlocked ? null : AppColors.textLight,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${level.number}. ${level.name}',
                          style: TextStyle(
                            fontSize: AppTypography.headingSmall,
                            fontWeight: AppTypography.semiBold,
                            color: isUnlocked
                                ? AppColors.textPrimary
                                : AppColors.textLight,
                          ),
                        ),
                        if (!isUnlocked) ...[
                          const SizedBox(width: AppDimensions.spacingS),
                          const Icon(
                            Icons.lock,
                            size: 20,
                            color: AppColors.textLight,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    Text(
                      level.description,
                      style: TextStyle(
                        fontSize: AppTypography.bodySmall,
                        color: isUnlocked
                            ? AppColors.textSecondary
                            : AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingL),
          if (isUnlocked) ...[
            AppProgressBar(
              progress: progress.percentage,
              color: _getLevelColor(),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildProgressInfo(),
                AppButton(
                  text: AppStrings.play,
                  onPressed: () => _navigateToGame(context),
                  backgroundColor: _getLevelColor(),
                ),
              ],
            ),
          ] else
            _buildLockedMessage(level.previous!),
        ],
      ),
    );
  }

  Widget _buildProgressInfo() {
    if (progress.isCompleted) {
      return const Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.success),
          SizedBox(width: AppDimensions.spacingS),
          Text(
            AppStrings.levelUnlocked,
            style: TextStyle(
              fontSize: AppTypography.bodyMedium,
              color: AppColors.success,
              fontWeight: AppTypography.semiBold,
            ),
          ),
        ],
      );
    }

    final percentage = progress.percentageInt;
    final needed = 75 - percentage;

    return Text(
      '$percentage% • ${progress.validatedCount}/${progress.totalWords} validés',
      style: const TextStyle(
        fontSize: AppTypography.bodyMedium,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildLockedMessage(GameLevel previousLevel) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingS),
      child: Text(
        '${AppStrings.levelLocked} ${previousLevel.number}',
        style: const TextStyle(
          fontSize: AppTypography.bodyMedium,
          color: AppColors.textLight,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Color _getLevelColor() {
    switch (level) {
      case GameLevel.qcm:
        return AppColors.level1;
      case GameLevel.scramble:
        return AppColors.level2;
      case GameLevel.fillBlanks:
        return AppColors.level3;
      case GameLevel.writing:
        return AppColors.level4;
    }
  }

  void _navigateToGame(BuildContext context) {
    final Widget screen;

    switch (level) {
      case GameLevel.qcm:
        screen = QcmGameScreen(listId: listId);
        break;
      case GameLevel.scramble:
        screen = ScrambleGameScreen(listId: listId);
        break;
      case GameLevel.fillBlanks:
        screen = FillBlanksGameScreen(listId: listId);
        break;
      case GameLevel.writing:
        screen = WritingGameScreen(listId: listId);
        break;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}
