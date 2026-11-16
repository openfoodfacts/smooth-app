import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smooth_app/database/dao_secured_string.dart';

/// Encrypts the `user` field of the background tasks before they are stored.
///
/// Envelope: `enc:v1:` + base64(nonce(12) | ciphertext | mac(16)).
/// The key is random, lives in the secure storage and never in Hive.
class TaskUserCipher {
  const TaskUserCipher._();

  static const String _PREFIX = 'enc:v1:';
  static const String _KEY_NAME = 'background_task_user_key';
  static const int _KEY_LENGTH = 32;
  static const int _NONCE_LENGTH = 12;
  static const int _MAC_LENGTH = 16;

  /// Readable in the background after the first unlock, never migrated to
  /// another device.
  static const IOSOptions _IOS_OPTIONS = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  );

  static final AesGcm _algorithm = AesGcm.with256bits();

  /// Memoized so that concurrent calls cannot create two different keys.
  static Future<SecretKey>? _key;

  static bool isEncrypted(String value) => value.startsWith(_PREFIX);

  static Future<String> encrypt(
    String userJson,
    String uniqueId,
    String processName,
  ) async {
    final SecretBox box = await _algorithm.encrypt(
      utf8.encode(userJson),
      secretKey: await _getKey(),
      aad: _getAad(uniqueId, processName),
    );
    return '$_PREFIX${base64.encode(box.concatenation())}';
  }

  /// Throws if the envelope is malformed, tampered with, or does not belong to
  /// this task.
  static Future<String> decrypt(
    String envelope,
    String uniqueId,
    String processName,
  ) async {
    if (!isEncrypted(envelope)) {
      throw const FormatException('Not an encrypted value');
    }

    final SecretBox box = SecretBox.fromConcatenation(
      base64.decode(envelope.substring(_PREFIX.length)),
      nonceLength: _NONCE_LENGTH,
      macLength: _MAC_LENGTH,
    );
    final List<int> clear = await _algorithm.decrypt(
      box,
      secretKey: await _getKey(),
      aad: _getAad(uniqueId, processName),
    );

    return utf8.decode(clear);
  }

  /// Forgets the memoized key.
  @visibleForTesting
  static void reset() => _key = null;

  /// Binds the encrypted value to its task.
  static List<int> _getAad(String uniqueId, String processName) =>
      utf8.encode('smooth_app.task.user|$uniqueId|$processName');

  static Future<SecretKey> _getKey() async {
    final Future<SecretKey> pending = _key ??= _loadOrCreateKey();

    try {
      return await pending;
    } catch (_) {
      // Allows a new attempt.
      if (identical(_key, pending)) {
        _key = null;
      }

      rethrow;
    }
  }

  static Future<SecretKey> _loadOrCreateKey() async {
    // A read that throws must not lead to a new key: a transient error would
    // otherwise overwrite the key and orphan every pending task.
    final String? stored = await DaoSecuredString.get(
      _KEY_NAME,
      iOptions: _IOS_OPTIONS,
    );

    if (stored != null) {
      final List<int> bytes = base64.decode(stored);

      if (bytes.length != _KEY_LENGTH) {
        throw const FormatException('Unexpected key length');
      }

      return SecretKey(bytes);
    }

    final SecretKey created = await _algorithm.newSecretKey();
    await DaoSecuredString.put(
      key: _KEY_NAME,
      value: base64.encode(await created.extractBytes()),
      iOptions: _IOS_OPTIONS,
    );

    return created;
  }
}
