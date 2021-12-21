import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/OpenFoodAPIConfiguration.dart';
import 'package:smooth_app/database/dao_secured_string.dart';

class UserManagementHelper {
  UserManagementHelper._();

  static const String USER_ID = 'user_id';
  static const String PASSWORD = 'pasword';

  /// Checks credentials and conditionally saves them
  static Future<bool?> login(User user) async {
    final bool rightCredentials;
    try {
      rightCredentials = await OpenFoodAPIClient.login(user);
    } catch (e) {
      // Returning null to show a error on the page
      return null;
    }

    if (rightCredentials) {
      OpenFoodAPIConfiguration.globalUser = user;
      _putUser(user);
    }

    return rightCredentials && await _checkCredentialsInStorage();
  }

  /// Checks if the saved credentials are still valid
  /// and mounts credentials for use in queries
  static Future<bool?> checkAndReMountCredentials() async {
    final String? userId = await DaoSecuredString.get(USER_ID);
    final String? password = await DaoSecuredString.get(PASSWORD);

    if (userId == null || password == null) {
      return false;
    }

    final User user = User(userId: userId, password: password);

    final bool rightCredentials;
    try {
      rightCredentials = await OpenFoodAPIClient.login(user);
    } catch (e) {
      // Returning null to show a error
      return null;
    }

    if (rightCredentials) {
      OpenFoodAPIConfiguration.globalUser = user;
    }

    return rightCredentials;
  }

  /// Deletes saved credentials from storage
  static Future<bool> logout() async {
    OpenFoodAPIConfiguration.globalUser = null;
    DaoSecuredString.remove(key: USER_ID);
    DaoSecuredString.remove(key: PASSWORD);
    final bool contains = await _checkCredentialsInStorage();
    return !contains;
  }

  /// Saves user to storage
  static Future<void> _putUser(User user) async {
    await DaoSecuredString.put(
      key: USER_ID,
      value: user.userId,
    );
    await DaoSecuredString.put(
      key: PASSWORD,
      value: user.password,
    );
  }

  /// Checks if some credentials exist in storage
  static Future<bool> _checkCredentialsInStorage() async {
    final bool userId = await DaoSecuredString.contains(key: USER_ID);
    final bool password = await DaoSecuredString.contains(key: PASSWORD);

    return userId && password;
  }
}
