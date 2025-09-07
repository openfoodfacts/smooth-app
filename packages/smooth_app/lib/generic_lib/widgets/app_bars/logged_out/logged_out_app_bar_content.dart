import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/app_bar_background.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/app_bar_constanst.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/logged_out/app_bar_authentication_button.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/user_management/login_page.dart';
import 'package:smooth_app/pages/user_management/sign_up_page.dart';

class LoggedOutAppBarContent extends StatelessWidget {
  const LoggedOutAppBarContent({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return FlexibleSpaceBar(
      collapseMode: CollapseMode.none,
      background: Padding(
        padding: const EdgeInsetsDirectional.only(bottom: SEARCH_BOTTOM_HEIGHT),
        child: AppBarBackground(
          height: LOGGED_OUT_APP_BAR_EXPANDED_HEIGHT,
          child: Container(
            margin: EdgeInsetsDirectional.only(
              top:
                  MediaQuery.paddingOf(context).top +
                  TOOLBAR_HEIGHT +
                  MEDIUM_SPACE,
            ),
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: MEDIUM_SPACE,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: AppBarAuthenticationButton(
                        title: appLocalizations.create_account,
                        onPressed: () {
                          Navigator.of(
                            context,
                            rootNavigator: true,
                          ).push<dynamic>(
                            MaterialPageRoute<dynamic>(
                              builder: (BuildContext context) =>
                                  const SignUpPage(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: MEDIUM_SPACE),
                    Expanded(
                      child: AppBarAuthenticationButton(
                        title: appLocalizations.sign_in,
                        onPressed: () {
                          Navigator.of(
                            context,
                            rootNavigator: true,
                          ).push<dynamic>(
                            MaterialPageRoute<dynamic>(
                              builder: (BuildContext context) =>
                                  const LoginPage(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
