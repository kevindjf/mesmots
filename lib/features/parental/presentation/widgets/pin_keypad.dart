import 'package:flutter/material.dart';
import 'package:mesmots/shared/widgets/keypad_button.dart';

class PinKeypad extends StatelessWidget {
  final Function(int) onNumberPressed;
  final VoidCallback onDeletePressed;

  /// Smaller keys, closer together, to fit a phone held sideways.
  final bool compact;

  const PinKeypad({
    super.key,
    required this.onNumberPressed,
    required this.onDeletePressed,
    this.compact = false,
  });

  static const _size = 70.0;
  static const _compactSize = 60.0;
  static const _rowGap = 16.0;
  static const _compactRowGap = 10.0;

  double get _keySize => compact ? _compactSize : _size;

  @override
  Widget build(BuildContext context) {
    final rowGap = compact ? _compactRowGap : _rowGap;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow([1, 2, 3]),
        SizedBox(height: rowGap),
        _buildRow([4, 5, 6]),
        SizedBox(height: rowGap),
        _buildRow([7, 8, 9]),
        SizedBox(height: rowGap),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: _keySize), // Empty space
            const SizedBox(width: 20),
            KeypadButton.number(
              number: 0,
              size: _keySize,
              onTap: () => onNumberPressed(0),
            ),
            const SizedBox(width: 20),
            KeypadButton.delete(
              size: _keySize,
              onTap: onDeletePressed,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(List<int> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: numbers
          .map((n) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: KeypadButton.number(
                  number: n,
                  size: _keySize,
                  onTap: () => onNumberPressed(n),
                ),
              ))
          .toList(),
    );
  }
}
