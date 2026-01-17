import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/utils/tts_service.dart';
import 'package:mesmots/core/utils/haptic_service.dart';

/// Button to play word via TTS
class SpeakerButton extends ConsumerWidget {
  final String word;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;

  const SpeakerButton({
    super.key,
    required this.word,
    this.size = 64.0,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tts = ref.watch(ttsServiceProvider);
    final haptic = ref.watch(hapticServiceProvider);

    return GestureDetector(
      onTap: () async {
        await haptic.light();
        await tts.speak(word);
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.volume_up_rounded,
          color: iconColor ?? Colors.white,
          size: size * 0.5,
        ),
      ),
    );
  }
}

/// Small inline speaker button
class SmallSpeakerButton extends ConsumerWidget {
  final String word;
  final Color? color;

  const SmallSpeakerButton({
    super.key,
    required this.word,
    this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tts = ref.watch(ttsServiceProvider);
    final haptic = ref.watch(hapticServiceProvider);

    return IconButton(
      onPressed: () async {
        await haptic.light();
        await tts.speak(word);
      },
      icon: Icon(
        Icons.volume_up_rounded,
        color: color ?? AppColors.primary,
      ),
      iconSize: AppDimensions.iconM,
    );
  }
}
