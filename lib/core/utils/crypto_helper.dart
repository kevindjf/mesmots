import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Cryptographic helper for hashing PINs and answers
class CryptoHelper {
  CryptoHelper._();

  /// Hash a string using SHA-256
  static String hashString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Hash a PIN code
  static String hashPin(String pin) {
    return hashString(pin);
  }

  /// Verify a PIN against its hash
  static bool verifyPin(String pin, String hash) {
    return hashPin(pin) == hash;
  }

  /// Hash a recovery answer (case-insensitive, trimmed)
  static String hashRecoveryAnswer(String answer) {
    final normalized = answer.trim().toLowerCase();
    return hashString(normalized);
  }

  /// Verify a recovery answer against its hash
  static bool verifyRecoveryAnswer(String answer, String hash) {
    return hashRecoveryAnswer(answer) == hash;
  }
}
