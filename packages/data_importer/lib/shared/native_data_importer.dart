import 'package:data_importer/shared/model.dart';
import 'package:flutter/services.dart';

/// Supports both Android & iOS
class NativeDataImporter {
  const NativeDataImporter._();

  /// Method channel with three features:
  /// - getUser
  /// - getHistory
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

  /// Returns a list of barcodes (only on iOS)
  static Future<dynamic> getHistory() {
    return methodChannel.invokeMethod<dynamic>('getHistory');
  }

  /// Remove old data (only used on new migration processes)
  static Future<bool> clearOldData() {
    return methodChannel
        .invokeMethod<bool>('clearOldData')
        .then((bool? value) => value ?? false)
        .onError((Object? error, StackTrace stackTrace) => false);
  }
}
