import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jerevise/core/constants/app_colors.dart';
import 'package:jerevise/core/constants/app_dimensions.dart';
import 'package:jerevise/core/constants/app_typography.dart';
import 'package:jerevise/features/maths/domain/entities/math_config.dart';
import 'package:jerevise/features/maths/presentation/providers/duel_express_provider.dart';
import 'package:jerevise/features/maths/presentation/screens/duel_result_screen.dart';
import 'package:jerevise/features/maths/presentation/widgets/numeric_keypad.dart';
import 'package:jerevise/features/games/presentation/widgets/game_header.dart';
import 'package:jerevise/shared/widgets/gradient_background.dart';

class DuelGameScreen extends ConsumerWidget {
  final DuelExpressConfig config;

  const DuelGameScreen({super.key, required this.config});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(duelExpressProvider(config));
    final notifier = ref.read(duelExpressProvider(config).notifier);

    // Navigate to result when finished
    if (notifier.isFinished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DuelResultScreen(
              score: state.score,
              total: state.questions.length,
              config: config,
            ),
          ),
        );
      });
    }

    final question = notifier.currentQuestion;
    if (question == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final progress = state.questions.isEmpty
        ? 0.0
        : (state.index + 1) / state.questions.length;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Close button + header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                  vertical: AppDimensions.paddingS,
                ),
                child: Row(
                  children: [
                    _CloseButton(
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: AppDimensions.spacingM),
                    Expanded(
                      child: GameHeader(
                        progress: progress,
                        validatedCount: state.index + 1,
                        totalCount: state.questions.length,
                        progressColor: AppColors.sectionMaths,
                        timer: _TimerBadge(seconds: state.timeRemaining),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Question card
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppDimensions.paddingXl),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.primaryDark,
                        blurRadius: 0,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        question.displayString,
                        style: const TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 36,
                          fontWeight: AppTypography.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingL),
                      // Input display
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.paddingM,
                        ),
                        decoration: BoxDecoration(
                          color: state.showFeedback
                              ? (state.lastCorrect
                                  ? AppColors.success.withValues(alpha: 0.1)
                                  : AppColors.error.withValues(alpha: 0.1))
                              : AppColors.background.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                        ),
                        child: Text(
                          state.showFeedback && !state.lastCorrect
                              ? '${state.currentInput.isEmpty ? "?" : state.currentInput}  →  ${state.lastCorrectAnswer}'
                              : state.currentInput.isEmpty
                                  ? '?'
                                  : state.currentInput,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: AppTypography.headingLarge,
                            fontWeight: AppTypography.bold,
                            color: state.showFeedback
                                ? (state.lastCorrect
                                    ? AppColors.success
                                    : AppColors.error)
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Keypad or Next button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                ),
                child: state.showFeedback
                    ? _NextButton(onTap: () => notifier.next())
                    : NumericKeypad(
                        onDigit: (d) => notifier.appendDigit(d),
                        onDelete: () => notifier.deleteDigit(),
                        onValidate: () => notifier.submitAnswer(null),
                      ),
              ),

              const SizedBox(height: AppDimensions.spacingXl),
            ],
          ),
        ),
      ),
    );
  }
}

class _CloseButton extends StatefulWidget {
  final VoidCallback onTap;
  const _CloseButton({required this.onTap});

  @override
  State<_CloseButton> createState() => _CloseButtonState();
}

class _CloseButtonState extends State<_CloseButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 44,
        height: 44,
        transform: Matrix4.translationValues(0, _isPressed ? 2 : 0, 0),
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark,
              blurRadius: 0,
              offset: Offset(0, _isPressed ? 2 : 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.close,
          color: AppColors.error,
          size: AppDimensions.iconM,
        ),
      ),
    );
  }
}

class _TimerBadge extends StatelessWidget {
  final int seconds;
  const _TimerBadge({required this.seconds});

  @override
  Widget build(BuildContext context) {
    final isLow = seconds <= 3;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingS,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isLow ? AppColors.error : AppColors.sectionMaths,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Text(
        '${seconds}s',
        style: const TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: AppTypography.bodyMedium,
          fontWeight: AppTypography.bold,
          color: AppColors.textOnColor,
        ),
      ),
    );
  }
}

class _NextButton extends StatefulWidget {
  final VoidCallback onTap;
  const _NextButton({required this.onTap});

  @override
  State<_NextButton> createState() => _NextButtonState();
}

class _NextButtonState extends State<_NextButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: double.infinity,
        height: 64,
        transform: Matrix4.translationValues(0, _isPressed ? 3 : 0, 0),
        decoration: BoxDecoration(
          color: AppColors.sectionMaths,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          boxShadow: [
            BoxShadow(
              color: AppColors.sectionMathsShadow,
              blurRadius: 0,
              offset: Offset(0, _isPressed ? 2 : 5),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'SUIVANT',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: AppTypography.bodyLarge,
              fontWeight: AppTypography.bold,
              color: AppColors.textOnColor,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
