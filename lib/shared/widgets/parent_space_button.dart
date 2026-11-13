import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mesmots/core/extensions/palette_context.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_strings.dart';

/// Round button opening the parent space: adult-and-child symbol on a theme
/// tile (white on anthracite in light, dark on white in dark).
class ParentSpaceButton extends StatefulWidget {
  static const iconAsset = 'assets/icons/parent.svg';

  final VoidCallback? onTap;

  const ParentSpaceButton({super.key, this.onTap});

  @override
  State<ParentSpaceButton> createState() => _ParentSpaceButtonState();
}

class _ParentSpaceButtonState extends State<ParentSpaceButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      label: AppStrings.parentSpace,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap?.call();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: AppDimensions.minTouchTarget,
          height: AppDimensions.minTouchTarget,
          transform: Matrix4.translationValues(0, _isPressed ? 2 : 0, 0),
          decoration: BoxDecoration(
            color: palette.tile,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: palette.tileShadow,
                blurRadius: 0,
                offset: Offset(0, _isPressed ? 2 : 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            ParentSpaceButton.iconAsset,
            width: AppDimensions.iconM + 2,
            height: AppDimensions.iconM + 2,
            colorFilter: ColorFilter.mode(palette.tileIcon, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}
