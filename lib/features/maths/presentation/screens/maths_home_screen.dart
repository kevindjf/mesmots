import 'package:flutter/material.dart';
import 'package:jerevise/core/constants/app_colors.dart';
import 'package:jerevise/core/constants/app_dimensions.dart';
import 'package:jerevise/core/constants/app_strings.dart';
import 'package:jerevise/core/constants/app_typography.dart';
import 'package:jerevise/features/maths/presentation/screens/duel_setup_screen.dart';
import 'package:jerevise/features/maths/presentation/screens/balance_game_screen.dart';
import 'package:jerevise/features/maths/presentation/screens/cascade_game_screen.dart';
import 'package:jerevise/features/maths/presentation/screens/chantier_game_screen.dart';
import 'package:jerevise/features/maths/domain/entities/math_config.dart';
import 'package:jerevise/features/maths/domain/entities/math_difficulty.dart';
import 'package:jerevise/shared/widgets/app_header.dart';
import 'package:jerevise/shared/widgets/back_button.dart';
import 'package:jerevise/shared/widgets/gradient_background.dart';

class MathsHomeScreen extends StatelessWidget {
  const MathsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppHeader(
                title: AppStrings.sectionMaths,
                subtitle: AppStrings.sectionMathsDesc.toUpperCase(),
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
                      icon: Icons.bolt,
                      title: AppStrings.mathsDuelExpress,
                      description: AppStrings.mathsDuelExpressDesc,
                      color: AppColors.buttonOrange,
                      shadowColor: AppColors.buttonOrangeShadow,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DuelSetupScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: AppDimensions.spacingL),

                    _SectionCard(
                      icon: Icons.balance,
                      title: AppStrings.mathsBalance,
                      description: AppStrings.mathsBalanceDesc,
                      color: AppColors.sectionMaths,
                      shadowColor: AppColors.sectionMathsShadow,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BalanceGameScreen(
                              config: BalanceConfig(
                                difficulty: MathDifficulty.ce1,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: AppDimensions.spacingL),

                    _SectionCard(
                      icon: Icons.sort,
                      title: AppStrings.mathsCascade,
                      description: AppStrings.mathsCascadeDesc,
                      color: AppColors.buttonBlue,
                      shadowColor: AppColors.buttonBlueShadow,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CascadeGameScreen(
                              config: CascadeConfig(
                                difficulty: MathDifficulty.ce1,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: AppDimensions.spacingL),

                    _SectionCard(
                      icon: Icons.construction,
                      title: AppStrings.mathsChantier,
                      description: AppStrings.mathsChantierDesc,
                      color: AppColors.buttonCoral,
                      shadowColor: AppColors.buttonCoralShadow,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChantierGameScreen(
                              config: ChantierConfig(
                                difficulty: MathDifficulty.ce1,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: AppDimensions.spacingXxl),
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
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                ),
                child: Center(
                  child: Icon(
                    widget.icon,
                    size: 40,
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
