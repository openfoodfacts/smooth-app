import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/pages/abstract_user_preferences.dart';
import 'package:smooth_app/pages/onboarding/country_selector.dart';
import 'package:smooth_app/pages/user_management/login_page.dart';
import 'package:smooth_ui_library/buttons/smooth_simple_button.dart';
import 'package:smooth_ui_library/dialogs/smooth_alert_dialog.dart';

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
  List<Widget> getBody() => <Widget>[
        ListTile(
          leading: const Icon(Icons.supervised_user_circle),
          title: const Text('User management'),
          onTap: () => Navigator.push<Widget>(
            context,
            MaterialPageRoute<Widget>(
              builder: (BuildContext context) => const LoginPage(),
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.public),
          title: CountrySelector(
            initialCountryCode: userPreferences.userCountryCode,
          ),
        ),
        ListTile(
          leading: const Icon(Icons.rotate_left),
          title: Text(appLocalizations.reset_food_preferences),
          onTap: () => _confirmReset(context),
        ),
      ];

  void _confirmReset(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SmoothAlertDialog(
          body: Text(localizations.confirm_reset_food_preferences),
          actions: <SmoothSimpleButton>[
            SmoothSimpleButton(
              text: localizations.yes,
              onPressed: () async {
                await context.read<ProductPreferences>().resetImportances();
                Navigator.pop(context);
              },
            ),
            SmoothSimpleButton(
              text: localizations.no,
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
