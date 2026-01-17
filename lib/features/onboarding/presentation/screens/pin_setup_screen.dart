import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/features/parental/presentation/providers/parental_providers.dart';
import 'package:mesmots/features/word_lists/presentation/screens/home_screen.dart';

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
      // Welcome -> PIN creation
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      // PIN creation -> PIN confirmation
      if (_pinController.text.length == 4) {
        setState(() => _currentStep = 2);
      } else {
        _showError('Le code PIN doit contenir 4 chiffres');
      }
    } else if (_currentStep == 2) {
      // PIN confirmation -> Complete
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

      // Activate parental mode
      ref.read(parentalModeProvider.notifier).activate();

      if (mounted) {
        // Navigate to home screen
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
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentStep > 0
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousStep,
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingXl),
          child: _buildCurrentStep(),
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
        const Text(
          '🎒',
          style: TextStyle(fontSize: 80),
        ),
        const SizedBox(height: AppDimensions.spacingXl),
        const Text(
          'Bienvenue dans MesMots !',
          style: TextStyle(
            fontSize: AppTypography.headingLarge,
            fontWeight: AppTypography.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.spacingL),
        const Text(
          'L\'application d\'apprentissage ludique des mots de dictée',
          style: TextStyle(
            fontSize: AppTypography.bodyLarge,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.paddingL,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              ),
            ),
            child: const Text(
              'Commencer',
              style: TextStyle(
                fontSize: AppTypography.bodyLarge,
                fontWeight: AppTypography.semiBold,
              ),
            ),
          ),
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
        const Icon(
          Icons.lock_outline,
          size: 80,
          color: AppColors.primary,
        ),
        const SizedBox(height: AppDimensions.spacingXl),
        const Text(
          'Code Parental',
          style: TextStyle(
            fontSize: AppTypography.headingLarge,
            fontWeight: AppTypography.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingL),
        const Text(
          'Créez un code PIN à 4 chiffres pour protéger l\'accès aux paramètres',
          style: TextStyle(
            fontSize: AppTypography.bodyLarge,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.spacingXxl),
        TextField(
          controller: _pinController,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 32,
            letterSpacing: 16,
            fontWeight: AppTypography.bold,
          ),
          decoration: const InputDecoration(
            hintText: '••••',
            counterText: '',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            if (value.length == 4) {
              _nextStep();
            }
          },
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
        const Icon(
          Icons.lock_outline,
          size: 80,
          color: AppColors.primary,
        ),
        const SizedBox(height: AppDimensions.spacingXl),
        const Text(
          'Confirmer le code',
          style: TextStyle(
            fontSize: AppTypography.headingLarge,
            fontWeight: AppTypography.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingL),
        const Text(
          'Saisissez à nouveau votre code PIN',
          style: TextStyle(
            fontSize: AppTypography.bodyLarge,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.spacingXxl),
        TextField(
          controller: _confirmPinController,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 32,
            letterSpacing: 16,
            fontWeight: AppTypography.bold,
          ),
          decoration: const InputDecoration(
            hintText: '••••',
            counterText: '',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            if (value.length == 4) {
              _nextStep();
            }
          },
        ),
        const Spacer(),
        const SizedBox(height: AppDimensions.spacingXl),
      ],
    );
  }
}
