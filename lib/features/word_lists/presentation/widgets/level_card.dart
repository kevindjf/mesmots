import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/features/word_lists/domain/entities/game_level.dart';
import 'package:mesmots/features/word_lists/domain/entities/level_progress.dart';
import 'package:mesmots/features/games/presentation/screens/qcm_game_screen.dart';
import 'package:mesmots/features/games/presentation/screens/scramble_game_screen.dart';
import 'package:mesmots/features/games/presentation/screens/fill_blanks_game_screen.dart';
import 'package:mesmots/features/games/presentation/screens/writing_game_screen.dart';

/// Color scheme for level cards
class _LevelColorScheme {
  final Color cardColor;
  final Color shadowColor;

  const _LevelColorScheme({
    required this.cardColor,
    required this.shadowColor,
  });
}

/// Get color scheme for each level
_LevelColorScheme _getColorScheme(GameLevel level) {
  switch (level) {
    case GameLevel.qcm:
      return const _LevelColorScheme(
        cardColor: AppColors.buttonOrange,
        shadowColor: AppColors.buttonOrangeShadow,
      );
    case GameLevel.scramble:
      return const _LevelColorScheme(
        cardColor: AppColors.buttonBlue,
        shadowColor: AppColors.buttonBlueShadow,
      );
    case GameLevel.fillBlanks:
      return const _LevelColorScheme(
        cardColor: AppColors.buttonPink,
        shadowColor: AppColors.buttonPinkShadow,
      );
    case GameLevel.writing:
      return const _LevelColorScheme(
        cardColor: AppColors.buttonMagenta,
        shadowColor: AppColors.buttonMagentaShadow,
      );
  }
}

class LevelCard extends StatefulWidget {
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
  State<LevelCard> createState() => _LevelCardState();
}

class _LevelCardState extends State<LevelCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = _getColorScheme(widget.level);
    final isCompleted = widget.progress.isCompleted;

    return GestureDetector(
      onTapDown: widget.isUnlocked ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.isUnlocked
          ? (_) {
              setState(() => _isPressed = false);
              _navigateToGame(context);
            }
          : null,
      onTapCancel: widget.isUnlocked ? () => setState(() => _isPressed = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.only(bottom: AppDimensions.spacingL),
        padding: const EdgeInsets.all(20),
        transform: Matrix4.translationValues(0, _isPressed ? 3 : 0, 0),
        decoration: BoxDecoration(
          color: widget.isUnlocked
              ? colorScheme.cardColor
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
          boxShadow: [
            BoxShadow(
              color: widget.isUnlocked
                  ? colorScheme.shadowColor
                  : AppColors.primaryDark,
              blurRadius: 0,
              offset: Offset(0, _isPressed ? 3 : 6),
            ),
          ],
        ),
        child: widget.isUnlocked
            ? _buildUnlockedContent(colorScheme, isCompleted)
            : _buildLockedContent(),
      ),
    );
  }

  Widget _buildUnlockedContent(_LevelColorScheme colorScheme, bool isCompleted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with number and title
        Row(
          children: [
            // Level number badge
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.textOnColor.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: Center(
                child: Text(
                  '${widget.level.number}',
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: AppTypography.headingMedium,
                    fontWeight: AppTypography.bold,
                    color: AppColors.textOnColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingM),

            // Title and description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.level.name,
                    style: const TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: AppTypography.headingSmall,
                      fontWeight: AppTypography.bold,
                      color: AppColors.textOnColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.level.description,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: AppTypography.bodySmall,
                      fontWeight: AppTypography.semiBold,
                      color: AppColors.textOnColor.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),

            // Status icon or arrow
            if (isCompleted)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.textOnColor.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: AppColors.textOnColor,
                  size: 22,
                ),
              )
            else
              const Text(
                '→',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textOnColor,
                ),
              ),
          ],
        ),

        const SizedBox(height: AppDimensions.spacingM),

        // Progress bar
        _LevelProgressBar(
          progress: widget.progress.percentage,
        ),

        const SizedBox(height: AppDimensions.spacingS),

        // Progress text
        Text(
          isCompleted
              ? '✓ Niveau terminé !'
              : '${widget.progress.percentageInt}% • ${widget.progress.validatedCount}/${widget.progress.totalWords} mots validés',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: AppTypography.bodySmall,
            fontWeight: AppTypography.semiBold,
            color: AppColors.textOnColor.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildLockedContent() {
    return Opacity(
      opacity: 0.6,
      child: Row(
        children: [
          // Lock icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: const Center(
              child: Icon(
                Icons.lock,
                color: AppColors.textLight,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingM),

          // Title and locked message
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.level.number}. ${widget.level.name}',
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: AppTypography.headingSmall,
                    fontWeight: AppTypography.bold,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Termine le niveau ${widget.level.previous!.number} pour débloquer',
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: AppTypography.bodySmall,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToGame(BuildContext context) {
    final Widget screen;

    switch (widget.level) {
      case GameLevel.qcm:
        screen = QcmGameScreen(listId: widget.listId);
        break;
      case GameLevel.scramble:
        screen = ScrambleGameScreen(listId: widget.listId);
        break;
      case GameLevel.fillBlanks:
        screen = FillBlanksGameScreen(listId: widget.listId);
        break;
      case GameLevel.writing:
        screen = WritingGameScreen(listId: widget.listId);
        break;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}

/// Progress bar for level card
class _LevelProgressBar extends StatelessWidget {
  final double progress;

  const _LevelProgressBar({
    required this.progress,
  });

  static const double height = 4;

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
