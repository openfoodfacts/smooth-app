import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:openfoodfacts/model/User.dart';
import 'package:smooth_app/database/abstract_dao.dart';
import 'package:smooth_app/database/local_database.dart';

enum SecuredValues {
  USER_ID,
  PASSWORD,
}

/// Where we store extra secured strings
class DaoSecuredString extends AbstractDao {
  DaoSecuredString(final LocalDatabase localDatabase) : super(localDatabase);

  static const String _hiveBoxName = 'securedStrings';
  //The key-value key under which the base64 encrypted encryption key is stored
  static const String _encryptionKeyKey = 'securedStringsKey';

  @override
  Future<void> init() async {
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();

    final bool containsEncryptionKey =
        await secureStorage.containsKey(key: _encryptionKeyKey);
    if (!containsEncryptionKey) {
      final List<int> key = Hive.generateSecureKey();
      await secureStorage.write(
          key: _encryptionKeyKey, value: base64UrlEncode(key));
    }

    final String? encryptedEncryptionKey =
        await secureStorage.read(key: _encryptionKeyKey);
    if (encryptedEncryptionKey == null) {
      throw Exception('Encryption key is null');
    }
    final Uint8List encryptionKey = base64Url.decode(encryptedEncryptionKey);

    await Hive.openBox<String>(
      _hiveBoxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
  }

  @override
  void registerAdapter() {}

  Box<String> _getBox() => Hive.box<String>(_hiveBoxName);

  Future<String?> get(SecuredValues type) async => _getBox().get(type.name);

  Future<void> put({required SecuredValues type, required String value}) async {
    _getBox().put(type.name, value);
  }

  Future<void> putUser(User user) async {
    put(type: SecuredValues.USER_ID, value: user.userId);
    put(type: SecuredValues.PASSWORD, value: user.password);
  }
}
