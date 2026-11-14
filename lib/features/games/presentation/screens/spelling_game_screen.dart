import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmots/core/extensions/palette_context.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/features/games/presentation/providers/spelling_game_provider.dart';
import 'package:mesmots/features/games/presentation/widgets/puzzle_game_view.dart';
import 'package:mesmots/features/games/presentation/widgets/success_overlay.dart';
import 'package:mesmots/shared/widgets/gradient_background.dart';
import 'package:mesmots/shared/widgets/bounded_content.dart';

/// "Écoute et épelle": hear the word spelled letter by letter and write it
/// with the letter tiles.
class SpellingGameScreen extends ConsumerWidget {
  final String listId;

  const SpellingGameScreen({super.key, required this.listId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = spellingGameProvider(listId);
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: BoundedContent(
            child: ref.watch(provider).when(
                  data: (state) {
                    final puzzle = state.puzzle;
                    if (puzzle == null) {
                      return SuccessOverlay(
                        onReplay: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SpellingGameScreen(listId: listId),
                          ),
                        ),
                        onBackToList: () => Navigator.pop(context),
                      );
                    }
                    return PuzzleGameView(
                      state: state,
                      puzzle: puzzle,
                      engine: ref.read(provider.notifier).engine,
                    );
                  },
                  loading: () => Center(
                    child: CircularProgressIndicator(
                      color: context.palette.onBackground,
                    ),
                  ),
                  error: (_, __) => Center(
                    child: Text(
                      AppStrings.errorGeneric,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        color: context.palette.onBackground,
                      ),
                    ),
                  ),
                ),
          ),
        ),
      ),
    );
  }
}
