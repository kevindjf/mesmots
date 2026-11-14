import 'package:flutter/widgets.dart';
import 'package:mesmots/core/constants/app_breakpoints.dart';
import 'package:mesmots/core/extensions/responsive_context.dart';

/// Draws the app bigger on tablets, by [ScreenClass.uiScale]: the widgets
/// below see a smaller logical screen, then the result is scaled up to fill
/// the real one. Text, tiles and keys keep their size relative to the
/// screen instead of looking tiny.
///
/// Use it as the `builder` of the `MaterialApp`, so dialogs and sheets are
/// scaled too.
class AdaptiveScale extends StatelessWidget {
  final Widget child;

  const AdaptiveScale({super.key, required this.child});

  /// For `MaterialApp.builder`.
  static Widget builder(BuildContext context, Widget? child) =>
      AdaptiveScale(child: child ?? const SizedBox.shrink());

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenClass = ScreenClass.of(media.size);
    final scale = screenClass.uiScale;
    final scoped = ScreenClassScope(screenClass: screenClass, child: child);
    if (scale == 1) return scoped;

    final size = media.size / scale;
    return MediaQuery(
      data: media.copyWith(
        size: size,
        devicePixelRatio: media.devicePixelRatio * scale,
        padding: media.padding / scale,
        viewPadding: media.viewPadding / scale,
        viewInsets: media.viewInsets / scale,
        systemGestureInsets: media.systemGestureInsets / scale,
      ),
      child: FittedBox(
        fit: BoxFit.fill,
        alignment: Alignment.topLeft,
        child: SizedBox.fromSize(size: size, child: scoped),
      ),
    );
  }
}
