import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/core/utils/tts_service.dart';
import 'package:mesmots/features/games/presentation/widgets/letter_dots.dart';

/// Word to find in a grid, heard rather than read: until found, it only
/// shows a speaker and one dot per letter, so the child must know how the
/// word is written to find it. Tapping reads the word; a long press shows
/// it for 2 seconds, in case the child is stuck.
class WordToFindChip extends ConsumerStatefulWidget {
  final String word;

  /// Number of letters to find in the grid.
  final int letterCount;

  /// Highlight color once found, null while still hidden
  final Color? foundColor;

  const WordToFindChip({
    super.key,
    required this.word,
    required this.letterCount,
    this.foundColor,
  });

  @override
  ConsumerState<WordToFindChip> createState() => _WordToFindChipState();
}

class _WordToFindChipState extends ConsumerState<WordToFindChip> {
  static const _peekDuration = Duration(seconds: 2);

  bool _isPeeking = false;
  Timer? _peekTimer;

  void _peek() {
    _peekTimer?.cancel();
    setState(() => _isPeeking = true);
    _peekTimer = Timer(_peekDuration, () {
      if (mounted) setState(() => _isPeeking = false);
    });
  }

  @override
  void dispose() {
    _peekTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFound = widget.foundColor != null;
    final showWord = isFound || _isPeeking;

    return GestureDetector(
      onTap: () => ref.read(ttsServiceProvider).speak(widget.word),
      onLongPress: isFound ? null : _peek,
      child: Container(
        constraints: const BoxConstraints(
          minHeight: AppDimensions.minTouchTarget,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingS,
        ),
        decoration: BoxDecoration(
          color: widget.foundColor ?? AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          boxShadow: const [
            BoxShadow(
              color: AppColors.primaryDark,
              blurRadius: 0,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isFound ? Icons.check_rounded : Icons.volume_up_rounded,
              size: AppDimensions.iconS,
              color: isFound ? AppColors.textOnColor : AppColors.primary,
            ),
            const SizedBox(width: AppDimensions.spacingXs),
            if (showWord)
              Text(
                widget.word,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: AppTypography.bodyMedium,
                  fontWeight: AppTypography.semiBold,
                  color: isFound
                      ? AppColors.textOnColor
                      : AppColors.textPrimary,
                  decoration: isFound ? TextDecoration.lineThrough : null,
                  decorationColor: AppColors.textOnColor,
                ),
              )
            else
              LetterDots(count: widget.letterCount),
          ],
        ),
      ),
    );
  }
}
