import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/core/utils/tts_service.dart';
import 'package:mesmots/shared/widgets/highlighted_word.dart';
import 'package:mesmots/shared/widgets/tinted_icon_button.dart';

/// A word of the list being edited (parent side): the parent can hear it,
/// hear it spelled (the letter being said is highlighted) and remove it.
class EditWordItem extends ConsumerStatefulWidget {
  final String word;
  final int colorIndex;
  final VoidCallback onDelete;

  const EditWordItem({
    super.key,
    required this.word,
    required this.colorIndex,
    required this.onDelete,
  });

  @override
  ConsumerState<EditWordItem> createState() => _EditWordItemState();
}

class _EditWordItemState extends ConsumerState<EditWordItem> {
  static const _colors = [
    (AppColors.buttonOrange, AppColors.buttonOrangeShadow),
    (AppColors.buttonPink, AppColors.buttonPinkShadow),
    (AppColors.buttonBlue, AppColors.buttonBlueShadow),
    (AppColors.buttonMagenta, AppColors.buttonMagentaShadow),
    (AppColors.buttonCoral, AppColors.buttonCoralShadow),
  ];

  late final TtsService _tts = ref.read(ttsServiceProvider);
  int? _spokenPosition;
  bool _isSpelling = false;

  Future<void> _spell() async {
    setState(() => _isSpelling = true);
    await _tts.spell(
      widget.word,
      onLetter: (position) {
        if (mounted) setState(() => _spokenPosition = position);
      },
    );
    if (mounted) setState(() => _isSpelling = false);
  }

  @override
  void dispose() {
    if (_isSpelling) _tts.stop().ignore();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (color, shadow) = _colors[widget.colorIndex % _colors.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingL,
          vertical: AppDimensions.paddingS,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          boxShadow: [
            BoxShadow(color: shadow, blurRadius: 0, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: HighlightedWord(
                word: widget.word,
                position: _spokenPosition,
                highlightColor: AppColors.textPrimary,
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: AppTypography.headingSmall,
                  fontWeight: AppTypography.bold,
                  color: AppColors.textOnColor,
                ),
              ),
            ),
            TintedIconButton(
              icon: Icons.volume_up_rounded,
              tooltip: AppStrings.listenWord,
              onTap: () => _tts.speak(widget.word).ignore(),
            ),
            const SizedBox(width: AppDimensions.spacingS),
            TintedIconButton(
              icon: Icons.abc_rounded,
              tooltip: AppStrings.spellWord,
              onTap: _spell,
            ),
            const SizedBox(width: AppDimensions.spacingS),
            TintedIconButton(
              icon: Icons.close,
              tooltip: AppStrings.delete,
              onTap: widget.onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
