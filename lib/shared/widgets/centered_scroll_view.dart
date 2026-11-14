import 'package:flutter/widgets.dart';
import 'package:mesmots/core/extensions/responsive_context.dart';

/// Scrolls [child] when it is taller than the screen. On tablets, where it
/// usually fits with room to spare, centers it vertically instead of
/// leaving it at the top.
class CenteredScrollView extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const CenteredScrollView({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    if (!context.isTablet) {
      return SingleChildScrollView(padding: padding, child: child);
    }
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: padding,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: (constraints.maxHeight - padding.vertical)
                .clamp(0.0, double.infinity),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
