import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openfoodfacts/model/LoginStatus.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/OpenFoodAPIConfiguration.dart';
import 'package:smooth_app/database/dao_secured_string.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/services/smooth_services.dart';

class UserManagementProvider with ChangeNotifier {
  static const String _USER_ID = 'user_id';
  static const String _PASSWORD = 'pasword';

  // TODO(m123): Show why its failing
  /// Checks credentials and conditionally saves them
  Future<bool> login(User user) async {
    final LoginStatus? loginStatus;
    try {
      loginStatus = await OpenFoodAPIClient.login2(user);
    } catch (e) {
      throw Exception(e);
    }

    if (loginStatus == null) {
      return false;
    }

    if (loginStatus.successful) {
      await putUser(user);
      notifyListeners();
    }

    return loginStatus.successful && await credentialsInStorage();
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
  ///
  /// We can use optional parameters to mock in tests
  static Future<void> mountCredentials(
      {String? userId, String? password}) async {
    String? effectiveUserId;
    String? effectivePassword;

    try {
      effectiveUserId = userId ?? await DaoSecuredString.get(_USER_ID);
      effectivePassword = password ?? await DaoSecuredString.get(_PASSWORD);
    } on PlatformException {
      /// Decrypting the values can go wrong if, for example, the app was
      /// manually overwritten from an external apk.
      DaoSecuredString.remove(key: _USER_ID);
      DaoSecuredString.remove(key: _PASSWORD);
      Logs.e('Credentials query failed, you have been logged out');
    }

    if (effectiveUserId == null || effectivePassword == null) {
      return;
    }

    final User user =
        User(userId: effectiveUserId, password: effectivePassword);
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
        final LoginStatus? loginStatus = await OpenFoodAPIClient.login2(
          User(
            userId: user.userId,
            password: user.password,
          ),
        );
        if (loginStatus == null) {
          // No internet or sever down
          return;
        }
        if (loginStatus.successful) {
          // Credentials are still valid so we just return
          return;
        } else {
          // Credentials are not valid anymore so we log out
          // TODO(m123): Notify the user
          await logout();
        }
      }
    } catch (e) {
      // We don't want to crash the app if the login check fails
      // So we do nothing here
    }
  }
}
