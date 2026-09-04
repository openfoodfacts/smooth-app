import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/login_result.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/database/dao_secured_string.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/services/smooth_services.dart';

class UserManagementProvider with ChangeNotifier {
  static const String _USER_ID = 'user_id';
  static const String _PASSWORD = 'pasword';
  static const String _COOKIE = 'user_cookie';
  static const String _USER_DETAILS = 'user_details';

  static UserDetails? globalUserDetails;

  /// Checks credentials and conditionally saves them.
  Future<LoginResult> login(
    final User user,
    final UserPreferences preferences,
  ) async {
    final LoginResult loginResult = await LoginResult.getLoginResult(
      user,
      preferences,
    );
    if (loginResult.type != LoginResultType.successful) {
      return loginResult;
    }
    await putUser(loginResult.user!);
    await _saveUserDetails(loginResult.userDetails);
    await credentialsInStorage();
    return loginResult;
  }

  /// Saves user details to storage
  Future<void> _saveUserDetails(UserDetails? userDetails) async {
    globalUserDetails = userDetails;
    if (userDetails != null) {
      final String jsonString = jsonEncode(userDetails.toJson());
      await DaoSecuredString.put(key: _USER_DETAILS, value: jsonString);
    } else {
      DaoSecuredString.remove(key: _USER_DETAILS);
    }
    notifyListeners();
  }

  /// Deletes saved credentials from storage
  Future<bool> logout() async {
    OpenFoodAPIConfiguration.globalUser = null;
    globalUserDetails = null;
    DaoSecuredString.remove(key: _USER_ID);
    DaoSecuredString.remove(key: _PASSWORD);
    DaoSecuredString.remove(key: _COOKIE);
    DaoSecuredString.remove(key: _USER_DETAILS);
    notifyListeners();
    final bool contains = await credentialsInStorage();
    return !contains;
  }

  /// Mounts already stored credentials, called at app startup
  ///
  /// We can use optional parameters to mock in tests
  static Future<void> mountCredentials({
    String? userId,
    String? password,
  }) async {
    String? effectiveUserId;
    String? effectivePassword;
    String? effectiveCookie;
    String? userDetailsJson;

    try {
      effectiveUserId = userId ?? await DaoSecuredString.get(_USER_ID);
      effectivePassword = password ?? await DaoSecuredString.get(_PASSWORD);
      effectiveCookie = await DaoSecuredString.get(_COOKIE);
      userDetailsJson = await DaoSecuredString.get(_USER_DETAILS);
    } on PlatformException {
      /// Decrypting the values can go wrong if, for example, the app was
      /// manually overwritten from an external apk.
      DaoSecuredString.remove(key: _USER_ID);
      DaoSecuredString.remove(key: _PASSWORD);
      DaoSecuredString.remove(key: _COOKIE);
      DaoSecuredString.remove(key: _USER_DETAILS);
      Logs.e('Credentials query failed, you have been logged out');
    }

    if (effectiveUserId == null || effectivePassword == null) {
      return;
    }

    final User user = User(
      userId: effectiveUserId,
      password: effectivePassword,
      cookie: effectiveCookie,
    );
    OpenFoodAPIConfiguration.globalUser = user;

    // Restore complete UserDetails from JSON
    if (userDetailsJson != null && userDetailsJson.isNotEmpty) {
      try {
        final Map<String, dynamic> json = jsonDecode(userDetailsJson);
        globalUserDetails = UserDetails.fromJson(json);
      } catch (e) {
        Logs.e('Failed to parse UserDetails: $e');
        DaoSecuredString.remove(key: _USER_DETAILS);
      }
    }
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
    await DaoSecuredString.put(key: _USER_ID, value: user.userId);
    await DaoSecuredString.put(key: _PASSWORD, value: user.password);
    if (user.cookie != null) {
      await DaoSecuredString.put(key: _COOKIE, value: user.cookie!);
    } else {
      DaoSecuredString.remove(key: _COOKIE);
    }
    notifyListeners();
  }

  /// Check if the user is still logged in and the credentials are still valid
  /// If not, the user is logged out
  Future<void> checkUserLoginValidity(UserPreferences preferences) async {
    if (!ProductQuery.isLoggedIn()) {
      return;
    }
    final User user = ProductQuery.getWriteUser();
    final LoginResult loginResult = await LoginResult.getLoginResult(
      User(userId: user.userId, password: user.password),
      preferences,
    );

    if (loginResult.type == LoginResultType.unsuccessful) {
      // TODO(m123): Notify the user
      await logout();
      return;
    }

    /// Save the cookie and user details if necessary
    if (user.cookie == null && loginResult.user?.cookie != null) {
      await putUser(loginResult.user!);
      await _saveUserDetails(loginResult.userDetails);
    }
  }
}
