import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesmots/features/appearance/data/repositories/appearance_repository_impl.dart';
import 'package:mesmots/features/appearance/domain/entities/appearance_settings.dart';
import 'package:mesmots/features/appearance/domain/repositories/appearance_repository.dart';
import 'package:mesmots/features/appearance/presentation/providers/appearance_providers.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepository extends Mock implements AppearanceRepository {}

void main() {
  late _MockRepository repository;
  late ProviderContainer container;

  setUpAll(() => registerFallbackValue(AppearanceSettings.initial));

  setUp(() {
    repository = _MockRepository();
    when(repository.load).thenReturn(
      const AppearanceSettings(theme: ThemeChoice.light),
    );
    when(() => repository.save(any())).thenAnswer((_) async {});
    container = ProviderContainer(
      overrides: [appearanceRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
  });

  test('starts from the saved settings', () {
    // Act & Assert
    expect(container.read(appearanceProvider).theme, ThemeChoice.light);
  });

  test('setTheme updates and saves the theme', () async {
    // Act
    await container.read(appearanceProvider.notifier).setTheme(
          ThemeChoice.dark,
        );

    // Assert
    const expected = AppearanceSettings(theme: ThemeChoice.dark);
    expect(container.read(appearanceProvider), expected);
    verify(() => repository.save(expected)).called(1);
  });

  test('setHighContrast keeps the theme', () async {
    // Act
    await container.read(appearanceProvider.notifier).setHighContrast(true);

    // Assert
    expect(
      container.read(appearanceProvider),
      const AppearanceSettings(theme: ThemeChoice.light, highContrast: true),
    );
  });
}
