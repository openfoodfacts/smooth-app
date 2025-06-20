import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:smooth_app/query/product_query.dart';

/// How did the login attempt work?
enum LoginResultType {
  successful,
  unsuccessful,
  serverIssue,
  exception,
}

/// Result of a log in attempt, more subtle than a `bool`.
class LoginResult {
  const LoginResult(this.type, {this.user, this.text});

  final LoginResultType type;
  final User? user;
  final String? text;

  String getErrorMessage(final AppLocalizations appLocalizations) =>
      switch (type) {
        LoginResultType.successful => 'not supposed to happen',
        LoginResultType.unsuccessful => appLocalizations.incorrect_credentials,
        LoginResultType.serverIssue =>
          appLocalizations.login_result_type_server_issue,
        LoginResultType.exception => isNoNetworkException(text!)
            ? appLocalizations.login_result_type_server_unreachable
            : text!,
      };

  static bool isNoNetworkException(final String text) =>
      text == 'Network is unreachable' ||
      text.startsWith('Failed host lookup: ');

  /// Checks credentials. Returns null if OK, or an error message.
  static Future<LoginResult> getLoginResult(
    final User user,
    final UserPreferences userPreferences,
  ) async {
    try {
      final bool prodUrl = userPreferences
              .getFlag(UserPreferencesDevMode.userPreferencesFlagProd) ??
          true;

      final LoginStatus? loginStatus = await OpenFoodAPIClient.login2(
        user,
        uriHelper: ProductQuery.getUriProductHelper(
          productType: prodUrl ? ProductType.food : null,
        ),
      );
      if (loginStatus == null) {
        return const LoginResult(LoginResultType.serverIssue);
      }
      if (!loginStatus.successful) {
        return const LoginResult(LoginResultType.unsuccessful);
      }
      return LoginResult(
        LoginResultType.successful,
        user: User(
          userId: loginStatus.userId!,
          password: user.password,
          cookie: loginStatus.cookie,
        ),
      );
    } catch (e) {
      return LoginResult(LoginResultType.exception, text: e.toString());
    }
  }
}
