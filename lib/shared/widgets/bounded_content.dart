import 'package:flutter/widgets.dart';
import 'package:mesmots/core/constants/app_breakpoints.dart';
import 'package:mesmots/core/extensions/responsive_context.dart';

/// Centers [child], as wide as the screen but at most [maxWidth], so a screen keeps a readable
/// column on tablets. No effect on phones, narrower than that.
class BoundedContent extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  /// Whether a screen held sideways gets the wide width, for screens that
  /// then put two panes side by side.
  final bool wideInLandscape;

  const BoundedContent({
    super.key,
    required this.child,
    this.maxWidth = AppBreakpoints.contentMaxWidth,
  }) : wideInLandscape = false;

  /// For grids and side-by-side layouts.
  const BoundedContent.wide({super.key, required this.child})
      : maxWidth = AppBreakpoints.wideContentMaxWidth,
        wideInLandscape = false;

  /// One column, or two side by side on a screen held sideways.
  const BoundedContent.sideBySide({super.key, required this.child})
      : maxWidth = AppBreakpoints.contentMaxWidth,
        wideInLandscape = true;

  @override
  Widget build(BuildContext context) {
    final width = wideInLandscape && context.isLandscape
        ? AppBreakpoints.wideContentMaxWidth
        : maxWidth;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }
}
