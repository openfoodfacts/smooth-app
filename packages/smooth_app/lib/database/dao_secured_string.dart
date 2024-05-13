import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Where we store extra secured strings
class DaoSecuredString {
  const DaoSecuredString._();

  static FlutterSecureStorage get _getStorage => const FlutterSecureStorage();

  static Future<String?> get(String key) async {
    try {
      return _getStorage.read(key: key);
    } on PlatformException catch (e) {
      if (e.details == -25300) {
        // On some platforms, the plugin returns an Exception when this value is unavailable
        // Exception received: "The specified item could not be found in the keychain."
        return null;
      } else {
        rethrow;
      }
    }
  }

  static Future<void> put({required String key, required String value}) async =>
      _getStorage.write(key: key, value: value);

  static Future<bool> remove({required String key}) async {
    try {
      await _getStorage.delete(key: key);
    } on PlatformException catch (e) {
      if (e.details == -25300) {
        // On some platforms, the plugin returns an Exception when this value is unavailable
        // Exception received: "The specified item could not be found in the keychain."
        return false;
      } else {
        rethrow;
      }
    }
    return contains(key: key);
  }

  static Future<bool> contains({required String key}) async =>
      _getStorage.containsKey(key: key);
}
