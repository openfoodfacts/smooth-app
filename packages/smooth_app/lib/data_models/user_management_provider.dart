import 'package:flutter/cupertino.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/OpenFoodAPIConfiguration.dart';
import 'package:smooth_app/database/dao_secured_string.dart';

class UserManagementProvider with ChangeNotifier {
  static const String _USER_ID = 'user_id';
  static const String _PASSWORD = 'pasword';

  bool _finishedLoading = false;

  bool get isLoading => !_finishedLoading;

  /// Checks credentials and conditionally saves them
  Future<bool> login(User user) async {
    final bool rightCredentials;
    try {
      rightCredentials = await OpenFoodAPIClient.login(user);
    } catch (e) {
      throw Exception(e);
    }

    if (rightCredentials) {
      await putUser(user);
    }

    return rightCredentials && await credentialsInStorage();
  }

  /// Deletes saved credentials from storage
  Future<bool> logout() async {
    OpenFoodAPIConfiguration.globalUser = null;
    DaoSecuredString.remove(key: _USER_ID);
    DaoSecuredString.remove(key: _PASSWORD);
    notifyListeners();
    final bool contains = await credentialsInStorage();
    return !contains;
  }

  /// Mounts already stored credentials, called at app startup
  Future<void> mountCredentials() async {
    final String? userId = await DaoSecuredString.get(_USER_ID);
    final String? password = await DaoSecuredString.get(_PASSWORD);

    if (userId == null || password == null) {
      _finishedLoading = true;
      notifyListeners();
      return;
    }

    final User user = User(userId: userId, password: password);
    OpenFoodAPIConfiguration.globalUser = user;
    _finishedLoading = true;
    notifyListeners();
  }

  /// Checks if any credentials exist in storage
  Future<bool> credentialsInStorage() async {
    final bool userId = await DaoSecuredString.contains(key: _USER_ID);
    final bool password = await DaoSecuredString.contains(key: _PASSWORD);

    return userId && password;
  }

  /// Saves user to storage
  Future<void> putUser(User user) async {
    OpenFoodAPIConfiguration.globalUser = user;
    await DaoSecuredString.put(
      key: _USER_ID,
      value: user.userId,
    );
    await DaoSecuredString.put(
      key: _PASSWORD,
      value: user.password,
    );
    notifyListeners();
  }

  /* Currently not in use, to be used before contributing to something
  /// Checks if the saved credentials are still correct
  Future<bool> validateCredentials() async {
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
  */

}
