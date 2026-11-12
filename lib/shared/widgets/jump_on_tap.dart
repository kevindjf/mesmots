import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mesmots/core/extensions/motion_context.dart';

/// Makes [child] jump and spin once when tapped, with a light vibration.
class JumpOnTap extends StatefulWidget {
  final Widget child;
  final double height;

  const JumpOnTap({super.key, required this.child, this.height = 28});

  @override
  State<JumpOnTap> createState() => _JumpOnTapState();
}

class _JumpOnTapState extends State<JumpOnTap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );

  void _jump() {
    HapticFeedback.lightImpact();
    if (!context.reduceMotion) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _jump,
      child: AnimatedBuilder(
        animation: _controller,
        child: widget.child,
        builder: (context, child) {
          final t = _controller.value;
          // Up then down on a parabola, one full turn while in the air.
          final lift = 4 * t * (1 - t) * widget.height;
          final turn = Curves.easeInOut.transform(t) * 2 * math.pi;
          return Transform.translate(
            offset: Offset(0, -lift),
            child: Transform.rotate(angle: turn, child: child),
          );
        },
      ),
    );
  }
}
