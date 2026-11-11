import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/core/utils/tts_service.dart';

/// Word to find in a grid. Tapping it reads the word aloud.
class WordToFindChip extends ConsumerWidget {
  final String word;

  /// Highlight color once found, null while still hidden
  final Color? foundColor;

  const WordToFindChip({
    super.key,
    required this.word,
    this.foundColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFound = foundColor != null;

    return GestureDetector(
      onTap: () => ref.read(ttsServiceProvider).speak(word),
      child: Container(
        constraints: const BoxConstraints(
          minHeight: AppDimensions.minTouchTarget,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingS,
        ),
        decoration: BoxDecoration(
          color: foundColor ?? AppColors.surface,
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
            Text(
              word,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: AppTypography.bodyMedium,
                fontWeight: AppTypography.semiBold,
                color: isFound ? AppColors.textOnColor : AppColors.textPrimary,
                decoration: isFound ? TextDecoration.lineThrough : null,
                decorationColor: AppColors.textOnColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
