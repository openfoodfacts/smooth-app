import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/OpenFoodAPIConfiguration.dart';
import 'package:smooth_app/database/dao_secured_string.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/services/smooth_services.dart';

class UserManagementProvider with ChangeNotifier {
  static const String _USER_ID = 'user_id';
  static const String _PASSWORD = 'pasword';

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
      notifyListeners();
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
  static Future<void> mountCredentials() async {
    String? userId;
    String? password;

    try {
      userId = await DaoSecuredString.get(_USER_ID);
      password = await DaoSecuredString.get(_PASSWORD);
    } on PlatformException {
      /// Decrypting the values can go wrong if, for example, the app was
      /// manually overwritten from an external apk.
      DaoSecuredString.remove(key: _USER_ID);
      DaoSecuredString.remove(key: _PASSWORD);
      Logs.e('Credentials query failed, you have been logged out');
    }

    if (userId == null || password == null) {
      return;
    }

    final User user = User(userId: userId, password: password);
    OpenFoodAPIConfiguration.globalUser = user;
  }

  /// Checks if any credentials exist in storage
  Future<bool> credentialsInStorage() async {
    final String? userId = await DaoSecuredString.get(_USER_ID);
    final String? password = await DaoSecuredString.get(_PASSWORD);

    return userId != null && password != null;
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

  /// Check if the user is still logged in and the credentials are still valid
  /// If not, the user is logged out
  Future<void> checkUserLoginValidity() async {
    try {
      if (ProductQuery.isLoggedIn()) {
        final User user = ProductQuery.getUser();
        final bool checkLogin = await OpenFoodAPIClient.login(
          User(
            userId: user.userId,
            password: user.password,
          ),
        );
        if (checkLogin) {
          // Credentials are still valid so we just return
          return;
        } else {
          // Credentials are not valid anymore so we log out
          await logout();
        }
      }
    } catch (e) {
      // We don't want to crash the app if the login check fails
      // So we do nothing here
    }
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
