import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/OpenFoodAPIConfiguration.dart';
import 'package:smooth_app/database/dao_secured_string.dart';

class UserManagementHelper {
  UserManagementHelper._();

  static const String _USER_ID = 'user_id';
  static const String _PASSWORD = 'pasword';

  /// cf. https://stackoverflow.com/questions/63292839/how-to-validate-email-in-a-textformfield
  // TODO(monsieurtanuki): check if we can find something more relevant
  static const String _emailPattern =
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
      r'{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]'
      r'{0,253}[a-zA-Z0-9])?)*$';
  static final RegExp _emailRegex = RegExp(_emailPattern);

  static const String _userPattern = r'^[a-z0-9]+$';
  static final RegExp _userRegex = RegExp(_userPattern);

  /// Checks credentials and conditionally saves them
  static Future<bool> login(User user) async {
    final bool rightCredentials;
    try {
      rightCredentials = await OpenFoodAPIClient.login(user);
    } catch (e) {
      throw Exception(e);
    }

    if (rightCredentials) {
      await put(user);
    }

    return rightCredentials && await credentialsInStorage();
  }

  /// Puts the [User] in the preferences
  static Future<void> put(User user) async {
    OpenFoodAPIConfiguration.globalUser = user;
    await _putUser(user);
  }

  /// Mounts stored credentials
  static Future<void> mountCredentials() async {
    final String? userId = await DaoSecuredString.get(_USER_ID);
    final String? password = await DaoSecuredString.get(_PASSWORD);

    if (userId == null || password == null) {
      return;
    }

    final User user = User(userId: userId, password: password);

    OpenFoodAPIConfiguration.globalUser = user;
  }

  /// Checks if the saved credentials are still correct
  static Future<bool> validateCredentials() async {
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
    final bool contains = await credentialsInStorage();
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
  static Future<bool> credentialsInStorage() async {
    final bool userId = await DaoSecuredString.contains(key: _USER_ID);
    final bool password = await DaoSecuredString.contains(key: _PASSWORD);

    return userId && password;
  }

  static bool isEmailValid(final String email) =>
      email.isNotEmpty && _emailRegex.hasMatch(email);

  static bool isUsernameValid(final String username) =>
      username.isNotEmpty && _userRegex.hasMatch(username);

  static bool isPasswordValid(final String password) => password.length >= 6;
}
