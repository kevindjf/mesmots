import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/shared/widgets/circle_icon_button.dart';

/// Back button on the left, optional action on the right.
class OnboardingTopBar extends StatelessWidget {
  final VoidCallback onBack;
  final Widget? trailing;

  const OnboardingTopBar({super.key, required this.onBack, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.paddingM,
      ),
      child: Row(
        children: [
          CircleIconButton.surface(icon: Icons.arrow_back, onTap: onBack),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
