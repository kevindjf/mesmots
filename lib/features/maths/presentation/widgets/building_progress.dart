import 'package:flutter/material.dart';
import 'package:jerevise/core/constants/app_colors.dart';
class BuildingProgress extends StatelessWidget {
  final double progress;

  const BuildingProgress({super.key, required this.progress});

  static const _blockColors = [
    AppColors.buttonOrange,
    AppColors.buttonBlue,
    AppColors.buttonPink,
    AppColors.sectionMaths,
    AppColors.buttonCoral,
    AppColors.buttonMagenta,
  ];

  @override
  Widget build(BuildContext context) {
    const totalBlocks = 10;
    final filledBlocks = (progress * totalBlocks).ceil().clamp(0, totalBlocks);

    return SizedBox(
      height: 200,
      width: 120,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Ground
          Positioned(
            bottom: 0,
            child: Container(
              width: 120,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Blocks
          ...List.generate(filledBlocks, (i) {
            final color = _blockColors[i % _blockColors.length];
            return Positioned(
              bottom: 8 + (i * 18.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.bounceOut,
                width: 80,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            );
          }),

          // Roof (when complete)
          if (progress >= 1.0)
            Positioned(
              bottom: 8 + (totalBlocks * 18.0),
              child: Container(
                width: 0,
                height: 0,
                decoration: const BoxDecoration(),
                child: CustomPaint(
                  size: const Size(100, 30),
                  painter: _RoofPainter(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RoofPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.buttonCoral
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
