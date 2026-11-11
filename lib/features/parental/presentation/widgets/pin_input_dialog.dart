import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/features/parental/presentation/providers/parental_providers.dart';
import 'package:mesmots/features/parental/presentation/widgets/pin_keypad.dart';
import 'package:mesmots/shared/widgets/colorful_button.dart';

class PinInputDialog extends ConsumerStatefulWidget {
  const PinInputDialog({super.key});

  @override
  ConsumerState<PinInputDialog> createState() => _PinInputDialogState();
}

class _PinInputDialogState extends ConsumerState<PinInputDialog> {
  String _pin = '';
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        decoration: BoxDecoration(
          color: Colors.white,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            const Text(
              'Zone Adultes',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: AppTypography.headingMedium,
                fontWeight: AppTypography.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              _errorMessage ?? 'Entre le code pour continuer',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: AppTypography.bodyMedium,
                fontWeight: AppTypography.semiBold,
                color: _errorMessage != null
                    ? AppColors.error
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // PIN dots
            _buildPinDisplay(),
            const SizedBox(height: 32),

            // Keypad
            PinKeypad(
              onNumberPressed: _onNumberPressed,
              onDeletePressed: _onDeletePressed,
            ),
            const SizedBox(height: 24),

            // Cancel button
            ColorfulButton(
              text: AppStrings.cancel,
              color: AppColors.surface,
              shadowColor: AppColors.primaryDark,
              textColor: AppColors.primary,
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isFilled = index < _pin.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? AppColors.primary : AppColors.textLight,
          ),
        );
      }),
    );
  }

  void _onNumberPressed(int number) {
    if (_pin.length < 4) {
      setState(() {
        _pin += number.toString();
        _errorMessage = null;
      });

      if (_pin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onDeletePressed() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _errorMessage = null;
      });
    }
  }

  Future<void> _verifyPin() async {
    final operations = ref.read(parentalOperationsProvider.notifier);
    final isValid = await operations.verifyPin(_pin);

    if (!mounted) return;

    if (isValid) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        _pin = '';
        _errorMessage = AppStrings.wrongPin;
      });
    }
  }
}
