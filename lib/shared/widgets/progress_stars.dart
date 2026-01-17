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

/// Animated stars (for celebrations)
class AnimatedProgressStars extends StatefulWidget {
  final int count; // 0, 1, or 2
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;

  const AnimatedProgressStars({
    super.key,
    required this.count,
    this.size = AppDimensions.iconM,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<AnimatedProgressStars> createState() => _AnimatedProgressStarsState();
}

class _AnimatedProgressStarsState extends State<AnimatedProgressStars>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedProgressStars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.count != widget.count) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.activeColor ?? AppColors.accent;
    final inactive = widget.inactiveColor ?? AppColors.textLight;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAnimatedStar(0, active, inactive),
        const SizedBox(width: AppDimensions.spacingXs),
        _buildAnimatedStar(1, active, inactive),
      ],
    );
  }

  Widget _buildAnimatedStar(int index, Color active, Color inactive) {
    final isActive = widget.count > index;

    return ScaleTransition(
      scale: isActive ? _scaleAnimation : const AlwaysStoppedAnimation(1.0),
      child: Icon(
        isActive ? Icons.star : Icons.star_border,
        color: isActive ? active : inactive,
        size: widget.size,
      ),
    );
  }
}
