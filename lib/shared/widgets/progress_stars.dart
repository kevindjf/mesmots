import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';

/// Stars indicating word progress (0, 1, or 2 stars)
class ProgressStars extends StatelessWidget {
  final int count; // 0, 1, or 2
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;

  const ProgressStars({
    super.key,
    required this.count,
    this.size = AppDimensions.iconM,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final active = activeColor ?? AppColors.accent;
    final inactive = inactiveColor ?? AppColors.textLight;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          count >= 1 ? Icons.star : Icons.star_border,
          color: count >= 1 ? active : inactive,
          size: size,
        ),
        const SizedBox(width: AppDimensions.spacingXs),
        Icon(
          count >= 2 ? Icons.star : Icons.star_border,
          color: count >= 2 ? active : inactive,
          size: size,
        ),
      ],
    );
  }
}

/// Row of [max] stars, [count] of them lit. When [count] grows, the newly
/// lit stars pop in.
class AnimatedProgressStars extends StatefulWidget {
  final int count;
  final int max;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;

  const AnimatedProgressStars({
    super.key,
    required this.count,
    this.max = 2,
    this.size = AppDimensions.iconM,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<AnimatedProgressStars> createState() => _AnimatedProgressStarsState();
}

class _AnimatedProgressStarsState extends State<AnimatedProgressStars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 600),
    vsync: this,
    value: 1,
  );
  late final Animation<double> _pop = TweenSequence<double>([
    TweenSequenceItem(tween: Tween<double>(begin: 0, end: 1.5), weight: 40),
    TweenSequenceItem(
      tween: Tween<double>(begin: 1.5, end: 1)
          .chain(CurveTween(curve: Curves.elasticOut)),
      weight: 60,
    ),
  ]).animate(_controller);

  /// Stars lit before the last change: they don't animate.
  late int _previousCount = widget.count;

  @override
  void didUpdateWidget(AnimatedProgressStars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count > oldWidget.count) {
      _previousCount = oldWidget.count;
      _controller.forward(from: 0);
    } else if (widget.count != oldWidget.count) {
      _previousCount = widget.count;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.activeColor ?? AppColors.accent;
    final inactive = widget.inactiveColor ?? AppColors.textLight;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < widget.max; i++) ...[
          if (i > 0) const SizedBox(width: AppDimensions.spacingXs),
          _buildStar(i, active, inactive),
        ],
      ],
    );
  }

  Widget _buildStar(int index, Color active, Color inactive) {
    final isActive = widget.count > index;
    final isNew = isActive && index >= _previousCount;
    final icon = Icon(
      isActive ? Icons.star_rounded : Icons.star_outline_rounded,
      color: isActive ? active : inactive,
      size: widget.size,
    );
    return isNew ? ScaleTransition(scale: _pop, child: icon) : icon;
  }
}
