import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/features/appearance/data/repositories/appearance_repository_impl.dart';
import 'package:mesmots/features/appearance/domain/entities/appearance_settings.dart';
import 'package:mesmots/features/appearance/domain/repositories/appearance_repository.dart';
import 'package:mesmots/features/parental/presentation/providers/parental_providers.dart';
import 'package:mesmots/main.dart';
import 'package:mocktail/mocktail.dart';

class _MockAppearanceRepository extends Mock implements AppearanceRepository {}

void main() {
  testWidgets('App shows loader while parental settings are loading',
      (WidgetTester tester) async {
    // Arrange
    final appearance = _MockAppearanceRepository();
    when(appearance.load).thenReturn(AppearanceSettings.initial);
    final app = ProviderScope(
      overrides: [
        appearanceRepositoryProvider.overrideWithValue(appearance),
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
