import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/features/parental/presentation/providers/parental_providers.dart';
import 'package:mesmots/main.dart';

void main() {
  testWidgets('App shows loader while parental settings are loading',
      (WidgetTester tester) async {
    // Arrange
    final app = ProviderScope(
      overrides: [
        parentalSettingsProvider.overrideWith((ref) => const Stream.empty()),
      ],
      child: const MesMotsApp(),
    );

    // Act
    await tester.pumpWidget(app);
    await tester.pump();

    // Assert
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
