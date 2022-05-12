import 'package:flutter/widgets.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class UserManagementHelper {
  UserManagementHelper._();

  /// cf. https://stackoverflow.com/questions/63292839/how-to-validate-email-in-a-textformfield
  // TODO(monsieurtanuki): check if we can find something more relevant
  static const String _emailPattern =
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
      r'{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]'
      r'{0,253}[a-zA-Z0-9])?)*$';
  static final RegExp _emailRegex = RegExp(_emailPattern);

  static const String _userPattern = r'^[a-z0-9]+$';
  static final RegExp _userRegex = RegExp(_userPattern);

  static bool isEmailValid(final String email) =>
      email.isNotEmpty && _emailRegex.hasMatch(email);

  static bool isUsernameValid(final String username) =>
      username.isNotEmpty && _userRegex.hasMatch(username);

  static bool isUsernameLengthValid(final String username) =>
      username.length <= OpenFoodAPIClient.USER_NAME_MAX_LENGTH;

  static bool isPasswordValid(final String password) => password.length >= 6;
}

extension UserManagementTextController on TextEditingController {
  String get trimmedText => text.trim();
}
