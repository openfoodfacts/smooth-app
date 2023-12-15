import 'package:email_validator/email_validator.dart';
import 'package:flutter/widgets.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class UserManagementHelper {
  UserManagementHelper._();

  static const String _userPattern = r'^[a-z0-9]+$';
  static final RegExp _userRegex = RegExp(_userPattern);

  static bool isEmailValid(final String email) =>
      EmailValidator.validate(email);

  static bool isUsernameValid(final String username) =>
      username.isNotEmpty && _userRegex.hasMatch(username);

  static bool isUsernameLengthValid(final String username) =>
      username.length <= OpenFoodAPIClient.USER_NAME_MAX_LENGTH;

  static bool isPasswordValid(final String password) => password.length >= 6;
}

extension UserManagementTextController on TextEditingController {
  String get trimmedText => text.trim();
}

extension UserManagementEmail on String {
  bool get isEmail => EmailValidator.validate(this);
}
