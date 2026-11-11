import 'package:flutter/material.dart';
import 'package:jerevise/core/constants/app_colors.dart';
import 'package:jerevise/core/constants/app_dimensions.dart';
import 'package:jerevise/core/constants/app_typography.dart';
import 'package:jerevise/features/conjugation/domain/entities/conjugation_constants.dart';
import 'package:jerevise/features/conjugation/domain/entities/quiz_config.dart';
import 'package:jerevise/features/conjugation/presentation/screens/phrase_game_screen.dart';
import 'package:jerevise/features/conjugation/presentation/screens/quiz_game_screen.dart';
import 'package:jerevise/features/conjugation/presentation/screens/relier_game_screen.dart';
import 'package:jerevise/features/conjugation/presentation/screens/terminaison_game_screen.dart';
import 'package:jerevise/shared/widgets/app_header.dart';
import 'package:jerevise/shared/widgets/back_button.dart';
import 'package:jerevise/shared/widgets/gradient_background.dart';

class ConjugationHomeScreen extends StatelessWidget {
  const ConjugationHomeScreen({super.key});

  /// Default config used when launching games directly from home.
  static const _defaultConfig = QuizConfig(
    selectedVerbs: {},
    timeLimit: ConjugationConstants.defaultTimeLimit,
    numberQuestions: ConjugationConstants.defaultQuestionCount,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppHeader(
                title: 'Conjugaison',
                subtitle: 'MAÎTRISE LES VERBES',
                leading: BackButton3D(onTap: () => Navigator.pop(context)),
              ),

              const SizedBox(height: AppDimensions.spacingL),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingL,
                  ),
                  children: [
                    _SectionCard(
                      icon: Icons.quiz,
                      title: 'Quiz',
                      description: 'Choisis la bonne conjugaison\nparmi 4 propositions.',
                      color: AppColors.buttonBlue,
                      shadowColor: AppColors.buttonBlueShadow,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const QuizGameScreen(config: _defaultConfig),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spacingL),

                    _SectionCard(
                      icon: Icons.auto_fix_high,
                      title: 'Terminaisons',
                      description: 'Trouve la bonne terminaison\npour compléter le verbe.',
                      color: AppColors.buttonOrange,
                      shadowColor: AppColors.buttonOrangeShadow,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TerminaisonGameScreen(
                              config: _defaultConfig,),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spacingL),

                    _SectionCard(
                      icon: Icons.compare_arrows,
                      title: 'Relier',
                      description: 'Associe chaque sujet\nà la bonne forme.',
                      color: AppColors.buttonPink,
                      shadowColor: AppColors.buttonPinkShadow,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const RelierGameScreen(config: _defaultConfig),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spacingL),

                    _SectionCard(
                      icon: Icons.short_text,
                      title: 'Phrase à Trous',
                      description: 'Complète la phrase\navec le bon verbe conjugué.',
                      color: AppColors.buttonMagenta,
                      shadowColor: AppColors.buttonMagentaShadow,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const PhraseGameScreen(config: _defaultConfig),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spacingXl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final Color shadowColor;
  final VoidCallback onTap;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.shadowColor,
    required this.onTap,
  });

  @override
  State<_SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<_SectionCard> {
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
        transform: Matrix4.translationValues(0, _isPressed ? 4 : 0, 0),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          boxShadow: [
            BoxShadow(
              color: widget.shadowColor,
              blurRadius: 0,
              offset: Offset(0, _isPressed ? 2 : 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingXl),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.25),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusL),
                ),
                child: Center(
                  child: Icon(
                    widget.icon,
                    size: 36,
                    color: AppColors.textOnColor,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingL),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: AppTypography.headingSmall,
                        fontWeight: AppTypography.bold,
                        color: AppColors.textOnColor,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingS),
                    Text(
                      widget.description,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: AppTypography.bodySmall,
                        fontWeight: AppTypography.regular,
                        color: AppColors.textOnColor.withValues(alpha: 0.9),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textOnColor,
                size: AppDimensions.iconM,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
