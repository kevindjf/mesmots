import 'package:flutter/material.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/features/games/presentation/screens/fill_blanks_game_screen.dart';
import 'package:mesmots/features/games/presentation/screens/qcm_game_screen.dart';
import 'package:mesmots/features/games/presentation/screens/scramble_game_screen.dart';
import 'package:mesmots/features/games/presentation/screens/writing_game_screen.dart';
import 'package:mesmots/features/word_lists/domain/entities/game_type.dart';

/// UI attributes and navigation for each [GameType].
extension GameTypePresentation on GameType {
  IconData get icon {
    switch (this) {
      case GameType.qcm:
        return Icons.touch_app_rounded;
      case GameType.scramble:
        return Icons.shuffle_rounded;
      case GameType.fillBlanks:
        return Icons.extension_rounded;
      case GameType.writing:
        return Icons.edit_rounded;
    }
  }

  Color get color {
    switch (this) {
      case GameType.qcm:
        return AppColors.buttonOrange;
      case GameType.scramble:
        return AppColors.buttonBlue;
      case GameType.fillBlanks:
        return AppColors.buttonPink;
      case GameType.writing:
        return AppColors.buttonMagenta;
    }
  }

  Color get shadowColor {
    switch (this) {
      case GameType.qcm:
        return AppColors.buttonOrangeShadow;
      case GameType.scramble:
        return AppColors.buttonBlueShadow;
      case GameType.fillBlanks:
        return AppColors.buttonPinkShadow;
      case GameType.writing:
        return AppColors.buttonMagentaShadow;
    }
  }

  /// Screen to play this game with the given word list
  Widget buildScreen(String listId) {
    switch (this) {
      case GameType.qcm:
        return QcmGameScreen(listId: listId);
      case GameType.scramble:
        return ScrambleGameScreen(listId: listId);
      case GameType.fillBlanks:
        return FillBlanksGameScreen(listId: listId);
      case GameType.writing:
        return WritingGameScreen(listId: listId);
    }
  }
}
