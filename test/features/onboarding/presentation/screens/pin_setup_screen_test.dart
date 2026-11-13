import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/features/appearance/domain/entities/appearance_settings.dart';
import 'package:mesmots/features/appearance/presentation/providers/appearance_providers.dart';
import 'package:mesmots/features/onboarding/presentation/screens/pin_setup_screen.dart';
import 'package:mesmots/features/parental/presentation/providers/parental_providers.dart';
import 'package:mesmots/features/word_lists/presentation/providers/word_list_providers.dart';
import 'package:mesmots/shared/widgets/keypad_button.dart';

class _FakeParentalOperations extends ParentalOperations {
  String? configuredPin;

  @override
  FutureOr<void> build() {}

  @override
  Future<void> configurePin(String pin) async => configuredPin = pin;
}

Future<void> _type(WidgetTester tester, String digits) async {
  for (final digit in digits.split('')) {
    await tester.tap(find.widgetWithText(KeypadButton, digit));
    await tester.pump();
  }
  // Let the short pauses after a complete PIN elapse.
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
}

void main() {
  late _FakeParentalOperations operations;

  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    operations = _FakeParentalOperations();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          parentalOperationsProvider.overrideWith(() => operations),
          wordListsProvider.overrideWith((ref) => Stream.value([])),
          appearanceProvider.overrideWith(_FixedAppearance.new),
        ],
        // Reduced motion: the title wave loops forever otherwise,
        // and pumpAndSettle would never return.
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
          home: const PinSetupScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('goes from welcome through the tour to the PIN', (tester) async {
    // Arrange
    await pumpScreen(tester);

    // Act
    await tester.tap(find.text(AppStrings.start.toUpperCase()));
    await tester.pumpAndSettle();
    final tourTitle = find.text(AppStrings.tourListTitle);
    await tester.tap(find.text(AppStrings.next.toUpperCase()));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.next.toUpperCase()));
    await tester.pumpAndSettle();
    final lastButton = find.text(AppStrings.createMyCode.toUpperCase());
    expect(lastButton, findsOneWidget);
    await tester.tap(lastButton);
    await tester.pumpAndSettle();

    // Assert
    expect(tourTitle, findsNothing);
    expect(find.text(AppStrings.createPinTitle), findsOneWidget);
  });

  testWidgets('refuses a different confirmation, then saves the PIN',
      (tester) async {
    // Arrange
    await pumpScreen(tester);
    await tester.tap(find.text(AppStrings.start.toUpperCase()));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.skip));
    await tester.pumpAndSettle();

    // Act
    await _type(tester, '1234');
    expect(find.text(AppStrings.confirmPinTitle), findsOneWidget);
    await _type(tester, '9999');

    // Assert
    expect(operations.configuredPin, isNull);
    expect(find.text(AppStrings.confirmPinTitle), findsOneWidget);

    // Act
    await _type(tester, '1234');

    // Assert
    expect(operations.configuredPin, '1234');
    expect(find.text(AppStrings.parentSpace), findsOneWidget);
  });
}

/// Default appearance, without the Hive box of the app.
class _FixedAppearance extends Appearance {
  @override
  AppearanceSettings build() => AppearanceSettings.initial;
}
