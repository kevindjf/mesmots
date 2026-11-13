import 'package:flutter/material.dart';
import 'package:mesmots/core/extensions/palette_context.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/features/word_lists/domain/entities/word_status.dart';
import 'package:mesmots/shared/widgets/highlighted_word.dart';
import 'package:mesmots/shared/widgets/progress_stars.dart';
import 'package:mesmots/shared/widgets/speaker_button.dart';
import 'package:mesmots/shared/widgets/spell_button.dart';

/// Bottom sheet to look at one word: shown big with its stars, with buttons
/// to hear it or hear it spelled. Nothing is said until a button is tapped.
class WordPreviewSheet extends StatefulWidget {
  final String word;
  final WordStatus status;

  const WordPreviewSheet({super.key, required this.word, required this.status});

  /// Shows the sheet for [word].
  static Future<void> show(
    BuildContext context, {
    required String word,
    required WordStatus status,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.palette.panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXxl),
        ),
      ),
      builder: (_) => WordPreviewSheet(word: word, status: status),
    );
  }

  @override
  State<WordPreviewSheet> createState() => _WordPreviewSheetState();
}

class _WordPreviewSheetState extends State<WordPreviewSheet> {
  int? _spokenPosition;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.paddingXl,
          AppDimensions.paddingXl,
          AppDimensions.paddingXl,
          AppDimensions.paddingXxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HighlightedWord(
              word: widget.word,
              position: _spokenPosition,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: AppTypography.headingLarge,
                fontWeight: AppTypography.bold,
                color: context.palette.panelText,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            AnimatedProgressStars(
              count: widget.status.stars,
              max: WordStatus.masteryThreshold,
              size: AppDimensions.iconL,
            ),
            const SizedBox(height: AppDimensions.spacingXl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _LabeledAction(
                  label: AppStrings.listen,
                  child: SpeakerButton(word: widget.word, size: 72),
                ),
                _LabeledAction(
                  label: AppStrings.spell,
                  child: SpellButton(
                    word: widget.word,
                    size: 72,
                    sayWordFirst: false,
                    onLetter: (position) =>
                        setState(() => _spokenPosition = position),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledAction extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledAction({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const SizedBox(height: AppDimensions.spacingM),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: AppTypography.bodyMedium,
            fontWeight: AppTypography.semiBold,
            color: context.palette.panelText,
          ),
        ),
      ],
    );
  }
}
