import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/features/parental/presentation/providers/parental_providers.dart';
import 'package:mesmots/features/parental/presentation/widgets/pin_keypad.dart';

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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              AppStrings.enterPin,
              style: TextStyle(
                fontSize: AppTypography.headingMedium,
                fontWeight: AppTypography.semiBold,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXl),
            _buildPinDisplay(),
            if (_errorMessage != null) ...[
              const SizedBox(height: AppDimensions.spacingM),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: AppTypography.bodyMedium,
                ),
              ),
            ],
            const SizedBox(height: AppDimensions.spacingXl),
            PinKeypad(
              onNumberPressed: _onNumberPressed,
              onDeletePressed: _onDeletePressed,
            ),
            const SizedBox(height: AppDimensions.spacingL),
            TextButton(
              onPressed: () {
                // TODO: Show recovery dialog
                Navigator.pop(context);
              },
              child: const Text(AppStrings.forgotPin),
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
          margin: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingS,
          ),
          width: 16,
          height: 16,
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
