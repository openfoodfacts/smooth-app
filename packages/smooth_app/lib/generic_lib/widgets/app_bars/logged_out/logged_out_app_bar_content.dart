import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/logged_out/app_bar_authentication_button.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/user_management/login_page.dart';
import 'package:smooth_app/pages/user_management/sign_up_page.dart';

class LoggedOutAppBarContent extends StatelessWidget {
  const LoggedOutAppBarContent({super.key});

  static const double MIN_HEIGHT = 73.0;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return IntrinsicHeight(
      child: Row(
        spacing: MEDIUM_SPACE,
        children: <Widget>[
          Expanded(
            child: AppBarAuthenticationButton(
              title: appLocalizations.create_account,
              onPressed: () {
                Navigator.of(context, rootNavigator: true).push<dynamic>(
                  MaterialPageRoute<dynamic>(
                    builder: (BuildContext context) => const SignUpPage(),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: AppBarAuthenticationButton(
              title: appLocalizations.sign_in,
              onPressed: () {
                Navigator.of(context, rootNavigator: true).push<dynamic>(
                  MaterialPageRoute<dynamic>(
                    builder: (BuildContext context) => const LoginPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
