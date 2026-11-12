import 'package:flutter/material.dart';
import 'package:mesmots/core/extensions/motion_context.dart';

/// Makes [child] appear with a fade, a scale and an optional slide,
/// after [delay]. Shown immediately when animations are reduced.
class PopIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;

  /// Starting offset of the slide, in logical pixels.
  final Offset from;

  /// Starting scale.
  final double fromScale;

  const PopIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.elasticOut,
    this.from = Offset.zero,
    this.fromScale = 0.4,
  });

  /// Falls from above and bounces, like a letter tile.
  const PopIn.drop({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 700),
  })  : curve = Curves.bounceOut,
        from = const Offset(0, -80),
        fromScale = 1;

  /// Slides up gently, for text and buttons.
  const PopIn.rise({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 500),
  })  : curve = Curves.easeOutCubic,
        from = const Offset(0, 24),
        fromScale = 1;

  @override
  State<PopIn> createState() => _PopInState();
}

class _PopInState extends State<PopIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    final total = widget.delay + widget.duration;
    final start = total == Duration.zero
        ? 0.0
        : widget.delay.inMicroseconds / total.inMicroseconds;
    _controller = AnimationController(vsync: this, duration: total);
    _progress = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, 1, curve: widget.curve),
    );
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, (start + 0.3).clamp(0, 1), curve: Curves.easeOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller.isAnimating || _controller.isCompleted) return;
    if (context.reduceMotion) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = _progress.value;
        final scale = widget.fromScale + (1 - widget.fromScale) * t;
        return Opacity(
          opacity: _opacity.value.clamp(0, 1),
          child: Transform.translate(
            offset: widget.from * (1 - t),
            child: Transform.scale(scale: scale, child: child),
          ),
        );
      },
    );
  }
}
