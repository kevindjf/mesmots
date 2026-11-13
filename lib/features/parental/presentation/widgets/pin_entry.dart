import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mesmots/core/extensions/palette_context.dart';
import 'package:mesmots/core/constants/app_colors.dart';
import 'package:mesmots/core/constants/app_dimensions.dart';
import 'package:mesmots/core/constants/app_typography.dart';
import 'package:mesmots/core/extensions/motion_context.dart';
import 'package:mesmots/core/utils/haptic_service.dart';
import 'package:mesmots/features/parental/presentation/widgets/pin_keypad.dart';
import 'package:mesmots/shared/widgets/pin_dots.dart';
import 'package:mesmots/shared/widgets/shake.dart';

/// Typing a 4-digit PIN on the app keypad.
///
/// When 4 digits are typed, [validate] decides:
/// - accepted: the dots turn green, then [onAccepted] is called;
/// - refused: the dots shake, the phone vibrates and [errorMessage] shows.
class PinEntry extends ConsumerStatefulWidget {
  static const pinLength = 4;

  final Future<bool> Function(String pin) validate;
  final ValueChanged<String> onAccepted;
  final String errorMessage;
  /// Dot colors default to the panel text and hint of the theme.
  final Color? dotColor;
  final Color? emptyDotColor;
  final Color errorColor;

  const PinEntry({
    super.key,
    required this.validate,
    required this.onAccepted,
    required this.errorMessage,
    this.dotColor,
    this.emptyDotColor,
    this.errorColor = AppColors.error,
  });

  @override
  ConsumerState<PinEntry> createState() => _PinEntryState();
}

class _PinEntryState extends ConsumerState<PinEntry> {
  String _pin = '';
  int _shakes = 0;
  bool _hasError = false;
  bool _isSuccess = false;
  bool _isChecking = false;

  bool get _isLocked => _isChecking || _isSuccess;

  void _onNumber(int number) {
    if (_isLocked || _pin.length >= PinEntry.pinLength) return;
    ref.read(hapticServiceProvider).selectionClick();
    setState(() {
      _pin += '$number';
      _hasError = false;
    });
    if (_pin.length == PinEntry.pinLength) _check();
  }

  void _onDelete() {
    if (_isLocked || _pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _check() async {
    final haptics = ref.read(hapticServiceProvider);
    final pin = _pin;
    setState(() => _isChecking = true);
    final isValid = await widget.validate(pin);
    if (!mounted) return;

    if (isValid) {
      haptics.success();
      setState(() {
        _isChecking = false;
        _isSuccess = true;
      });
      // Let the green dots be seen before moving on.
      await Future<void>.delayed(
        context.motion(const Duration(milliseconds: 350)),
      );
      if (mounted) widget.onAccepted(pin);
    } else {
      haptics.error();
      // Show the 4th dot briefly, then shake and clear.
      await Future<void>.delayed(
        context.motion(const Duration(milliseconds: 150)),
      );
      if (!mounted) return;
      setState(() {
        _isChecking = false;
        _pin = '';
        _hasError = true;
        _shakes++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Shake(
          trigger: _shakes,
          child: PinDots(
            filled: _pin.length,
            length: PinEntry.pinLength,
            isSuccess: _isSuccess,
            filledColor: widget.dotColor ?? context.palette.panelText,
            emptyColor: widget.emptyDotColor ?? context.palette.panelHint,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        SizedBox(
          height: AppDimensions.spacingXl,
          child: Center(
            child: AnimatedOpacity(
              opacity: _hasError ? 1 : 0,
              duration: context.motion(const Duration(milliseconds: 200)),
              child: Text(
                widget.errorMessage,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: AppTypography.bodyMedium,
                  fontWeight: AppTypography.bold,
                  color: widget.errorColor,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        PinKeypad(onNumberPressed: _onNumber, onDeletePressed: _onDelete),
      ],
    );
  }
}
