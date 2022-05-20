import 'package:data_importer/shared/model.dart';
import 'package:flutter/services.dart';

/// Supports both Android & iOS
class NativeDataImporter {
  const NativeDataImporter._();

  /// Method channel with two features:
  /// - getUser
  /// - clearOldData
  static const MethodChannel methodChannel = MethodChannel('data_importer');

  /// Returns the user credentials from V1
  /// On Android: Shared Preferences (login.xml)
  /// On iOS: UserDefaults (login) + KeyChain (password)
  static Future<ImportableUser?> getUser() async {
    final Map<Object?, Object?>? user =
        await methodChannel.invokeMethod<Map<Object?, Object?>>('getUser');

    if (user != null) {
      final String? userName = user['user'] as String?;
      final String? password = user['password'] as String?;

      if (userName?.isNotEmpty == true && password?.isNotEmpty == true) {
        return ImportableUser(
          userName: userName!,
          password: password!,
        );
      }
    }
    return null;
  }

  /// Unused feature (for now) which clears unused data from V1
  static Future<void> clearOldData() {
    return methodChannel.invokeMethod<dynamic>('clearOldData');
  }
}
