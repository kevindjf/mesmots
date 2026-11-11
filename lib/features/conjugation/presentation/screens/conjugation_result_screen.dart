import 'package:flutter/material.dart';
import 'package:jerevise/core/constants/app_colors.dart';
import 'package:jerevise/core/constants/app_dimensions.dart';
import 'package:jerevise/core/constants/app_typography.dart';
import 'package:jerevise/shared/widgets/colorful_button.dart';
import 'package:jerevise/shared/widgets/gradient_background.dart';

/// Generic result screen shared by all conjugation games (except Quiz which
/// has its own with config-based replay).
class ConjugationResultScreen extends StatelessWidget {
  final int score;
  final int total;
  final String gameTitle;
  final Color accentColor;
  final Color accentShadowColor;
  final VoidCallback onReplay;
  final VoidCallback onMenu;

  const ConjugationResultScreen({
    super.key,
    required this.score,
    required this.total,
    required this.gameTitle,
    required this.accentColor,
    required this.accentShadowColor,
    required this.onReplay,
    required this.onMenu,
  });

  int get _percentage => total > 0 ? ((score / total) * 100).round() : 0;
  int get _errors => total - score;

  String get _message {
    if (_percentage >= 90) return 'Incroyable ! Tu es un champion !';
    if (_percentage >= 80) return 'Excellent travail ! Continue !';
    if (_percentage >= 70) return 'Bravo ! Tu progresses bien !';
    if (_percentage >= 60) return 'Bien joué ! Encore un effort !';
    if (_percentage >= 50) return 'Pas mal ! Continue de t\'entraîner !';
    return 'Continue d\'essayer, tu vas y arriver !';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Back button
              Padding(
                padding: const EdgeInsets.only(
                  left: AppDimensions.paddingL,
                  top: AppDimensions.spacingS,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _BackButton(
                    onTap: () =>
                        Navigator.popUntil(context, (r) => r.isFirst),
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingM),

              // Title
              Center(
                child: Text(
                  gameTitle.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: AppTypography.headingSmall,
                    fontWeight: AppTypography.bold,
                    color: AppColors.textOnColor,
                    letterSpacing: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingM),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingL,
                    vertical: AppDimensions.paddingM,
                  ),
                  child: Column(
                    children: [
                      // Result card
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusXxl),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.primaryDark,
                              blurRadius: 0,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.all(AppDimensions.paddingXl),
                          child: Column(
                            children: [
                              Text(
                                '$score / $total',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 52,
                                  fontWeight: AppTypography.bold,
                                  color: accentColor,
                                ),
                              ),
                              Text(
                                '$_percentage%',
                                style: const TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: AppTypography.headingMedium,
                                  fontWeight: AppTypography.semiBold,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: AppDimensions.spacingL),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(
                                    AppDimensions.paddingM,),
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusL,),
                                ),
                                child: Text(
                                  _message,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: AppTypography.bodyMedium,
                                    fontWeight: AppTypography.semiBold,
                                    color: accentColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppDimensions.spacingXl),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _StatItem(
                                    icon: Icons.check_circle,
                                    label: 'Bonnes',
                                    value: '$score',
                                    color: AppColors.success,
                                  ),
                                  _StatItem(
                                    icon: Icons.cancel,
                                    label: 'Erreurs',
                                    value: '$_errors',
                                    color: AppColors.error,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: AppDimensions.spacingXxl),

                      // Replay
                      ColorfulButton(
                        text: 'REJOUER',
                        icon: Icons.refresh,
                        color: AppColors.success,
                        shadowColor: AppColors.successShadow,
                        width: double.infinity,
                        onTap: onReplay,
                      ),

                      const SizedBox(height: AppDimensions.spacingL),

                      // Menu
                      _OutlineButton(
                        text: 'MENU PRINCIPAL',
                        onTap: onMenu,
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

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: AppDimensions.iconL),
        const SizedBox(height: AppDimensions.spacingS),
        Text(
          value,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: AppTypography.headingMedium,
            fontWeight: AppTypography.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: AppTypography.bodySmall,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _OutlineButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _OutlineButton({required this.text, required this.onTap});

  @override
  State<_OutlineButton> createState() => _OutlineButtonState();
}

class _OutlineButtonState extends State<_OutlineButton> {
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
        transform: Matrix4.translationValues(0, _isPressed ? 2 : 0, 0),
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          border: Border.all(color: AppColors.textOnColor, width: 2),
        ),
        child: Center(
          child: Text(
            widget.text,
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: AppTypography.bodyMedium,
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

class _BackButton extends StatefulWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
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
          Icons.arrow_back,
          color: AppColors.primary,
          size: AppDimensions.iconM,
        ),
      ),
    );
  }
}
