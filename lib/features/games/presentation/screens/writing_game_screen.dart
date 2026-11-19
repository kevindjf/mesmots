import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmots/core/extensions/palette_context.dart';
import 'package:mesmots/core/extensions/responsive_context.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/features/games/presentation/providers/writing_game_provider.dart';
import 'package:mesmots/features/games/presentation/widgets/game_layout.dart';
import 'package:mesmots/features/games/presentation/widgets/success_overlay.dart';
import 'package:mesmots/features/games/presentation/widgets/writing_answer.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_status.dart';
import 'package:mesmots/shared/widgets/child_keyboard.dart';
import 'package:mesmots/shared/widgets/game_control_button.dart';
import 'package:mesmots/shared/widgets/gradient_background.dart';
import 'package:mesmots/shared/widgets/progress_stars.dart';
import 'package:mesmots/shared/widgets/speaker_button.dart';
import 'package:mesmots/shared/widgets/spelled_word.dart';
import 'package:mesmots/shared/widgets/bounded_content.dart';
import 'package:mesmots/shared/widgets/centered_scroll_view.dart';

/// "Écriture": hear the word and type it entirely.
class WritingGameScreen extends ConsumerWidget {
  final String listId;

  const WritingGameScreen({super.key, required this.listId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = writingGameProvider(listId);
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: BoundedContent.sideBySide(
            child: ref.watch(provider).when(
                  data: (state) {
                    final question = state.question;
                    if (question == null) {
                      return SuccessOverlay(
                        onReplay: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WritingGameScreen(listId: listId),
                          ),
                        ),
                        onBackToList: () => Navigator.pop(context),
                      );
                    }
                    return _buildGame(
                      context,
                      state,
                      question,
                      ref.read(provider.notifier),
                    );
                  },
                  loading: () => Center(
                    child: CircularProgressIndicator(
                      color: context.palette.onBackground,
                    ),
                  ),
                  error: (_, __) => Center(
                    child: Text(
                      AppStrings.errorGeneric,
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

  Widget _buildGame(
    BuildContext context,
    WritingGameState state,
    WritingQuestion question,
    WritingGame game,
  ) {
    final keys = state.keys;
    // The right spelling: after a mistake, and as a model while copying.
    final showModel =
        question.phase == WritingPhase.wrong || question.isCopying;

    final isLandscape = context.isLandscape;
    final content = CenteredScrollView(
      alwaysCenter: isLandscape,
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingXl,
        vertical: isLandscape ? AppDimensions.paddingS : AppDimensions.paddingM,
      ),
      child: Column(
        children: [
          SpeakerButton(word: question.word, size: 64),
          const SizedBox(height: AppDimensions.spacingS),
          AnimatedProgressStars(
            count: state.stars,
            max: WordStatus.masteryThreshold,
            size: AppDimensions.iconL,
          ),
          const SizedBox(height: AppDimensions.spacingM),
          SizedBox(
            height: 64,
            child: showModel
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (question.isCopying)
                        Text(
                          AppStrings.copyTheWord,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: AppTypography.bodySmall,
                            fontWeight: AppTypography.semiBold,
                            color: context.palette.onBackground,
                          ),
                        ),
                      SpelledWord(
                        word: question.word,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: AppTypography.headingMedium,
                          fontWeight: AppTypography.bold,
                          color: context.palette.onBackground,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  )
                : null,
          ),
          const SizedBox(height: AppDimensions.spacingS),
          WritingAnswer(question: question, onMoveCursor: game.moveCursor),
        ],
      ),
    );
    final controls = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingXl,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GameControlButton(
            icon: Icons.lightbulb_outline,
            label: AppStrings.hint,
            onTap: game.hint,
            isEnabled: question.canType,
          ),
          GameControlButton(
            icon: Icons.check,
            label: AppStrings.validate,
            onTap: game.submit,
            isEnabled: question.canType && question.input.trim().isNotEmpty,
            isPrimary: true,
          ),
        ],
      ),
    );
    final keyboard = Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingS,
        AppDimensions.paddingM,
        AppDimensions.paddingS,
        AppDimensions.paddingS,
      ),
      child: ChildKeyboard(
        accents: keys.accents,
        hasSpace: keys.hasSpace,
        hasHyphen: keys.hasHyphen,
        hasApostrophe: keys.hasApostrophe,
        onLetter: question.canType ? game.type : null,
        onBackspace: question.canType ? game.backspace : null,
      ),
    );

    return GameLayout(
      progress: state.progress,
      validatedCount: state.validatedCount,
      totalCount: state.totalCount,
      topBarPadding: AppDimensions.paddingS,
      portrait: Column(
        children: [Expanded(child: content), controls, keyboard],
      ),
      prompt: content,
      answer: CenteredScrollView(
        alwaysCenter: true,
        child: Column(children: [controls, keyboard]),
      ),
    );
  }
}
