import 'package:flutter/material.dart';
import 'package:jerevise/core/constants/app_colors.dart';
import 'package:jerevise/core/constants/app_typography.dart';

/// Round keypad button with 3D press effect, used in PIN input
class KeypadButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;
  final Color backgroundColor;
  final Color shadowColor;
  final double size;

  const KeypadButton({
    super.key,
    required this.onTap,
    required this.child,
    this.backgroundColor = Colors.white,
    this.shadowColor = AppColors.primaryDark,
    this.size = 70,
  });

  /// Number button with primary color text
  factory KeypadButton.number({
    Key? key,
    required int number,
    required VoidCallback onTap,
  }) {
    return KeypadButton(
      key: key,
      onTap: onTap,
      child: Text(
        number.toString(),
        style: const TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 28,
          fontWeight: AppTypography.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  /// Delete button with red styling
  factory KeypadButton.delete({
    Key? key,
    required VoidCallback onTap,
  }) {
    return KeypadButton(
      key: key,
      onTap: onTap,
      backgroundColor: const Color(0xFFFDE8E8),
      shadowColor: const Color(0xFFE5B0B0),
      child: const Icon(
        Icons.backspace_outlined,
        color: Color(0xFFE57373),
        size: 24,
      ),
    );
  }

  @override
  State<KeypadButton> createState() => _KeypadButtonState();
}

class _KeypadButtonState extends State<KeypadButton> {
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
          color: widget.backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.shadowColor,
              blurRadius: 0,
              offset: Offset(0, _isPressed ? 2 : 4),
            ),
          ],
        ),
        child: Center(
          child: widget.child,
        ),
      ),
    );
  }
}
