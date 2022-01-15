import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/utils/OpenFoodAPIConfiguration.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/product_query.dart';
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

  static const String userPreferencesFlagProd = '__devWorkingOnProd';
  static const String userPreferencesFlagUseMLKit = '__useMLKit';

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
            // resetting back to "no dev mode"
            await userPreferences.setDevMode(0);
            // resetting back to PROD
            await userPreferences.setFlag(userPreferencesFlagProd, true);
            ProductQuery.setQueryType(userPreferences);
            setState(() {});
          },
        ),
        ListTile(
          title: const Text('Restart onboarding'),
          subtitle:
              const Text('You then have to restart Flutter to see it again.'),
          onTap: () async {
            userPreferences
                .setLastVisitedOnboardingPage(OnboardingPage.NOT_STARTED);
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Ok')));
          },
        ),
        ListTile(
          title: const Text('Switch between openfoodfacts.org and .net'),
          subtitle: Text(
            'Current query type is ${OpenFoodAPIConfiguration.globalQueryType}',
          ),
          onTap: () async {
            await userPreferences.setFlag(userPreferencesFlagProd,
                !(userPreferences.getFlag(userPreferencesFlagProd) ?? true));
            ProductQuery.setQueryType(userPreferences);
            setState(() {});
          },
        ),
        SwitchListTile(
          title: const Text('Use ML Kit'),
          subtitle: const Text('then you have to restart this app'),
          value: userPreferences.getFlag(userPreferencesFlagUseMLKit) ?? true,
          onChanged: (bool value) async {
            await userPreferences.setFlag(userPreferencesFlagUseMLKit, value);
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Ok')));
          },
        ),
        ListTile(
          title: const Text('Export History'),
          onTap: () async {
            final LocalDatabase localDatabase = context.read<LocalDatabase>();
            final Map<String, dynamic> export =
                await DaoProductList(localDatabase).export(
              ProductList.history(),
            );
            debugPrint('exported history: $export', wrapWidth: 80);
          },
        ),
      ];
}
