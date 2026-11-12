import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/extensions/motion_context.dart';

/// Row of dots showing how many digits of a PIN are typed.
/// A dot pops when it fills; all dots turn green when [isSuccess].
class PinDots extends StatelessWidget {
  final int length;
  final int filled;
  final bool isSuccess;
  final Color filledColor;
  final Color emptyColor;

  const PinDots({
    super.key,
    required this.filled,
    this.length = 4,
    this.isSuccess = false,
    this.filledColor = AppColors.primary,
    this.emptyColor = AppColors.textLight,
  });

  @override
  Widget build(BuildContext context) {
    final duration = context.motion(const Duration(milliseconds: 250));
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        final isFilled = index < filled;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: AnimatedScale(
            scale: isFilled ? 1.25 : 1,
            duration: duration,
            curve: Curves.elasticOut,
            child: AnimatedContainer(
              duration: duration,
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSuccess
                    ? AppColors.success
                    : isFilled
                        ? filledColor
                        : emptyColor,
              ),
            ),
          ),
        );
      }),
    );
  }
}
