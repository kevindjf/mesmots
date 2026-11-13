import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/features/games/presentation/extensions/game_type_presentation.dart';
import 'package:mesmots/features/word_lists/domain/entities/game_type.dart';
import 'package:mesmots/shared/widgets/pop_in.dart';

/// The games as colorful tiles popping in one after another.
class TourGamesIllustration extends StatelessWidget {
  const TourGamesIllustration({super.key});

  static const _tileSize = 64.0;

  @override
  Widget build(BuildContext context) {
    const games = GameType.values;
    return SizedBox(
      width: _tileSize * 3 + AppDimensions.spacingM * 2,
      child: Wrap(
        spacing: AppDimensions.spacingM,
        runSpacing: AppDimensions.spacingM,
        children: [
          for (var i = 0; i < games.length; i++)
            PopIn(
              delay: Duration(milliseconds: 150 + 120 * i),
              child: Transform.rotate(
                angle: i.isEven ? -0.05 : 0.05,
                child: Container(
                  width: _tileSize,
                  height: _tileSize,
                  decoration: BoxDecoration(
                    color: games[i].color,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    boxShadow: [
                      BoxShadow(
                        color: games[i].shadowColor,
                        blurRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    games[i].icon,
                    color: AppColors.textOnColor,
                    size: AppDimensions.iconL,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
