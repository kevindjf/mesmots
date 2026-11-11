import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jerevise/core/constants/app_colors.dart';
import 'package:jerevise/core/constants/app_dimensions.dart';
import 'package:jerevise/core/constants/app_typography.dart';
import 'package:jerevise/features/conjugation/domain/entities/quiz_config.dart';
import 'package:jerevise/features/conjugation/presentation/providers/relier_game_provider.dart';
import 'package:jerevise/features/conjugation/presentation/screens/conjugation_result_screen.dart';
import 'package:jerevise/features/games/presentation/widgets/game_header.dart';
import 'package:jerevise/shared/widgets/circle_icon_button.dart';
import 'package:jerevise/shared/widgets/gradient_background.dart';

class RelierGameScreen extends ConsumerWidget {
  final QuizConfig config;

  const RelierGameScreen({super.key, required this.config});

  static const _accentColor = AppColors.buttonPink;
  static const _accentShadow = AppColors.buttonPinkShadow;

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(relierGameProvider(config));
    final notifier = ref.read(relierGameProvider(config).notifier);

    if (state.rounds.isEmpty) {
      return const Scaffold(
        body: GradientBackground(
          child: Center(
            child: CircularProgressIndicator(color: AppColors.textOnColor),
          ),
        ),
      );
    }

    final round = state.rounds[state.roundIndex];
    final progress = (state.roundIndex + 1) / state.rounds.length;
    final isFinished = state.isFinished;

    // Navigate to result when finished
    if (isFinished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ConjugationResultScreen(
              score: state.score,
              total: state.rounds.length,
              gameTitle: 'Relier',
              accentColor: _accentColor,
              accentShadowColor: _accentShadow,
              onReplay: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RelierGameScreen(config: config),
                  ),
                );
              },
              onMenu: () =>
                  Navigator.popUntil(context, (r) => r.isFirst),
            ),
          ),
        );
      });
    }

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
                validatedCount: state.roundIndex + 1,
                totalCount: state.rounds.length,
                progressColor: _accentColor,
              ),

              const SizedBox(height: AppDimensions.spacingM),

              // Title: "Relie [verbe] au présent"
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingL,),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusXxl),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.primaryDark,
                        blurRadius: 0,
                        offset: Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: _accentColor.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: AppTypography.bodyLarge,
                        color: AppColors.textPrimary,
                      ),
                      children: [
                        const TextSpan(text: 'Relie '),
                        TextSpan(
                          text: round.verb.infinitive,
                          style: const TextStyle(
                            fontWeight: AppTypography.bold,
                            color: _accentColor,
                          ),
                        ),
                        const TextSpan(text: ' au présent'),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingXl),

              // Two columns: subjects ↔ forms
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingL,),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subjects column
                      Expanded(
                        child: Column(
                          children: round.subjects.map((s) {
                            final isMatched =
                                state.matchedSubjects.contains(s);
                            final isSelected =
                                state.selectedSubject == s;

                            return Padding(
                              padding: const EdgeInsets.only(
                                  bottom: AppDimensions.spacingM,),
                              child: _RelierChip(
                                text: s,
                                isMatched: isMatched,
                                isSelected: isSelected,
                                isFlashError: false,
                                baseColor: AppColors.surface,
                                baseShadow: AppColors.primaryDark,
                                textColor: AppColors.textPrimary,
                                onTap: isMatched
                                    ? null
                                    : () => notifier.selectSubject(s),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(width: AppDimensions.spacingM),

                      // Forms column
                      Expanded(
                        child: Column(
                          children: round.forms.map((f) {
                            final isMatched = state.matchedSubjects.any(
                                (s) => round.correctPairs[s] == f,);
                            final isFlash = state.flashError == f;

                            return Padding(
                              padding: const EdgeInsets.only(
                                  bottom: AppDimensions.spacingM,),
                              child: _RelierChip(
                                text: f,
                                isMatched: isMatched,
                                isSelected: false,
                                isFlashError: isFlash,
                                baseColor: _accentColor,
                                baseShadow: _accentShadow,
                                textColor: AppColors.textOnColor,
                                onTap: isMatched
                                    ? null
                                    : () => notifier.selectForm(f),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingM),
            ],
          ),
        ),
      ),
    );
  }
}

class _RelierChip extends StatefulWidget {
  final String text;
  final bool isMatched;
  final bool isSelected;
  final bool isFlashError;
  final Color baseColor;
  final Color baseShadow;
  final Color textColor;
  final VoidCallback? onTap;

  const _RelierChip({
    required this.text,
    required this.isMatched,
    required this.isSelected,
    required this.isFlashError,
    required this.baseColor,
    required this.baseShadow,
    required this.textColor,
    this.onTap,
  });

  @override
  State<_RelierChip> createState() => _RelierChipState();
}

class _RelierChipState extends State<_RelierChip> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color shadowColor;
    Color textColor;

    if (widget.isMatched) {
      bgColor = AppColors.success;
      shadowColor = AppColors.successShadow;
      textColor = AppColors.textOnColor;
    } else if (widget.isFlashError) {
      bgColor = AppColors.error;
      shadowColor = AppColors.errorShadow;
      textColor = AppColors.textOnColor;
    } else if (widget.isSelected) {
      bgColor = AppColors.buttonBlue;
      shadowColor = AppColors.buttonBlueShadow;
      textColor = AppColors.textOnColor;
    } else {
      bgColor = widget.baseColor;
      shadowColor = widget.baseShadow;
      textColor = widget.textColor;
    }

    return GestureDetector(
      onTapDown:
          widget.onTap != null ? (_) => setState(() => _isPressed = true) : null,
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
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.paddingM,
          horizontal: AppDimensions.paddingS,
        ),
        transform: Matrix4.translationValues(0, _isPressed ? 3 : 0, 0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 0,
              offset: Offset(0, _isPressed ? 2 : 5),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isMatched)
                const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Icon(Icons.check_circle,
                      size: 18, color: AppColors.textOnColor,),
                ),
              Flexible(
                child: Text(
                  widget.text,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: AppTypography.bodyLarge,
                    fontWeight: AppTypography.bold,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
