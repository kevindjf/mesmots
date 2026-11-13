import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmots/core/extensions/palette_context.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/utils/tts_service.dart';
import 'package:mesmots/core/utils/haptic_service.dart';

/// Button to play word via TTS - style Mr. Square avec ombre 3D
class SpeakerButton extends ConsumerStatefulWidget {
  final String word;
  final double size;
  final Color? backgroundColor;
  final Color? shadowColor;
  final Color? iconColor;

  const SpeakerButton({
    super.key,
    required this.word,
    this.size = 64.0,
    this.backgroundColor,
    this.shadowColor,
    this.iconColor,
  });

  @override
  ConsumerState<SpeakerButton> createState() => _SpeakerButtonState();
}

class _SpeakerButtonState extends ConsumerState<SpeakerButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final tts = ref.watch(ttsServiceProvider);
    final haptic = ref.watch(hapticServiceProvider);
    final bgColor = widget.backgroundColor ?? AppColors.buttonBlue;
    final shadow = widget.shadowColor ?? AppColors.buttonBlueShadow;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) async {
        setState(() => _isPressed = false);
        await haptic.light();
        await tts.speak(widget.word);
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.size,
        height: widget.size,
        transform: Matrix4.translationValues(0, _isPressed ? 3 : 0, 0),
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: shadow,
              blurRadius: 0,
              offset: Offset(0, _isPressed ? 3 : 6),
            ),
          ],
        ),
        child: Icon(
          Icons.volume_up_rounded,
          color: widget.iconColor ?? context.palette.onBlock(bgColor),
          size: widget.size * 0.5,
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
        color: color ?? context.palette.panelText,
      ),
      iconSize: AppDimensions.iconM,
    );
  }
}
