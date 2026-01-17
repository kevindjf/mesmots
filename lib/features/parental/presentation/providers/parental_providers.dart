import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mesmots/features/parental/data/repositories/parental_repository_impl.dart';
import 'package:mesmots/features/parental/domain/entities/parental_settings.dart';
import 'package:mesmots/core/utils/crypto_helper.dart';

part 'parental_providers.g.dart';

/// Provider for parental settings (stream)
@riverpod
Stream<ParentalSettings> parentalSettings(ParentalSettingsRef ref) {
  final repository = ref.watch(parentalRepositoryProvider);
  return repository.watch();
}

/// Provider for parental mode state (whether parent is currently authenticated)
@riverpod
class ParentalMode extends _$ParentalMode {
  @override
  bool build() => false; // Not authenticated by default

  void activate() => state = true;
  void deactivate() => state = false;
}

/// Provider for parental operations
@riverpod
class ParentalOperations extends _$ParentalOperations {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  /// Configure PIN only (for initial onboarding)
  Future<void> configurePin(String pin) async {
    state = const AsyncLoading();

    await AsyncValue.guard(() async {
      final repository = ref.read(parentalRepositoryProvider);

      final pinHash = CryptoHelper.hashPin(pin);

      final settings = ParentalSettings.initial().configure(
        pinHash: pinHash,
        recoveryQuestion: null,
        recoveryAnswerHash: null,
      );

      await repository.save(settings);
    }).then((value) => state = value);
  }

  /// Setup PIN for the first time with recovery
  Future<void> setupPin({
    required String pin,
    required String recoveryQuestion,
    required String recoveryAnswer,
  }) async {
    state = const AsyncLoading();

    await AsyncValue.guard(() async {
      final repository = ref.read(parentalRepositoryProvider);

      final pinHash = CryptoHelper.hashPin(pin);
      final recoveryAnswerHash =
          CryptoHelper.hashRecoveryAnswer(recoveryAnswer);

      final settings = ParentalSettings.initial().configure(
        pinHash: pinHash,
        recoveryQuestion: recoveryQuestion,
        recoveryAnswerHash: recoveryAnswerHash,
      );

      await repository.save(settings);
    }).then((value) => state = value);
  }

  /// Verify PIN
  Future<bool> verifyPin(String pin) async {
    final repository = ref.read(parentalRepositoryProvider);
    final settings = await repository.get();

    if (!settings.isPinConfigured || settings.pinHash == null) {
      return false;
    }

    return CryptoHelper.verifyPin(pin, settings.pinHash!);
  }

  /// Verify recovery answer
  Future<bool> verifyRecoveryAnswer(String answer) async {
    final repository = ref.read(parentalRepositoryProvider);
    final settings = await repository.get();

    if (settings.recoveryAnswerHash == null) {
      return false;
    }

    return CryptoHelper.verifyRecoveryAnswer(
      answer,
      settings.recoveryAnswerHash!,
    );
  }

  /// Change PIN
  Future<void> changePin(String newPin) async {
    state = const AsyncLoading();

    await AsyncValue.guard(() async {
      final repository = ref.read(parentalRepositoryProvider);
      final current = await repository.get();

      if (!current.isPinConfigured) {
        throw Exception('PIN not configured');
      }

      final newPinHash = CryptoHelper.hashPin(newPin);
      final updated = current.updatePin(newPinHash);

      await repository.save(updated);
    }).then((value) => state = value);
  }

  /// Update recovery question and answer
  Future<void> updateRecovery({
    required String newQuestion,
    required String newAnswer,
  }) async {
    state = const AsyncLoading();

    await AsyncValue.guard(() async {
      final repository = ref.read(parentalRepositoryProvider);
      final current = await repository.get();

      if (!current.isPinConfigured) {
        throw Exception('PIN not configured');
      }

      final newAnswerHash = CryptoHelper.hashRecoveryAnswer(newAnswer);
      final updated = current.updateRecovery(
        newRecoveryQuestion: newQuestion,
        newRecoveryAnswerHash: newAnswerHash,
      );

      await repository.save(updated);
    }).then((value) => state = value);
  }

  /// Reset PIN using recovery answer
  Future<void> resetPinWithRecovery({
    required String recoveryAnswer,
    required String newPin,
  }) async {
    state = const AsyncLoading();

    await AsyncValue.guard(() async {
      final verified = await verifyRecoveryAnswer(recoveryAnswer);

      if (!verified) {
        throw Exception('Invalid recovery answer');
      }

      await changePin(newPin);
    }).then((value) => state = value);
  }

  /// Reset all parental settings
  Future<void> resetAll() async {
    state = const AsyncLoading();

    await AsyncValue.guard(() async {
      final repository = ref.read(parentalRepositoryProvider);
      await repository.reset();
    }).then((value) => state = value);
  }
}
