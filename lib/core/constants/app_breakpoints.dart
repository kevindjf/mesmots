import 'dart:ui' show Size;

/// Responsive breakpoints, on the shortest side of the screen so a phone
/// held sideways stays a phone.
///
/// Every width below is in logical pixels once the UI is scaled by
/// [ScreenClass.uiScale] (see `AdaptiveScale`).
class AppBreakpoints {
  AppBreakpoints._();

  /// Shortest side from which the screen is a small tablet (iPad mini,
  /// Android 10").
  static const double md = 600;

  /// Shortest side from which the screen is a large tablet (iPad 13").
  static const double lg = 900;

  /// UI scale of each screen class: tablets show the phone design bigger,
  /// so text, tiles and keys keep their size relative to the screen.
  static const double uiScaleSm = 1.0;
  static const double uiScaleMd = 1.25;
  static const double uiScaleLg = 1.4;

  /// Width of a single column of content: forms, games, dialogs.
  static const double contentMaxWidth = 640;

  /// Width of grids and of side-by-side layouts.
  static const double wideContentMaxWidth = 960;

  /// Width of the success screen and its buttons.
  static const double compactMaxWidth = 480;

  /// Narrowest grid item: below, the grid drops a column.
  static const double gridItemMinWidth = 280;

  /// Most columns of a grid.
  static const int gridMaxColumns = 3;

  /// Width of the pane next to a game board, in landscape.
  static const double sidePanelWidth = 400;

  /// Columns of a grid of items at least [minItemWidth] wide, [spacing]
  /// apart, in [width].
  static int columnsFor(
    double width, {
    double minItemWidth = gridItemMinWidth,
    double spacing = 0,
    int maxColumns = gridMaxColumns,
  }) {
    final columns = ((width + spacing) / (minItemWidth + spacing)).floor();
    return columns.clamp(1, maxColumns);
  }
}

/// Size class of the screen: phone (sm), small tablet (md), large tablet
/// (lg).
enum ScreenClass {
  sm(AppBreakpoints.uiScaleSm),
  md(AppBreakpoints.uiScaleMd),
  lg(AppBreakpoints.uiScaleLg);

  const ScreenClass(this.uiScale);

  /// How much bigger the UI is drawn.
  final double uiScale;

  bool get isTablet => this != ScreenClass.sm;

  /// Class of a screen of [size], in unscaled logical pixels.
  static ScreenClass of(Size size) {
    final side = size.shortestSide;
    if (side >= AppBreakpoints.lg) return ScreenClass.lg;
    if (side >= AppBreakpoints.md) return ScreenClass.md;
    return ScreenClass.sm;
  }
}
