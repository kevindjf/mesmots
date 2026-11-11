import 'package:flutter/material.dart';
import 'package:jerevise/core/constants/app_colors.dart';
import 'package:jerevise/core/constants/app_dimensions.dart';
import 'package:jerevise/core/constants/app_typography.dart';

/// Custom AZERTY keyboard widget to prevent cheating via voice input
class AzertyKeyboard extends StatelessWidget {
  final ValueChanged<String> onLetterTap;
  final VoidCallback onBackspace;
  final bool showAccents;
  final bool showSpecialChars;

  const AzertyKeyboard({
    super.key,
    required this.onLetterTap,
    required this.onBackspace,
    this.showAccents = true,
    this.showSpecialChars = false,
  });

  static const _row1 = ['A', 'Z', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'];
  static const _row2 = ['Q', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'M'];
  static const _row3 = ['W', 'X', 'C', 'V', 'B', 'N'];
  static const _accents = ['É', 'È', 'Ê', 'Ë', 'À', 'Â', 'Ù', 'Û', 'Î', 'Ï', 'Ô', 'Ç'];
  static const _special = ['-', "'"];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Size keys to fit 10 per row with spacing
        const spacing = 4.0;
        final keySize = ((constraints.maxWidth - spacing * 11) / 10).clamp(28.0, 40.0);
        final accentKeySize = ((constraints.maxWidth - spacing * 13) / 12).clamp(24.0, 34.0);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row 1: AZERTYUIOP
            _buildRow(_row1, keySize, spacing),
            SizedBox(height: spacing),
            // Row 2: QSDFGHJKLM
            _buildRow(_row2, keySize, spacing),
            SizedBox(height: spacing),
            // Row 3: ⌫ WXCVBN ⌫
            _buildRowWithBackspace(_row3, keySize, spacing),
            if (showAccents) ...[
              SizedBox(height: spacing),
              _buildAccentRow(accentKeySize, spacing),
            ],
            if (showSpecialChars) ...[
              SizedBox(height: spacing),
              _buildRow(_special, keySize, spacing),
            ],
          ],
        );
      },
    );
  }

  Widget _buildRow(List<String> letters, double keySize, double spacing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: letters.map((letter) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing / 2),
          child: _KeyButton(
            label: letter,
            size: keySize,
            onTap: () => onLetterTap(letter.toLowerCase()),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRowWithBackspace(List<String> letters, double keySize, double spacing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing / 2),
          child: _BackspaceButton(size: keySize, onTap: onBackspace),
        ),
        ...letters.map((letter) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing / 2),
            child: _KeyButton(
              label: letter,
              size: keySize,
              onTap: () => onLetterTap(letter.toLowerCase()),
            ),
          );
        }),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing / 2),
          child: _BackspaceButton(size: keySize, onTap: onBackspace),
        ),
      ],
    );
  }

  Widget _buildAccentRow(double keySize, double spacing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _accents.map((letter) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing / 2),
          child: _KeyButton(
            label: letter,
            size: keySize,
            onTap: () => onLetterTap(letter.toLowerCase()),
            isAccent: true,
          ),
        );
      }).toList(),
    );
  }
}

/// Individual key button with 3D press effect
class _KeyButton extends StatefulWidget {
  final String label;
  final double size;
  final VoidCallback onTap;
  final bool isAccent;

  const _KeyButton({
    required this.label,
    required this.size,
    required this.onTap,
    this.isAccent = false,
  });

  @override
  State<_KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends State<_KeyButton> {
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
        width: widget.size,
        height: widget.size,
        transform: Matrix4.translationValues(0, _isPressed ? 2 : 0, 0),
        decoration: BoxDecoration(
          color: widget.isAccent
              ? AppColors.primaryLight
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          boxShadow: [
            BoxShadow(
              color: widget.isAccent
                  ? AppColors.primaryDark
                  : AppColors.primaryDark,
              blurRadius: 0,
              offset: Offset(0, _isPressed ? 1 : 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            widget.label,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: widget.size * 0.4,
              fontWeight: AppTypography.bold,
              color: widget.isAccent
                  ? AppColors.textPrimary
                  : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Backspace key button
class _BackspaceButton extends StatefulWidget {
  final double size;
  final VoidCallback onTap;

  const _BackspaceButton({
    required this.size,
    required this.onTap,
  });

  @override
  State<_BackspaceButton> createState() => _BackspaceButtonState();
}

class _BackspaceButtonState extends State<_BackspaceButton> {
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
        width: widget.size * 1.3,
        height: widget.size,
        transform: Matrix4.translationValues(0, _isPressed ? 2 : 0, 0),
        decoration: BoxDecoration(
          color: AppColors.buttonCoral,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          boxShadow: [
            BoxShadow(
              color: AppColors.buttonCoralShadow,
              blurRadius: 0,
              offset: Offset(0, _isPressed ? 1 : 3),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.backspace_outlined,
            size: widget.size * 0.45,
            color: AppColors.textOnColor,
          ),
        ),
      ),
    );
  }
}
