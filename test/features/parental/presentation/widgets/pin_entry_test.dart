import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/features/parental/presentation/widgets/pin_entry.dart';
import 'package:mesmots/shared/widgets/keypad_button.dart';

Future<void> _type(WidgetTester tester, String digits) async {
  for (final digit in digits.split('')) {
    await tester.tap(find.widgetWithText(KeypadButton, digit));
    await tester.pump();
  }
  // Let the short pauses after a complete PIN elapse.
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
}

Widget _wrap(Widget child) => ProviderScope(
      child: MaterialApp(home: Scaffold(body: Center(child: child))),
    );

void main() {
  testWidgets('calls onAccepted with the PIN when it is valid', (tester) async {
    // Arrange
    String? accepted;
    await tester.pumpWidget(
      _wrap(
        PinEntry(
          validate: (pin) async => pin == '1234',
          onAccepted: (pin) => accepted = pin,
          errorMessage: 'Faux',
        ),
      ),
    );

    // Act
    await _type(tester, '1234');

    // Assert
    expect(accepted, '1234');
  });

  testWidgets('shows the error and lets the user retry when invalid',
      (tester) async {
    // Arrange
    String? accepted;
    await tester.pumpWidget(
      _wrap(
        PinEntry(
          validate: (pin) async => pin == '1234',
          onAccepted: (pin) => accepted = pin,
          errorMessage: 'Faux',
        ),
      ),
    );

    // Act
    await _type(tester, '9999');

    // Assert
    expect(accepted, isNull);
    final error = tester.widget<AnimatedOpacity>(
      find.ancestor(of: find.text('Faux'), matching: find.byType(AnimatedOpacity)),
    );
    expect(error.opacity, 1);

    // Act: retry with the right code
    await _type(tester, '1234');

    // Assert
    expect(accepted, '1234');
  });
}
