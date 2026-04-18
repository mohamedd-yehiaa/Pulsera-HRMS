import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Pure-logic TOTP validation service for QR-based location verification.
///
/// Uses HMAC-SHA256 with a 5-second time window. Both the admin QR generator
/// and the employee scanner use the same [generateHash] algorithm.
///
/// Security: No Firestore calls, no Flutter dependency — pure Dart logic.
class TotpService {
  TotpService._();

  /// Time window in seconds. QR code refreshes every 5 seconds.
  static const int timeStepSeconds = 5;

  /// Generates a TOTP hash for the given [sharedSecret] and [timestampSeconds].
  ///
  /// Algorithm: HMAC-SHA256(secret, floor(timestamp / timeStep))
  /// Output: first 8 hex characters of the digest.
  static String generateHash(String sharedSecret, int timestampSeconds) {
    final timeCounter = timestampSeconds ~/ timeStepSeconds;
    final key = utf8.encode(sharedSecret);
    final message = utf8.encode(timeCounter.toString());
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(message);
    // Truncate to 8 hex chars for a compact QR code value
    return digest.toString().substring(0, 8);
  }

  /// Validates [scannedHash] against the current, previous, AND next time
  /// windows to handle device clock drift.
  ///
  /// Windows checked:
  /// - T     (current)
  /// - T - 1 (previous — for late scans)
  /// - T + 1 (next — for early device clocks)
  ///
  /// Returns `true` if the scanned hash matches any valid window.
  static bool validate(String scannedHash, String sharedSecret) {
    final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final currentHash = generateHash(sharedSecret, nowSeconds);
    final previousHash =
        generateHash(sharedSecret, nowSeconds - timeStepSeconds);
    final nextHash = generateHash(sharedSecret, nowSeconds + timeStepSeconds);

    return scannedHash == currentHash ||
        scannedHash == previousHash ||
        scannedHash == nextHash;
  }
}
