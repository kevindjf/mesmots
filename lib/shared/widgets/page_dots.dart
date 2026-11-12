import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/extensions/motion_context.dart';

/// Page indicator: the current page is a wide pill, the others are dots.
class PageDots extends StatelessWidget {
  final int count;
  final int current;

  const PageDots({super.key, required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final isCurrent = index == current;
        return AnimatedContainer(
          duration: context.motion(const Duration(milliseconds: 250)),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isCurrent ? 28 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: isCurrent
                ? AppColors.surface
                : AppColors.surface.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }),
    );
  }
}
