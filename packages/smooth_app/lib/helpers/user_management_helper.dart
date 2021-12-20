import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/OpenFoodAPIConfiguration.dart';
import 'package:smooth_app/database/dao_secured_string.dart';
import 'package:smooth_app/database/local_database.dart';

class UserManagementHelper {
  UserManagementHelper({required this.localDatabase});

  final LocalDatabase localDatabase;

  /// Checks credentials and conditionally saves them
  Future<bool> smoothieLogin(User user) async {
    final bool rightCredentials = await OpenFoodAPIClient.login(user);

    if (rightCredentials) {
      _putUser(user);
    }

    return rightCredentials && _checkCredentialsInStorage();
  }

  /// Checks if the saved credentials are still valid
  /// and mounts credentials for use in queries
  Future<bool> checkAndMountCredentials() async {
    final String? userId =
        DaoSecuredString(localDatabase).get(SecuredValues.USER_ID);
    final String? password =
        DaoSecuredString(localDatabase).get(SecuredValues.PASSWORD);

    if (userId == null || password == null) {
      return false;
    }

    final User user = User(userId: userId, password: password);

    final bool rightCredentials = await OpenFoodAPIClient.login(user);

    if (rightCredentials) {
      OpenFoodAPIConfiguration.globalUser = user;
    }

    return rightCredentials;
  }

  /// Deletes saved credentials from storage
  bool smoothieLogout() {
    OpenFoodAPIConfiguration.globalUser = null;
    DaoSecuredString(localDatabase).remove(type: SecuredValues.USER_ID);
    DaoSecuredString(localDatabase).remove(type: SecuredValues.PASSWORD);

    return !_checkCredentialsInStorage();
  }

  /// Saves user to storage
  void _putUser(User user) {
    DaoSecuredString(localDatabase).put(
      type: SecuredValues.USER_ID,
      value: user.userId,
    );
    DaoSecuredString(localDatabase).put(
      type: SecuredValues.PASSWORD,
      value: user.password,
    );
  }

  /// Checks if some credentials exist in storage
  bool _checkCredentialsInStorage() {
    final bool userId =
        DaoSecuredString(localDatabase).contains(type: SecuredValues.USER_ID);
    final bool password =
        DaoSecuredString(localDatabase).contains(type: SecuredValues.PASSWORD);

    return userId && password;
  }
}
