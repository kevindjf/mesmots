import 'package:flutter/material.dart';
import 'package:jerevise/core/constants/app_colors.dart';
import 'package:jerevise/core/constants/app_dimensions.dart';
import 'package:jerevise/core/constants/app_strings.dart';
import 'package:jerevise/core/constants/app_typography.dart';
import 'package:jerevise/features/maths/domain/entities/math_config.dart';
import 'package:jerevise/features/maths/domain/entities/math_difficulty.dart';
import 'package:jerevise/features/maths/domain/entities/math_operation.dart';
import 'package:jerevise/features/maths/presentation/screens/duel_game_screen.dart';
import 'package:jerevise/shared/widgets/app_header.dart';
import 'package:jerevise/shared/widgets/back_button.dart';
import 'package:jerevise/shared/widgets/colorful_button.dart';
import 'package:jerevise/shared/widgets/gradient_background.dart';

class DuelSetupScreen extends StatefulWidget {
  final DuelExpressConfig? previousConfig;

  const DuelSetupScreen({super.key, this.previousConfig});

  @override
  State<DuelSetupScreen> createState() => _DuelSetupScreenState();
}

class _DuelSetupScreenState extends State<DuelSetupScreen> {
  MathDifficulty _difficulty = MathDifficulty.ce1;
  Set<MathOperationType> _operations = {MathOperationType.addition};
  int _timePerQuestion = 10;
  int _questionCount = 10;

  static const _timeLimits = [5, 10, 15, 20];
  static const _questionCounts = [5, 10, 15, 20];

  @override
  void initState() {
    super.initState();
    if (widget.previousConfig != null) {
      _difficulty = widget.previousConfig!.difficulty;
      _operations = widget.previousConfig!.operations.toSet();
      _timePerQuestion = widget.previousConfig!.timePerQuestion;
      _questionCount = widget.previousConfig!.questionCount;
    }
  }

  void _start() {
    if (_operations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choisis au moins une opération'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final config = DuelExpressConfig(
      difficulty: _difficulty,
      operations: _operations.toList(),
      timePerQuestion: _timePerQuestion,
      questionCount: _questionCount,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DuelGameScreen(config: config),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppHeader(
                title: AppStrings.mathsDuelExpress,
                subtitle: 'CONFIGURATION',
                leading: BackButton3D(onTap: () => Navigator.pop(context)),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingL,
                    vertical: AppDimensions.paddingM,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppDimensions.spacingM),

                      // Difficulty
                      _SettingsCard(
                        title: AppStrings.mathsSelectDifficulty,
                        child: Wrap(
                          spacing: AppDimensions.spacingS,
                          children: MathDifficulty.values.map((d) {
                            return _OptionPill(
                              label: d.displayName,
                              isSelected: _difficulty == d,
                              onTap: () {
                                setState(() {
                                  _difficulty = d;
                                  // Reset operations to allowed ones
                                  _operations.retainAll(d.allowedOperations);
                                  if (_operations.isEmpty) {
                                    _operations = {d.allowedOperations.first};
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: AppDimensions.spacingL),

                      // Operations
                      _SettingsCard(
                        title: AppStrings.mathsSelectOperations,
                        child: Wrap(
                          spacing: AppDimensions.spacingS,
                          children: _difficulty.allowedOperations.map((op) {
                            return _OptionPill(
                              label: '${op.symbol} ${op.displayName}',
                              isSelected: _operations.contains(op),
                              onTap: () {
                                setState(() {
                                  if (_operations.contains(op)) {
                                    if (_operations.length > 1) {
                                      _operations.remove(op);
                                    }
                                  } else {
                                    _operations.add(op);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: AppDimensions.spacingL),

                      // Time per question
                      _SettingsCard(
                        title: '${AppStrings.mathsTimePerQuestion} (s)',
                        child: Wrap(
                          spacing: AppDimensions.spacingS,
                          children: _timeLimits.map((t) {
                            return _OptionPill(
                              label: '${t}s',
                              isSelected: _timePerQuestion == t,
                              onTap: () => setState(() => _timePerQuestion = t),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: AppDimensions.spacingL),

                      // Question count
                      _SettingsCard(
                        title: AppStrings.mathsQuestionCount,
                        child: Wrap(
                          spacing: AppDimensions.spacingS,
                          children: _questionCounts.map((c) {
                            return _OptionPill(
                              label: '$c',
                              isSelected: _questionCount == c,
                              onTap: () => setState(() => _questionCount = c),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: AppDimensions.spacingXxl),

                      // Start button
                      ColorfulButton(
                        text: AppStrings.mathsStart,
                        icon: Icons.bolt,
                        color: AppColors.buttonOrange,
                        shadowColor: AppColors.buttonOrangeShadow,
                        width: double.infinity,
                        onTap: _start,
                      ),

                      const SizedBox(height: AppDimensions.spacingXl),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SettingsCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        boxShadow: const [
          BoxShadow(
            color: AppColors.primaryDark,
            blurRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: AppTypography.bodySmall,
              fontWeight: AppTypography.bold,
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          child,
        ],
      ),
    );
  }
}

class _OptionPill extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_OptionPill> createState() => _OptionPillState();
}

class _OptionPillState extends State<_OptionPill> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isSelected ? AppColors.sectionMaths : AppColors.surface;
    final shadow = widget.isSelected ? AppColors.sectionMathsShadow : AppColors.primaryDark;
    final textColor = widget.isSelected ? AppColors.textOnColor : AppColors.textPrimary;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(0, _isPressed ? 2 : 0, 0),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingS,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          boxShadow: [
            BoxShadow(
              color: shadow,
              blurRadius: 0,
              offset: Offset(0, _isPressed ? 1 : 3),
            ),
          ],
        ),
        child: Text(
          widget.label,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: AppTypography.bodyMedium,
            fontWeight: AppTypography.semiBold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
