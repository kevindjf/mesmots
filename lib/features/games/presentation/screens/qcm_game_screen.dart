import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmots/core/extensions/palette_context.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/features/games/presentation/providers/qcm_game_provider.dart';
import 'package:mesmots/shared/widgets/speaker_button.dart';
import 'package:mesmots/shared/widgets/progress_stars.dart';
import 'package:mesmots/shared/widgets/gradient_background.dart';
import 'package:mesmots/features/games/presentation/widgets/game_layout.dart';
import 'package:mesmots/features/games/presentation/widgets/qcm_option_card.dart';
import 'package:mesmots/features/games/presentation/widgets/success_overlay.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_status.dart';
import 'package:mesmots/shared/widgets/bounded_content.dart';
import 'package:mesmots/shared/widgets/centered_scroll_view.dart';

class QcmGameScreen extends ConsumerStatefulWidget {
  final String listId;

  const QcmGameScreen({
    super.key,
    required this.listId,
  });

  @override
  ConsumerState<QcmGameScreen> createState() => _QcmGameScreenState();
}

class _QcmGameScreenState extends ConsumerState<QcmGameScreen> {
  static const _columns = 2;

  /// Square cards, or wider ones when the screen is too short for squares
  /// (tablet in landscape), so every option stays visible.
  static double _cardAspectRatio(BoxConstraints constraints, int options) {
    const spacing = AppDimensions.spacingL;
    final rows = (options / _columns).ceil();
    final width = (constraints.maxWidth - spacing * (_columns - 1)) / _columns;
    final height = (constraints.maxHeight - spacing * (rows - 1)) / rows;
    if (height <= 0) return 1;
    return width / height > 1 ? width / height : 1;
  }

  @override
  Widget build(BuildContext context) {
    final gameStateAsync = ref.watch(qcmGameProvider(widget.listId));

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: BoundedContent.sideBySide(
            child: gameStateAsync.when(
              data: (gameState) {
                if (gameState.question == null) {
                  return SuccessOverlay(
                    onReplay: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              QcmGameScreen(listId: widget.listId),
                        ),
                      );
                    },
                    onBackToList: () {
                      Navigator.pop(context);
                    },
                  );
                }

                final gameProvider =
                    ref.read(qcmGameProvider(widget.listId).notifier);
                final question = gameState.question!;

                final prompt = <Widget>[
                  SpeakerButton(word: question.word, size: 80),
                  const SizedBox(height: AppDimensions.spacingS),
                  Text(
                    AppStrings.tapToReplay,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: AppTypography.bodySmall,
                      color: context.palette.onBackground,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXl),
                  AnimatedProgressStars(
                    count: question.stars,
                    max: WordStatus.masteryThreshold,
                    size: AppDimensions.iconL,
                  ),
                ];
                final options = LayoutBuilder(
                  builder: (context, constraints) => GridView.count(
                    crossAxisCount: _columns,
                    crossAxisSpacing: AppDimensions.spacingL,
                    mainAxisSpacing: AppDimensions.spacingL,
                    childAspectRatio: _cardAspectRatio(
                      constraints,
                      question.options.length,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      for (final option in question.options)
                        QcmOptionCard(
                          text: option.text,
                          isCorrect: option.isCorrect,
                          isAnswered: question.isAnswered,
                          isSelected: question.selected == option.text,
                          onTap: () => gameProvider.answer(option.text),
                        ),
                    ],
                  ),
                );

                return GameLayout(
                  progress: gameState.progress,
                  validatedCount: gameState.validatedCount,
                  totalCount: gameState.totalCount,
                  portrait: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingXl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...prompt,
                        const SizedBox(height: AppDimensions.spacingXxl),
                        Expanded(child: options),
                      ],
                    ),
                  ),
                  prompt: CenteredScrollView(
                    alwaysCenter: true,
                    padding: const EdgeInsets.all(AppDimensions.paddingL),
                    child: Column(children: prompt),
                  ),
                  answer: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingXl),
                    child: Center(child: options),
                  ),
                );
              },
              loading: () => Center(
                child: CircularProgressIndicator(
                    color: context.palette.onBackground),
              ),
              error: (error, stack) => Center(
                child: Text(
                  'Erreur: $error',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    color: context.palette.onBackground,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
