import 'package:flutter/material.dart';
import 'package:mesmots/core/extensions/palette_context.dart';
import 'package:mesmots/core/constants/app_colors.dart';

/// A round colored badge with a white icon and a 3D shadow (not tappable).
class IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color shadowColor;
  final double size;

  const IconBadge({
    super.key,
    required this.icon,
    required this.color,
    required this.shadowColor,
    this.size = 56,
  });

  const IconBadge.blue({super.key, required this.icon, this.size = 72})
      : color = AppColors.buttonBlue,
        shadowColor = AppColors.buttonBlueShadow;

  const IconBadge.orange({super.key, required this.icon, this.size = 56})
      : color = AppColors.buttonOrange,
        shadowColor = AppColors.buttonOrangeShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: shadowColor, blurRadius: 0, offset: const Offset(0, 4)),
        ],
      ),
      child: Icon(icon, size: size * 0.5, color: context.palette.onBlock(color)),
    );
  }
}
