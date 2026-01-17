import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'haptic_service.g.dart';

/// Haptic feedback service
class HapticService {
  /// Light haptic feedback for UI interactions
  Future<void> light() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Ignore haptic errors
    }
  }

  /// Medium haptic feedback
  Future<void> medium() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      // Ignore haptic errors
    }
  }

  /// Heavy haptic feedback for important events
  Future<void> heavy() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // Ignore haptic errors
    }
  }

  /// Success vibration pattern
  Future<void> success() async {
    try {
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 50));
      await HapticFeedback.mediumImpact();
    } catch (e) {
      // Ignore haptic errors
    }
  }

  /// Error vibration pattern
  Future<void> error() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // Ignore haptic errors
    }
  }

  /// Selection changed feedback
  Future<void> selectionClick() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      // Ignore haptic errors
    }
  }
}

@riverpod
HapticService hapticService(HapticServiceRef ref) {
  return HapticService();
}
