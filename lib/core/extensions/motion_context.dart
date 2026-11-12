import 'package:flutter/widgets.dart';

/// Motion preferences read from the platform accessibility settings.
extension MotionContext on BuildContext {
  /// True when the user asked the system to reduce animations.
  bool get reduceMotion => MediaQuery.maybeDisableAnimationsOf(this) ?? false;

  /// [duration], or zero when animations are reduced.
  Duration motion(Duration duration) => reduceMotion ? Duration.zero : duration;
}
