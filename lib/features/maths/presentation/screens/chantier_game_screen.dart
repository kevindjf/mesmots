import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jerevise/core/constants/app_colors.dart';
import 'package:jerevise/core/constants/app_dimensions.dart';
import 'package:jerevise/core/constants/app_strings.dart';
import 'package:jerevise/core/constants/app_typography.dart';
import 'package:jerevise/features/maths/domain/entities/math_config.dart';
import 'package:jerevise/features/maths/presentation/providers/chantier_provider.dart';
import 'package:jerevise/features/maths/presentation/widgets/building_progress.dart';
import 'package:jerevise/features/games/presentation/widgets/game_header.dart';
import 'package:jerevise/shared/widgets/colorful_button.dart';
import 'package:jerevise/shared/widgets/gradient_background.dart';

class ChantierGameScreen extends ConsumerWidget {
  final ChantierConfig config;

  const ChantierGameScreen({super.key, required this.config});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chantierProvider(config));
    final notifier = ref.read(chantierProvider(config).notifier);

    final problem = state.currentProblem;
    final step = state.currentStep;

    if (problem == null || step == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final progress = state.totalSteps > 0
        ? state.completedSteps / state.totalSteps
        : 0.0;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                  vertical: AppDimensions.paddingS,
                ),
                child: Row(
                  children: [
                    _CloseButton(onTap: () => Navigator.pop(context)),
                    const SizedBox(width: AppDimensions.spacingM),
                    Expanded(
                      child: GameHeader(
                        progress: progress,
                        validatedCount: state.completedSteps,
                        totalCount: state.totalSteps,
                        progressColor: AppColors.buttonCoral,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.spacingM),

              // Building + Problem title row
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    BuildingProgress(progress: state.buildingProgress),
                    const SizedBox(width: AppDimensions.spacingL),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            problem.title,
                            style: const TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: AppTypography.headingSmall,
                              fontWeight: AppTypography.bold,
                              color: AppColors.textOnColor,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spacingS),
                          Text(
                            'Problème ${state.problemIndex + 1}/${state.problems.length}',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: AppTypography.bodySmall,
                              fontWeight: AppTypography.regular,
                              color: AppColors.textOnColor.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.spacingXl),

              // Question card
              Expanded(
                child: Padding(
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Step question
                        Text(
                          step.question,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: AppTypography.bodyLarge,
                            fontWeight: AppTypography.semiBold,
                            color: AppColors.textPrimary,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: AppDimensions.spacingXxl),

                        // Answer options (4 buttons)
                        ...step.options.map((option) {
                          Color btnColor;
                          Color btnShadow;

                          if (state.showFeedback) {
                            if (option == step.correctAnswer) {
                              btnColor = AppColors.success;
                              btnShadow = AppColors.successShadow;
                            } else {
                              btnColor = AppColors.surface;
                              btnShadow = AppColors.primaryDark;
                            }
                          } else {
                            btnColor = AppColors.buttonCoral;
                            btnShadow = AppColors.buttonCoralShadow;
                          }

                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppDimensions.spacingM,
                            ),
                            child: _AnswerButton(
                              text: '$option',
                              color: btnColor,
                              shadowColor: btnShadow,
                              onTap: state.showFeedback
                                  ? null
                                  : () => notifier.answer(option),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingL),

              // Next button (after feedback)
              if (state.showFeedback)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingL,
                  ),
                  child: notifier.isFinished
                      ? ColorfulButton(
                          text: AppStrings.finish,
                          icon: Icons.check,
                          color: AppColors.buttonCoral,
                          shadowColor: AppColors.buttonCoralShadow,
                          width: double.infinity,
                          onTap: () => Navigator.pop(context),
                        )
                      : ColorfulButton(
                          text: AppStrings.next,
                          icon: Icons.arrow_forward,
                          color: AppColors.buttonCoral,
                          shadowColor: AppColors.buttonCoralShadow,
                          width: double.infinity,
                          onTap: () {
                            if (notifier.isLastStep) {
                              notifier.nextProblem();
                            } else {
                              notifier.nextStep();
                            }
                          },
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

class _AnswerButton extends StatefulWidget {
  final String text;
  final Color color;
  final Color shadowColor;
  final VoidCallback? onTap;

  const _AnswerButton({
    required this.text,
    required this.color,
    required this.shadowColor,
    this.onTap,
  });

  @override
  State<_AnswerButton> createState() => _AnswerButtonState();
}

class _AnswerButtonState extends State<_AnswerButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final textColor = widget.color == AppColors.surface
        ? AppColors.textSecondary
        : AppColors.textOnColor;

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: enabled
          ? (_) {
              setState(() => _isPressed = false);
              widget.onTap!();
            }
          : null,
      onTapCancel: enabled ? () => setState(() => _isPressed = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: double.infinity,
        height: 52,
        transform: Matrix4.translationValues(0, _isPressed ? 3 : 0, 0),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          boxShadow: [
            BoxShadow(
              color: widget.shadowColor,
              blurRadius: 0,
              offset: Offset(0, _isPressed ? 1 : 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            widget.text,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: AppTypography.headingSmall,
              fontWeight: AppTypography.bold,
              color: textColor,
            ),
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
