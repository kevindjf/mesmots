import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/features/parental/presentation/providers/parental_providers.dart';
import 'package:mesmots/features/parental/presentation/widgets/pin_entry.dart';
import 'package:mesmots/shared/widgets/colorful_button.dart';

class PinInputDialog extends ConsumerStatefulWidget {
  const PinInputDialog({super.key});

  @override
  ConsumerState<PinInputDialog> createState() => _PinInputDialogState();
}

class _PinInputDialogState extends ConsumerState<PinInputDialog> {
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
            const Text(
              'Entre le code pour continuer',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: AppTypography.bodyMedium,
                fontWeight: AppTypography.semiBold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            PinEntry(
              validate: (pin) =>
                  ref.read(parentalOperationsProvider.notifier).verifyPin(pin),
              onAccepted: (_) => Navigator.pop(context, true),
              errorMessage: AppStrings.wrongPin,
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
}
