import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jerevise/core/constants/app_colors.dart';
import 'package:jerevise/core/constants/app_dimensions.dart';
import 'package:jerevise/core/constants/app_strings.dart';
import 'package:jerevise/core/constants/app_typography.dart';
import 'package:jerevise/features/maths/domain/entities/math_config.dart';
import 'package:jerevise/features/maths/presentation/providers/cascade_provider.dart';
import 'package:jerevise/features/maths/presentation/widgets/number_line.dart';
import 'package:jerevise/features/maths/presentation/widgets/number_tile.dart';
import 'package:jerevise/features/games/presentation/widgets/game_header.dart';
import 'package:jerevise/shared/widgets/colorful_button.dart';
import 'package:jerevise/shared/widgets/gradient_background.dart';

class CascadeGameScreen extends ConsumerWidget {
  final CascadeConfig config;

  const CascadeGameScreen({super.key, required this.config});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cascadeNombresProvider(config));
    final notifier = ref.read(cascadeNombresProvider(config).notifier);

    if (state.rounds.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final progress = (state.roundIndex + 1) / state.rounds.length;
    final instruction = state.ascending
        ? 'Range du plus petit au plus grand'
        : 'Range du plus grand au plus petit';

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
                        validatedCount: state.roundIndex + 1,
                        totalCount: state.rounds.length,
                        progressColor: AppColors.buttonBlue,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.spacingXl),

              // Instruction
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                ),
                child: Text(
                  instruction,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: AppTypography.headingSmall,
                    fontWeight: AppTypography.bold,
                    color: AppColors.textOnColor,
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingXxl),

              // Number line (drop targets)
              NumberLine(
                placedNumbers: state.placedNumbers,
                selectedNumber: state.selectedNumber,
                onPositionTap: (pos) {
                  if (state.placedNumbers[pos] != null) {
                    notifier.removeFromPosition(pos);
                  } else {
                    notifier.placeAtPosition(pos);
                  }
                },
              ),

              const SizedBox(height: AppDimensions.spacingXxl),

              // Arrow indicator
              Icon(
                state.ascending ? Icons.arrow_forward : Icons.arrow_back,
                size: 32,
                color: AppColors.textOnColor.withValues(alpha: 0.6),
              ),

              const SizedBox(height: AppDimensions.spacingXl),

              // Available numbers
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                ),
                child: Wrap(
                  spacing: AppDimensions.spacingM,
                  runSpacing: AppDimensions.spacingM,
                  alignment: WrapAlignment.center,
                  children: state.availableNumbers.map((n) {
                    final isSelected = state.selectedNumber == n;
                    return NumberTile(
                      value: n,
                      isSelected: isSelected,
                      color: isSelected ? AppColors.buttonBlue : null,
                      shadowColor: isSelected ? AppColors.buttonBlueShadow : null,
                      onTap: () => notifier.selectNumber(n),
                    );
                  }).toList(),
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
                          ? 'Parfait ! Bien rangé !'
                          : 'Pas dans le bon ordre... Essaie encore !',
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
                            color: AppColors.buttonBlue,
                            shadowColor: AppColors.buttonBlueShadow,
                            width: double.infinity,
                            onTap: () => Navigator.pop(context),
                          )
                        : ColorfulButton(
                            text: AppStrings.next,
                            icon: Icons.arrow_forward,
                            color: AppColors.buttonBlue,
                            shadowColor: AppColors.buttonBlueShadow,
                            width: double.infinity,
                            onTap: () => notifier.next(),
                          )
                    : ColorfulButton(
                        text: AppStrings.validate,
                        icon: Icons.check,
                        color: AppColors.buttonBlue,
                        shadowColor: AppColors.buttonBlueShadow,
                        width: double.infinity,
                        onTap: state.placedNumbers.any((n) => n == null)
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
