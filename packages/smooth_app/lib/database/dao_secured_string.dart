import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Where we store extra secured strings
class DaoSecuredString {
  const DaoSecuredString._();

  static FlutterSecureStorage get _getStorage => const FlutterSecureStorage();

  static Future<String?> get(String key) async => _getStorage.read(key: key);

  static Future<void> put({required String key, required String value}) async =>
      _getStorage.write(key: key, value: value);

  static Future<bool> remove({required String key}) async {
    await _getStorage.delete(key: key);
    return contains(key: key);
  }

  static Future<bool> contains({required String key}) async =>
      _getStorage.containsKey(key: key);
}
