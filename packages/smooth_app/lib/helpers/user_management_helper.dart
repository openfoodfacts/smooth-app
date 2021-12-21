import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/OpenFoodAPIConfiguration.dart';
import 'package:smooth_app/database/dao_secured_string.dart';

class UserManagementHelper {
  UserManagementHelper._();

  static const String _USER_ID = 'user_id';
  static const String _PASSWORD = 'pasword';

  /// Checks credentials and conditionally saves them
  static Future<bool> login(User user) async {
    final bool rightCredentials;
    try {
      rightCredentials = await OpenFoodAPIClient.login(user);
    } catch (e) {
      throw Exception(e);
    }

    if (rightCredentials) {
      OpenFoodAPIConfiguration.globalUser = user;
      _putUser(user);
    }

    return rightCredentials && await _checkCredentialsInStorage();
  }

  /// Checks if the saved credentials are still valid
  /// and mounts credentials for use in queries
  static Future<bool> checkAndReMountCredentials() async {
    final String? userId = await DaoSecuredString.get(_USER_ID);
    final String? password = await DaoSecuredString.get(_PASSWORD);

    if (userId == null || password == null) {
      return false;
    }

    final User user = User(userId: userId, password: password);

    final bool rightCredentials;
    try {
      rightCredentials = await OpenFoodAPIClient.login(user);
    } catch (e) {
      throw Exception(e);
    }

    if (rightCredentials) {
      OpenFoodAPIConfiguration.globalUser = user;
    }

    return rightCredentials;
  }

  /// Deletes saved credentials from storage
  static Future<bool> logout() async {
    OpenFoodAPIConfiguration.globalUser = null;
    DaoSecuredString.remove(key: _USER_ID);
    DaoSecuredString.remove(key: _PASSWORD);
    final bool contains = await _checkCredentialsInStorage();
    return !contains;
  }

  /// Saves user to storage
  static Future<void> _putUser(User user) async {
    await DaoSecuredString.put(
      key: _USER_ID,
      value: user.userId,
    );
    await DaoSecuredString.put(
      key: _PASSWORD,
      value: user.password,
    );
  }

  /// Checks if some credentials exist in storage
  static Future<bool> _checkCredentialsInStorage() async {
    final bool userId = await DaoSecuredString.contains(key: _USER_ID);
    final bool password = await DaoSecuredString.contains(key: _PASSWORD);

    return userId && password;
  }
}
