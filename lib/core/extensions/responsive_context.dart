import 'package:flutter/widgets.dart';
import 'package:mesmots/core/constants/app_breakpoints.dart';

/// Gives the [ScreenClass] of the device to the widgets below, as
/// `AdaptiveScale` computes it before shrinking the logical screen.
class ScreenClassScope extends InheritedWidget {
  final ScreenClass screenClass;

  const ScreenClassScope({
    super.key,
    required this.screenClass,
    required super.child,
  });

  static ScreenClass? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<ScreenClassScope>()
      ?.screenClass;

  @override
  bool updateShouldNotify(ScreenClassScope oldWidget) =>
      screenClass != oldWidget.screenClass;
}

/// Screen class and orientation, to pick a layout.
extension ResponsiveContext on BuildContext {
  /// Phone or tablet, from the device screen.
  ScreenClass get screenClass =>
      ScreenClassScope.maybeOf(this) ?? ScreenClass.of(MediaQuery.sizeOf(this));

  bool get isTablet => screenClass.isTablet;

  /// A tablet held sideways: room for two panes side by side.
  bool get isTabletLandscape =>
      isTablet && MediaQuery.orientationOf(this) == Orientation.landscape;
}
