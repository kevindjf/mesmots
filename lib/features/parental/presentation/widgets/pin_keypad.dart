import 'package:flutter/material.dart';
import 'package:jerevise/shared/widgets/keypad_button.dart';

class PinKeypad extends StatelessWidget {
  final Function(int) onNumberPressed;
  final VoidCallback onDeletePressed;

  const PinKeypad({
    super.key,
    required this.onNumberPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow([1, 2, 3]),
        const SizedBox(height: 16),
        _buildRow([4, 5, 6]),
        const SizedBox(height: 16),
        _buildRow([7, 8, 9]),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 70), // Empty space
            const SizedBox(width: 20),
            KeypadButton.number(
              number: 0,
              onTap: () => onNumberPressed(0),
            ),
            const SizedBox(width: 20),
            KeypadButton.delete(
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
                  onTap: () => onNumberPressed(n),
                ),
              ))
          .toList(),
    );
  }
}
