import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/features/parental/presentation/providers/parental_providers.dart';
import 'package:mesmots/features/word_lists/presentation/screens/home_screen.dart';
import 'package:mesmots/shared/widgets/circle_icon_button.dart';
import 'package:mesmots/shared/widgets/colorful_button.dart';
import 'package:mesmots/shared/widgets/gradient_background.dart';

class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  int _currentStep = 0;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      if (_pinController.text.length == 4) {
        setState(() => _currentStep = 2);
      } else {
        _showError('Le code PIN doit contenir 4 chiffres');
      }
    } else if (_currentStep == 2) {
      if (_confirmPinController.text == _pinController.text) {
        _completeSetup();
      } else {
        _showError('Les codes PIN ne correspondent pas');
        _confirmPinController.clear();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _completeSetup() async {
    final operations = ref.read(parentalOperationsProvider.notifier);

    try {
      await operations.configurePin(_pinController.text);
      ref.read(parentalModeProvider.notifier).activate();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      _showError('Erreur lors de la configuration: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: AppTypography.fontFamily,
          ),
        ),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              if (_currentStep > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingL,
                    vertical: AppDimensions.paddingM,
                  ),
                  child: Row(
                    children: [
                      CircleIconButton.surface(
                        icon: Icons.arrow_back,
                        onTap: _previousStep,
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingXl),
                  child: _buildCurrentStep(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildWelcomeStep();
      case 1:
        return _buildPinCreationStep();
      case 2:
        return _buildPinConfirmationStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildWelcomeStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        const Icon(
          Icons.school,
          size: 80,
          color: AppColors.textOnColor,
        ),
        const SizedBox(height: AppDimensions.spacingXl),
        const Text(
          'Bienvenue dans MesMots !',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: AppTypography.headingLarge,
            fontWeight: AppTypography.bold,
            color: AppColors.textOnColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.spacingL),
        const Text(
          'L\'application d\'apprentissage ludique pour les enfants',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: AppTypography.bodyLarge,
            fontWeight: AppTypography.regular,
            color: AppColors.textOnColor,
          ),
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        ColorfulButton.orange(
          text: 'Commencer',
          icon: Icons.arrow_forward,
          width: double.infinity,
          onTap: _nextStep,
        ),
        const SizedBox(height: AppDimensions.spacingXl),
      ],
    );
  }

  Widget _buildPinCreationStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: AppColors.buttonBlue,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.buttonBlueShadow,
                blurRadius: 0,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.lock_outline,
            size: 40,
            color: AppColors.textOnColor,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingXl),
        const Text(
          'Code Parental',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: AppTypography.headingLarge,
            fontWeight: AppTypography.bold,
            color: AppColors.textOnColor,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingL),
        const Text(
          'Créez un code PIN à 4 chiffres pour protéger l\'accès aux paramètres',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: AppTypography.bodyLarge,
            fontWeight: AppTypography.regular,
            color: AppColors.textOnColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.spacingXxl),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            boxShadow: const [
              BoxShadow(
                color: AppColors.primaryDark,
                blurRadius: 0,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            obscureText: true,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 32,
              letterSpacing: 16,
              fontWeight: AppTypography.bold,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: '••••',
              hintStyle: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                color: AppColors.textLight,
              ),
              counterText: '',
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
            onChanged: (value) {
              if (value.length == 4) {
                _nextStep();
              }
            },
          ),
        ),
        const Spacer(),
        const SizedBox(height: AppDimensions.spacingXl),
      ],
    );
  }

  Widget _buildPinConfirmationStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: AppColors.buttonBlue,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.buttonBlueShadow,
                blurRadius: 0,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.lock_outline,
            size: 40,
            color: AppColors.textOnColor,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingXl),
        const Text(
          'Confirmer le code',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: AppTypography.headingLarge,
            fontWeight: AppTypography.bold,
            color: AppColors.textOnColor,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingL),
        const Text(
          'Saisissez à nouveau votre code PIN',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: AppTypography.bodyLarge,
            fontWeight: AppTypography.regular,
            color: AppColors.textOnColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.spacingXxl),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            boxShadow: const [
              BoxShadow(
                color: AppColors.primaryDark,
                blurRadius: 0,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _confirmPinController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            obscureText: true,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 32,
              letterSpacing: 16,
              fontWeight: AppTypography.bold,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: '••••',
              hintStyle: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                color: AppColors.textLight,
              ),
              counterText: '',
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
            onChanged: (value) {
              if (value.length == 4) {
                _nextStep();
              }
            },
          ),
        ),
        const Spacer(),
        const SizedBox(height: AppDimensions.spacingXl),
      ],
    );
  }
}
