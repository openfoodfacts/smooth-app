import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/utils/OpenFoodAPIConfiguration.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/helpers/user_management_helper.dart';
import 'package:smooth_app/pages/abstract_user_preferences.dart';
import 'package:smooth_app/pages/onboarding/country_selector.dart';
import 'package:smooth_app/pages/user_management/login_page.dart';

/// Collapsed/expanded display of profile for the preferences page.
class UserPreferencesProfile extends AbstractUserPreferences {
  UserPreferencesProfile({
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
  String getPreferenceFlagKey() => 'profile';

  @override
  Widget getTitle() => Text(
        appLocalizations.myPreferences_profile_title,
        style: themeData.textTheme.headline2,
      );

  @override
  Widget? getSubtitle() =>
      Text(appLocalizations.myPreferences_profile_subtitle);

  @override
  List<Widget> getBody() {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final Size size = MediaQuery.of(context).size;

    final List<Widget> result = <Widget>[];

    //Credentials exist
    if (OpenFoodAPIConfiguration.globalUser != null) {
      result.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => LaunchUrlHelper.launchURL(
                'https://openfoodfacts.org/editor/${OpenFoodAPIConfiguration.globalUser!.userId}',
                true,
              ),
              child: Row(
                children: <Widget>[
                  Text(
                    appLocalizations.view_profile,
                    style: theme.textTheme.bodyText2?.copyWith(
                      fontSize: 18.0,
                      color: theme.colorScheme.surface,
                    ),
                  ),
                  const Icon(Icons.open_in_new),
                ],
              ),
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all<Size>(
                  Size(size.width * 0.33, theme.buttonTheme.height + 10),
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(300.0),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                UserManagementHelper.logout();
                setState(() {});
              },
              child: Text(
                appLocalizations.sign_out,
                style: theme.textTheme.bodyText2?.copyWith(
                  fontSize: 18.0,
                  color: theme.colorScheme.surface,
                ),
              ),
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all<Size>(
                  Size(size.width * 0.33, theme.buttonTheme.height + 10),
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(300.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // No credentials
      result.add(
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push<dynamic>(
                context,
                MaterialPageRoute<dynamic>(
                  builder: (BuildContext context) => const LoginPage(),
                ),
              );
              setState(() {});
            },
            child: Text(
              appLocalizations.sign_in,
              style: theme.textTheme.bodyText2?.copyWith(
                fontSize: 18.0,
                color: theme.colorScheme.surface,
              ),
            ),
            style: ButtonStyle(
              minimumSize: MaterialStateProperty.all<Size>(
                Size(size.width * 0.5, theme.buttonTheme.height + 10),
              ),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(300.0),
                ),
              ),
            ),
          ),
        ),
      );
    }

    result.addAll(
      <Widget>[
        ListTile(
          leading: const Icon(Icons.public),
          title: CountrySelector(
            initialCountryCode: userPreferences.userCountryCode,
          ),
        ),
        ListTile(
          leading: const Icon(Icons.rotate_left),
          title: Text(appLocalizations.reset),
          onTap: () => _confirmReset(context),
        ),
      ],
    );

    return result;
  }

  void _confirmReset(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.confirmResetPreferences),
          actions: <Widget>[
            TextButton(
              child: Text(localizations.yes),
              onPressed: () async {
                await context.read<ProductPreferences>().resetImportances();
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text(localizations.no),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }
}
