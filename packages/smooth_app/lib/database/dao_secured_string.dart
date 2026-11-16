import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Where we store extra secured strings
class DaoSecuredString {
  const DaoSecuredString._();

  static FlutterSecureStorage get _getStorage => const FlutterSecureStorage();

  /// [iOptions] only applies to iOS, e.g. to choose when the item is readable.
  static Future<String?> get(String key, {IOSOptions? iOptions}) async =>
      _getStorage.read(key: key, iOptions: iOptions);

  static Future<void> put({
    required String key,
    required String value,
    IOSOptions? iOptions,
  }) async => _getStorage.write(key: key, value: value, iOptions: iOptions);

  static Future<Map<String, String>> getAll() async => _getStorage.readAll();

  static Future<bool> remove({required String key}) async {
    await _getStorage.delete(key: key);
    return contains(key: key);
  }

  static Future<bool> contains({required String key}) async =>
      _getStorage.containsKey(key: key);
}
