import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/core/constants/app_strings.dart';
import 'package:mesmots/features/appearance/data/repositories/appearance_repository_impl.dart';
import 'package:mesmots/features/appearance/domain/entities/appearance_settings.dart';
import 'package:mesmots/features/appearance/domain/repositories/appearance_repository.dart';
import 'package:mesmots/features/appearance/presentation/widgets/appearance_section.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepository extends Mock implements AppearanceRepository {}

void main() {
  late _MockRepository repository;

  setUpAll(() => registerFallbackValue(AppearanceSettings.initial));

  setUp(() {
    repository = _MockRepository();
    when(repository.load).thenReturn(AppearanceSettings.initial);
    when(() => repository.save(any())).thenAnswer((_) async {});
  });

  Future<void> pumpSection(WidgetTester tester) => tester.pumpWidget(
        ProviderScope(
          overrides: [
            appearanceRepositoryProvider.overrideWithValue(repository)
          ],
          child: const MaterialApp(
            home: Scaffold(
                body: SingleChildScrollView(child: AppearanceSection())),
          ),
        ),
      );

  testWidgets('shows the four themes, the saved one selected', (tester) async {
    // Act
    await pumpSection(tester);

    // Assert
    for (final label in [
      AppStrings.themeTurquoise,
      AppStrings.themeLight,
      AppStrings.themeDark,
      AppStrings.themeSystem,
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
  });

  testWidgets('tapping a theme saves it', (tester) async {
    // Arrange
    await pumpSection(tester);

    // Act
    await tester.tap(find.text(AppStrings.themeDark));
    await tester.pump();

    // Assert
    verify(
      () => repository.save(const AppearanceSettings(theme: ThemeChoice.dark)),
    ).called(1);
  });

  testWidgets('tapping the contrast row turns it on', (tester) async {
    // Arrange
    await pumpSection(tester);

    // Act
    await tester.tap(find.text(AppStrings.highContrast));
    await tester.pump();

    // Assert
    verify(
      () => repository.save(const AppearanceSettings(highContrast: true)),
    ).called(1);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
  });
}
