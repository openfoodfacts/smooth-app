import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/helpers/user_management_helper.dart';
import 'package:smooth_app/pages/abstract_user_preferences.dart';
import 'package:smooth_app/pages/user_management/login_page.dart';
import 'package:smooth_app/themes/theme_provider.dart';

/// Collapsed/expanded display of profile for the preferences page.
class UserPreferencesProfile extends AbstractUserPreferences {
  UserPreferencesProfile(final Function(Function()) setState) : super(setState);

  @override
  bool isCollapsedByDefault() => true;

  @override
  String getPreferenceFlagKey() => 'profile';

  @override
  String getTitle() => 'Your Profile';

  @override
  String getSubtitle() => 'Set app settings and find out advices and blah blah';

  @override
  List<Widget> getBody(
    final BuildContext context,
    final AppLocalizations appLocalizations,
    final ThemeProvider themeProvider,
    final ThemeData themeData,
  ) =>
      <Widget>[
        ListTile(
          leading: const Icon(Icons.threesixty_outlined),
          title: const Text('Check credentials'),
          onTap: () async {
            final bool correct =
                await UserManagementHelper.checkAndReMountCredentials();

            final SnackBar snackBar = SnackBar(
              content: Text('It is $correct'),
              action: SnackBarAction(
                label: 'Logout',
                onPressed: () async {
                  UserManagementHelper.logout();
                },
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          },
        ),
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
          leading: const Icon(Icons.rotate_left),
          title: Text(appLocalizations.reset),
          onTap: () => _confirmReset(context),
        ),
      ];

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
