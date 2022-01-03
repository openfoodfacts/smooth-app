import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/pages/abstract_user_preferences.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';

/// Collapsed/expanded display of "dev mode" for the preferences page.
///
/// The dev mode is triggered this way:
/// * go to the "forgotten password" page
/// * click 10 times on the action button (in French "Changer le mot de passe")
/// * you'll see a dialog; obviously click "yes"
/// * go to the preferences page
/// * expand/collapse any item
/// * then you'll see the dev mode in red
class UserPreferencesDevMode extends AbstractUserPreferences {
  UserPreferencesDevMode({
    required final Function(Function()) setState,
    required final BuildContext context,
    required final UserPreferences userPreferences,
    required final AppLocalizations appLocalizations,
    required final ThemeData themeData,
  }) : super(
          setState: setState,
          context: context,
          userPreferences: userPreferences,
          appLocalizations: appLocalizations,
          themeData: themeData,
        );

  @override
  bool isCollapsedByDefault() => true;

  @override
  String getPreferenceFlagKey() => 'devMode';

  @override
  Widget getTitle() => Container(
        color: Colors.red,
        child: Text(
          'DEV MODE',
          style: themeData.textTheme.headline2!.copyWith(color: Colors.white),
        ),
      );

  @override
  Widget? getSubtitle() => null;

  @override
  List<Widget> getBody() => <Widget>[
        ListTile(
          title: const Text('Remove dev mode'),
          onTap: () async {
            userPreferences.devMode = 0;
            setState(() {});
          },
        ),
        ListTile(
          title: const Text('restart onboarding'),
          subtitle: const Text('then you have to restart flutter'),
          onTap: () async {
            userPreferences
                .setLastVisitedOnboardingPage(OnboardingPage.NOT_STARTED);
            setState(() {});
          },
        ),
      ];
}
