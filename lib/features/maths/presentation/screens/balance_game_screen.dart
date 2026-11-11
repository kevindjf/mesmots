import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jerevise/core/constants/app_colors.dart';
import 'package:jerevise/core/constants/app_dimensions.dart';
import 'package:jerevise/core/constants/app_strings.dart';
import 'package:jerevise/core/constants/app_typography.dart';
import 'package:jerevise/features/maths/domain/entities/math_config.dart';
import 'package:jerevise/features/maths/presentation/providers/balance_provider.dart';
import 'package:jerevise/features/maths/presentation/widgets/balance_widget.dart';
import 'package:jerevise/features/maths/presentation/widgets/number_tile.dart';
import 'package:jerevise/features/games/presentation/widgets/game_header.dart';
import 'package:jerevise/shared/widgets/colorful_button.dart';
import 'package:jerevise/shared/widgets/gradient_background.dart';

class BalanceGameScreen extends ConsumerWidget {
  final BalanceConfig config;

  const BalanceGameScreen({super.key, required this.config});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(balanceMagiqueProvider(config));
    final notifier = ref.read(balanceMagiqueProvider(config).notifier);

    if (state.questions.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final question = state.questions[state.index];
    final progress = (state.index + 1) / state.questions.length;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header row
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
                        validatedCount: state.index + 1,
                        totalCount: state.questions.length,
                        progressColor: AppColors.sectionMaths,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.spacingL),

              // Instruction
              Text(
                'Fais la somme de ${question.targetValue}',
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: AppTypography.headingSmall,
                  fontWeight: AppTypography.bold,
                  color: AppColors.textOnColor,
                ),
              ),

              const SizedBox(height: AppDimensions.spacingXl),

              // Balance widget
              BalanceWidget(
                targetValue: question.targetValue,
                currentSum: state.selectedSum,
              ),

              const SizedBox(height: AppDimensions.spacingXl),

              // Tiles
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                ),
                child: Wrap(
                  spacing: AppDimensions.spacingM,
                  runSpacing: AppDimensions.spacingM,
                  alignment: WrapAlignment.center,
                  children: List.generate(question.availableTiles.length, (i) {
                    return NumberTile(
                      value: question.availableTiles[i],
                      isSelected: state.selectedIndices.contains(i),
                      onTap: () => notifier.toggleTile(i),
                    );
                  }),
                ),
              ),

              const Spacer(),

              // Feedback
              if (state.showFeedback)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingL,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    decoration: BoxDecoration(
                      color: state.lastCorrect
                          ? AppColors.success.withValues(alpha: 0.15)
                          : AppColors.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    ),
                    child: Text(
                      state.lastCorrect
                          ? 'Bravo ! La balance est équilibrée !'
                          : 'Pas tout à fait... Essaie encore !',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: AppTypography.bodyLarge,
                        fontWeight: AppTypography.semiBold,
                        color: state.lastCorrect
                            ? AppColors.successDark
                            : AppColors.errorDark,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: AppDimensions.spacingL),

              // Action button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                ),
                child: state.showFeedback
                    ? notifier.isFinished
                        ? ColorfulButton(
                            text: AppStrings.finish,
                            icon: Icons.check,
                            color: AppColors.sectionMaths,
                            shadowColor: AppColors.sectionMathsShadow,
                            width: double.infinity,
                            onTap: () => Navigator.pop(context),
                          )
                        : ColorfulButton(
                            text: AppStrings.next,
                            icon: Icons.arrow_forward,
                            color: AppColors.sectionMaths,
                            shadowColor: AppColors.sectionMathsShadow,
                            width: double.infinity,
                            onTap: () => notifier.next(),
                          )
                    : ColorfulButton(
                        text: AppStrings.validate,
                        icon: Icons.check,
                        color: AppColors.sectionMaths,
                        shadowColor: AppColors.sectionMathsShadow,
                        width: double.infinity,
                        onTap: state.selectedIndices.isEmpty
                            ? null
                            : () => notifier.validate(),
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
