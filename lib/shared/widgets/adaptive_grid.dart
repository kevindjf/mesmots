import 'package:flutter/widgets.dart';
import 'package:mesmots/core/constants/app_breakpoints.dart';

/// Lays [children] out in as many columns as fit, each at least
/// [minItemWidth] wide: one on phones, two or three on tablets. Items of a
/// row are top-aligned.
class AdaptiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double minItemWidth;
  final int maxColumns;

  /// Between columns.
  final double spacing;

  /// Between rows.
  final double runSpacing;

  const AdaptiveGrid({
    super.key,
    required this.children,
    this.minItemWidth = AppBreakpoints.gridItemMinWidth,
    this.maxColumns = AppBreakpoints.gridMaxColumns,
    this.spacing = 0,
    this.runSpacing = 0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = AppBreakpoints.columnsFor(
          constraints.maxWidth,
          minItemWidth: minItemWidth,
          spacing: spacing,
          maxColumns: maxColumns,
        );
        if (columns == 1) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) SizedBox(height: runSpacing),
                children[i],
              ],
            ],
          );
        }
        final rows = (children.length / columns).ceil();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var row = 0; row < rows; row++) ...[
              if (row > 0) SizedBox(height: runSpacing),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var col = 0; col < columns; col++) ...[
                    if (col > 0) SizedBox(width: spacing),
                    Expanded(
                      child: row * columns + col < children.length
                          ? children[row * columns + col]
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}
