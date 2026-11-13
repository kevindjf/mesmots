import 'package:mesmots/features/appearance/data/repositories/appearance_repository_impl.dart';
import 'package:mesmots/features/appearance/domain/entities/appearance_settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'appearance_providers.g.dart';

/// Current appearance preferences; changes apply to the whole app at once.
@Riverpod(keepAlive: true)
class Appearance extends _$Appearance {
  @override
  AppearanceSettings build() => ref.watch(appearanceRepositoryProvider).load();

  Future<void> setHighContrast(bool highContrast) =>
      _update(state.copyWith(highContrast: highContrast));

  Future<void> _update(AppearanceSettings settings) async {
    state = settings;
    await ref.read(appearanceRepositoryProvider).save(settings);
  }
}
