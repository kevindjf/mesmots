import 'package:flutter/material.dart';
import 'package:jerevise/core/constants/app_colors.dart';
import 'package:jerevise/core/constants/app_dimensions.dart';
import 'package:jerevise/core/constants/app_typography.dart';

class NumericKeypad extends StatelessWidget {
  final ValueChanged<int> onDigit;
  final VoidCallback onDelete;
  final VoidCallback onValidate;

  const NumericKeypad({
    super.key,
    required this.onDigit,
    required this.onDelete,
    required this.onValidate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow([1, 2, 3]),
        const SizedBox(height: AppDimensions.spacingS),
        _buildRow([4, 5, 6]),
        const SizedBox(height: AppDimensions.spacingS),
        _buildRow([7, 8, 9]),
        const SizedBox(height: AppDimensions.spacingS),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _KeypadButton(
              color: AppColors.surface,
              shadowColor: AppColors.primaryDark,
              onTap: onDelete,
              child: const Icon(Icons.backspace_outlined, color: AppColors.textPrimary, size: 28),
            ),
            const SizedBox(width: AppDimensions.spacingS),
            _KeypadButton(
              color: AppColors.surface,
              shadowColor: AppColors.primaryDark,
              onTap: () => onDigit(0),
              child: const Text(
                '0',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: AppTypography.headingMedium,
                  fontWeight: AppTypography.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingS),
            _KeypadButton(
              color: AppColors.success,
              shadowColor: AppColors.successShadow,
              onTap: onValidate,
              child: const Icon(Icons.check, color: AppColors.textOnColor, size: 28),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(List<int> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: digits
          .map((d) => Padding(
                padding: EdgeInsets.only(
                  right: d != digits.last ? AppDimensions.spacingS : 0,
                ),
                child: _KeypadButton(
                  color: AppColors.surface,
                  shadowColor: AppColors.primaryDark,
                  onTap: () => onDigit(d),
                  child: Text(
                    '$d',
                    style: const TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: AppTypography.headingMedium,
                      fontWeight: AppTypography.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),)
          .toList(),
    );
  }
}

class _KeypadButton extends StatefulWidget {
  final Widget child;
  final Color color;
  final Color shadowColor;
  final VoidCallback onTap;

  const _KeypadButton({
    required this.child,
    required this.color,
    required this.shadowColor,
    required this.onTap,
  });

  @override
  State<_KeypadButton> createState() => _KeypadButtonState();
}

class _KeypadButtonState extends State<_KeypadButton> {
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
        width: 72,
        height: 64,
        transform: Matrix4.translationValues(0, _isPressed ? 3 : 0, 0),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          boxShadow: [
            BoxShadow(
              color: widget.shadowColor,
              blurRadius: 0,
              offset: Offset(0, _isPressed ? 1 : 4),
            ),
          ],
        ),
        child: Center(child: widget.child),
      ),
    );
  }
}
