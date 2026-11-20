import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_breakpoints.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/extensions/responsive_context.dart';
import 'package:mesmots/features/games/presentation/widgets/game_header.dart';
import 'package:mesmots/shared/widgets/circle_icon_button.dart';

/// Layout shared by every game screen.
///
/// The close button always sits next to the progress.
///
/// Upright: [portrait] below them.
///
/// Held sideways, on a phone or a tablet: two panes. On the left, the
/// close button and the progress, then [prompt] (what to hear, read or
/// look at). On the right, as tall as the screen, [answer] (tiles, keyboard,
/// options), so a keyboard always fits.
///
/// With [squarePrompt], sideways, [prompt] is a square as tall as the
/// screen and the close button and the progress go above [answer], which
/// takes the rest of the width: a board gets all the height.
class GameLayout extends StatelessWidget {
  final double progress;
  final int validatedCount;
  final int totalCount;

  /// Content under the progress, upright.
  final Widget portrait;

  /// Left pane, sideways.
  final Widget prompt;

  /// Right pane, sideways.
  final Widget answer;

  /// Space above the close button and the progress, upright.
  final double topBarPadding;

  /// Sideways, [prompt] as a square as tall as the screen.
  final bool squarePrompt;

  const GameLayout({
    super.key,
    required this.progress,
    required this.validatedCount,
    required this.totalCount,
    required this.portrait,
    required this.prompt,
    required this.answer,
    this.topBarPadding = AppDimensions.paddingM,
    this.squarePrompt = false,
  });

  @override
  Widget build(BuildContext context) {
    final isLandscape = context.isLandscape;
    // The close button sits on the progress line, to save a row of height.
    final topBar = Padding(
      padding: EdgeInsets.only(
        left: AppDimensions.paddingL,
        top: isLandscape ? AppDimensions.paddingS : topBarPadding,
      ),
      child: Row(
        children: [
          CircleIconButton.surface(
            icon: Icons.close,
            onTap: () => Navigator.pop(context),
          ),
          Expanded(
            child: GameHeader(
              progress: progress,
              validatedCount: validatedCount,
              totalCount: totalCount,
              compact: isLandscape,
            ),
          ),
        ],
      ),
    );

    if (isLandscape && squarePrompt) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final side = constraints.maxHeight.clamp(
            0.0,
            constraints.maxWidth - AppBreakpoints.sidePanelMinWidth,
          );
          return Row(
            children: [
              SizedBox(width: side, child: prompt),
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        right: AppDimensions.paddingL,
                      ),
                      child: topBar,
                    ),
                    Expanded(child: answer),
                  ],
                ),
              ),
            ],
          );
        },
      );
    }

    if (isLandscape) {
      return LayoutBuilder(
        builder: (context, constraints) => Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  topBar,
                  Expanded(child: prompt),
                ],
              ),
            ),
            SizedBox(
              width: AppBreakpoints.sidePanelWidthFor(constraints.maxWidth),
              child: answer,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        topBar,
        Expanded(child: portrait),
      ],
    );
  }
}
