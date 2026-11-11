import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jerevise/core/constants/app_colors.dart';
import 'package:jerevise/core/constants/app_dimensions.dart';
import 'package:jerevise/core/constants/app_typography.dart';
import 'package:jerevise/features/conjugation/domain/entities/quiz_config.dart';
import 'package:jerevise/features/conjugation/presentation/providers/phrase_game_provider.dart';
import 'package:jerevise/features/conjugation/presentation/screens/conjugation_result_screen.dart';
import 'package:jerevise/features/games/presentation/widgets/game_header.dart';
import 'package:jerevise/shared/widgets/circle_icon_button.dart';
import 'package:jerevise/shared/widgets/colorful_button.dart';
import 'package:jerevise/shared/widgets/gradient_background.dart';

class PhraseGameScreen extends ConsumerWidget {
  final QuizConfig config;

  const PhraseGameScreen({super.key, required this.config});

  static const _accentColor = AppColors.buttonMagenta;
  static const _accentShadow = AppColors.buttonMagentaShadow;

  void _showQuitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        ),
        title: const Text(
          'Quitter le jeu ?',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontWeight: AppTypography.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'Ta progression ne sera pas sauvegardée.',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'CONTINUER',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontWeight: AppTypography.bold,
                color: _accentColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text(
              'QUITTER',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontWeight: AppTypography.bold,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _timerColor(int seconds) {
    if (seconds > 10) return AppColors.success;
    if (seconds > 5) return AppColors.accent;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(phraseGameProvider(config));
    final notifier = ref.read(phraseGameProvider(config).notifier);

    if (state.questions.isEmpty) {
      return const Scaffold(
        body: GradientBackground(
          child: Center(
            child: CircularProgressIndicator(color: AppColors.textOnColor),
          ),
        ),
      );
    }

    final q = state.questions[state.index];
    final progress = (state.index + 1) / state.questions.length;
    final isLast = state.index >= state.questions.length - 1;
    final isFinished = isLast && state.showFeedback;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Quit button
              Padding(
                padding: const EdgeInsets.only(
                  left: AppDimensions.paddingL,
                  top: AppDimensions.spacingS,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: CircleIconButton(
                    icon: Icons.close,
                    onTap: () => _showQuitDialog(context),
                    color: AppColors.surface,
                    shadowColor: AppColors.primaryDark,
                    iconColor: AppColors.error,
                    size: 40,
                  ),
                ),
              ),

              // Header
              GameHeader(
                progress: progress,
                validatedCount: state.index + 1,
                totalCount: state.questions.length,
                progressColor: _accentColor,
                timer: _TimerChip(
                  seconds: state.timeRemaining,
                  color: _timerColor(state.timeRemaining),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingM),

              // Phrase card
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingL,),
                child: _PhraseCard(
                  sentence: q.displaySentence,
                  infinitif: q.verb.infinitive,
                  showFeedback: state.showFeedback,
                  isCorrect: state.lastCorrect,
                  correctAnswer: q.correct,
                ),
              ),

              const SizedBox(height: AppDimensions.spacingL),

              // 4 answer buttons
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingL,),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: q.options.asMap().entries.map((e) {
                      final idx = e.key;
                      final opt = e.value;
                      return _AnswerButton(
                        key: ValueKey('q${q.id}-opt$idx'),
                        text: opt,
                        isCorrect: opt == q.correct,
                        showFeedback: state.showFeedback,
                        colorIndex: idx,
                        onTap: state.showFeedback
                            ? null
                            : () => notifier.answer(opt),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Next / Result button
              if (state.showFeedback)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingL,
                    vertical: AppDimensions.spacingM,
                  ),
                  child: ColorfulButton(
                    text: isFinished
                        ? 'VOIR MON SCORE'
                        : 'QUESTION SUIVANTE',
                    icon: isFinished ? Icons.emoji_events : Icons.arrow_forward,
                    color: isFinished ? _accentColor : AppColors.success,
                    shadowColor:
                        isFinished ? _accentShadow : AppColors.successShadow,
                    width: double.infinity,
                    onTap: isFinished
                        ? () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ConjugationResultScreen(
                                  score: state.score,
                                  total: state.questions.length,
                                  gameTitle: 'Phrase à Trous',
                                  accentColor: _accentColor,
                                  accentShadowColor: _accentShadow,
                                  onReplay: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PhraseGameScreen(
                                            config: config,),
                                      ),
                                    );
                                  },
                                  onMenu: () => Navigator.popUntil(
                                      context, (r) => r.isFirst,),
                                ),
                              ),
                            );
                          }
                        : () => notifier.next(),
                  ),
                ),

              const SizedBox(height: AppDimensions.spacingS),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimerChip extends StatelessWidget {
  final int seconds;
  final Color color;

  const _TimerChip({required this.seconds, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.spacingXs,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            seconds <= 5 ? Icons.timer : Icons.access_time,
            color: AppColors.textOnColor,
            size: AppDimensions.iconS,
          ),
          const SizedBox(width: 4),
          Text(
            '${seconds}s',
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: AppTypography.bodySmall,
              fontWeight: AppTypography.bold,
              color: AppColors.textOnColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhraseCard extends StatelessWidget {
  final String sentence;
  final String infinitif;
  final bool showFeedback;
  final bool isCorrect;
  final String correctAnswer;

  const _PhraseCard({
    required this.sentence,
    required this.infinitif,
    required this.showFeedback,
    required this.isCorrect,
    required this.correctAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingXl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
        boxShadow: const [
          BoxShadow(
            color: AppColors.primaryDark,
            blurRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.buttonMagenta.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Sentence text
          Text(
            showFeedback
                ? sentence.replaceAll('________', correctAnswer)
                : sentence,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: AppTypography.headingSmall,
              fontWeight: AppTypography.semiBold,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),

          const SizedBox(height: AppDimensions.spacingM),

          // Verb hint
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingM,
              vertical: AppDimensions.spacingXs,
            ),
            decoration: BoxDecoration(
              color: AppColors.buttonMagenta.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: Text(
              '($infinitif)',
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: AppTypography.bodyMedium,
                fontWeight: AppTypography.semiBold,
                color: AppColors.buttonMagenta,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          if (showFeedback) ...[
            const SizedBox(height: AppDimensions.spacingL),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              decoration: BoxDecoration(
                color: isCorrect ? AppColors.successLight : AppColors.errorLight,
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                border: Border.all(
                  color: isCorrect ? AppColors.success : AppColors.error,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    size: 24,
                    color: isCorrect
                        ? AppColors.successDark
                        : AppColors.errorDark,
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  Flexible(
                    child: Text(
                      isCorrect
                          ? 'Bravo !'
                          : 'La réponse était « $correctAnswer »',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: AppTypography.bodyMedium,
                        fontWeight: AppTypography.semiBold,
                        color: isCorrect
                            ? AppColors.successDark
                            : AppColors.errorDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AnswerButton extends StatefulWidget {
  final String text;
  final bool isCorrect;
  final bool showFeedback;
  final int colorIndex;
  final VoidCallback? onTap;

  const _AnswerButton({
    super.key,
    required this.text,
    required this.isCorrect,
    required this.showFeedback,
    required this.colorIndex,
    this.onTap,
  });

  @override
  State<_AnswerButton> createState() => _AnswerButtonState();
}

class _AnswerButtonState extends State<_AnswerButton> {
  bool _isPressed = false;

  static const _colors = [
    [AppColors.buttonMagenta, AppColors.buttonMagentaShadow],
    [AppColors.buttonCoral, AppColors.buttonCoralShadow],
    [AppColors.buttonBlue, AppColors.buttonBlueShadow],
    [AppColors.buttonOrange, AppColors.buttonOrangeShadow],
  ];

  @override
  Widget build(BuildContext context) {
    final pair = _colors[widget.colorIndex % _colors.length];
    Color bgColor;
    Color shadowColor;

    if (widget.showFeedback) {
      bgColor = widget.isCorrect ? AppColors.success : AppColors.textLight;
      shadowColor =
          widget.isCorrect ? AppColors.successShadow : AppColors.textSecondary;
    } else {
      bgColor = pair[0];
      shadowColor = pair[1];
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: GestureDetector(
        onTapDown: widget.onTap != null
            ? (_) => setState(() => _isPressed = true)
            : null,
        onTapUp: widget.onTap != null
            ? (_) {
                setState(() => _isPressed = false);
                widget.onTap!();
              }
            : null,
        onTapCancel: widget.onTap != null
            ? () => setState(() => _isPressed = false)
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(vertical: AppDimensions.paddingM),
          transform: Matrix4.translationValues(0, _isPressed ? 4 : 0, 0),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 0,
                offset: Offset(0, _isPressed ? 2 : 6),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.showFeedback && widget.isCorrect)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Icons.check_circle,
                        size: 22, color: AppColors.textOnColor,),
                  ),
                Text(
                  widget.text,
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: AppTypography.headingSmall,
                    fontWeight: AppTypography.bold,
                    color: AppColors.textOnColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
