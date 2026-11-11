import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/features/games/domain/entities/grid_point.dart';
import 'package:mesmots/features/games/presentation/providers/crossword_game_provider.dart';
import 'package:mesmots/features/games/presentation/widgets/crossword_board.dart';
import 'package:mesmots/features/games/presentation/widgets/crossword_clue_chip.dart';
import 'package:mesmots/features/games/presentation/widgets/game_header.dart';
import 'package:mesmots/features/games/presentation/widgets/success_overlay.dart';
import 'package:mesmots/shared/widgets/azerty_keyboard.dart';
import 'package:mesmots/shared/widgets/circle_icon_button.dart';
import 'package:mesmots/shared/widgets/colorful_button.dart';
import 'package:mesmots/shared/widgets/gradient_background.dart';

class CrosswordGameScreen extends ConsumerStatefulWidget {
  final String listId;

  const CrosswordGameScreen({super.key, required this.listId});

  @override
  ConsumerState<CrosswordGameScreen> createState() =>
      _CrosswordGameScreenState();
}

class _CrosswordGameScreenState extends ConsumerState<CrosswordGameScreen> {
  static const _celebrationDelay = Duration(milliseconds: 1200);

  bool _showSuccess = false;

  @override
  Widget build(BuildContext context) {
    final provider = crosswordGameProvider(widget.listId);

    ref.listen(provider, (previous, next) {
      final wasComplete = previous?.valueOrNull?.isComplete ?? false;
      if (!wasComplete && (next.valueOrNull?.isComplete ?? false)) {
        Future.delayed(_celebrationDelay, () {
          if (mounted) setState(() => _showSuccess = true);
        });
      }
    });

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: ref.watch(provider).when(
                data: (state) => _showSuccess
                    ? SuccessOverlay(
                        onReplay: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CrosswordGameScreen(listId: widget.listId),
                          ),
                        ),
                        onBackToList: () => Navigator.pop(context),
                      )
                    : _buildGame(state, ref.read(provider.notifier)),
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.textOnColor,
                  ),
                ),
                error: (error, _) => _buildMessage(
                  error is CrosswordUnavailableException
                      ? AppStrings.crosswordUnavailable
                      : '$error',
                ),
              ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
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
        ],
      ),
    );
  }

  Widget _buildMessage(String message) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingXl),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: AppTypography.bodyLarge,
                  fontWeight: AppTypography.semiBold,
                  color: AppColors.textOnColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGame(CrosswordGameState state, CrosswordGame game) {
    final entries = state.crossword.entries;

    return Column(
      children: [
        _buildHeader(),
        GameHeader(
          progress: state.progress,
          validatedCount: state.solvedCount,
          totalCount: state.totalCount,
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final crossword = state.crossword;
              final maxWidth =
                  constraints.maxWidth - 2 * AppDimensions.paddingL;
              final maxHeight = constraints.maxHeight;
              final width = (maxHeight * crossword.cols / crossword.rows)
                  .clamp(0.0, maxWidth);

              return Center(
                child: SizedBox(
                  width: width,
                  child: CrosswordBoard(
                    state: state,
                    onCellTap: game.tapCell,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppDimensions.spacingM),
        SizedBox(
          height: AppDimensions.minTouchTarget + 6,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingL,
            ),
            itemCount: entries.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: AppDimensions.spacingS),
            itemBuilder: (_, index) => CrosswordClueChip(
              entry: entries[index],
              isSelected: index == state.selectedEntry,
              isSolved: state.solved.contains(index),
              onTap: () => game.selectEntry(index),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingM),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
          ),
          child: Row(
            children: [
              CircleIconButton.colored(
                icon: Icons.volume_up_rounded,
                onTap: game.speakSelected,
                color: AppColors.buttonBlue,
                shadowColor: AppColors.buttonBlueShadow,
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: Text(
                  '${state.selected.number} ${_directionLabel(state)} • ${AppStrings.crosswordListen}',
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: AppTypography.bodySmall,
                    fontWeight: AppTypography.semiBold,
                    color: AppColors.textOnColor,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              ColorfulButton(
                text: AppStrings.hint,
                icon: Icons.lightbulb_rounded,
                color: AppColors.buttonOrange,
                shadowColor: AppColors.buttonOrangeShadow,
                onTap: game.revealLetter,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spacingM),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingS,
          ),
          child: AzertyKeyboard(
            onLetterTap: game.typeLetter,
            onBackspace: game.deleteLetter,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingM),
      ],
    );
  }

  String _directionLabel(CrosswordGameState state) =>
      state.selected.direction == WordDirection.horizontal
          ? AppStrings.crosswordAcross
          : AppStrings.crosswordDown;
}
