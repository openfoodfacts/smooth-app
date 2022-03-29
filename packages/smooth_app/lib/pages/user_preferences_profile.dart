import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mailto/mailto.dart';
import 'package:openfoodfacts/utils/OpenFoodAPIConfiguration.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_action_button.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/pages/abstract_user_preferences.dart';
import 'package:smooth_app/pages/onboarding/country_selector.dart';
import 'package:smooth_app/pages/user_management/login_page.dart';
import 'package:url_launcher/url_launcher.dart';

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
    return <Widget>[
      UserPreferencesSection(
        userPreferences: userPreferences,
        appLocalizations: appLocalizations,
        themeData: themeData,
      ),
    ];
  }
}

// Put into it's own widget in order for provider.watch() to work
class UserPreferencesSection extends StatefulWidget {
  const UserPreferencesSection({
    Key? key,
    required this.userPreferences,
    required this.appLocalizations,
    required this.themeData,
  }) : super(key: key);

  final UserPreferences userPreferences;
  final AppLocalizations appLocalizations;
  final ThemeData themeData;

  @override
  State<UserPreferencesSection> createState() => _UserPreferencesPageState();
}

class _UserPreferencesPageState extends State<UserPreferencesSection> {
  void _confirmLogout(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SmoothAlertDialog(
          close: false,
          title: localizations.sign_out,
          body: Text(
            localizations.sign_out_confirmation,
          ),
          actions: <SmoothActionButton>[
            SmoothActionButton(
              text: localizations.yes,
              onPressed: () async {
                context.read<UserManagementProvider>().logout();
                Navigator.pop(context);
              },
            ),
            SmoothActionButton(
              text: localizations.no,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final UserManagementProvider userManagementProvider =
        context.watch<UserManagementProvider>();

    final ThemeData theme = Theme.of(context);
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final Size size = MediaQuery.of(context).size;

    final List<Widget> result = <Widget>[];

    if (userManagementProvider.isLoading) {
      //Loading
      result.add(const Center(child: CircularProgressIndicator()));
    } else if (OpenFoodAPIConfiguration.globalUser != null) {
      //Credentials
      final String userId = OpenFoodAPIConfiguration.globalUser!.userId;
      result.add(
        ListTile(
          onTap: () async => LaunchUrlHelper.launchURL(
            'https://openfoodfacts.org/editor/$userId',
            true,
          ),
          title: Text(appLocalizations.view_profile),
          leading: const Icon(Icons.open_in_new),
        ),
      );
      result.add(
        ListTile(
          onTap: () => _confirmLogout(context),
          title: Text(appLocalizations.sign_out),
          leading: const Icon(Icons.clear),
        ),
      );
      result.add(
        ListTile(
          onTap: () async {
            final Mailto mailtoLink = Mailto(
              to: <String>['contact@openfoodfacts.org'],
              subject: 'Delete account', // TODO(monsieurtanuki): localize
              body: 'Hi there, please delete my openfoodfacts account: $userId',
            );
            await launch('$mailtoLink');
          },
          title: const Text('Delete account'),
          leading: const Icon(Icons.delete),
        ),
      );
    } else {
      // No credentials
      result.add(
        Center(
          child: ElevatedButton(
            onPressed: () async {
              Navigator.push<dynamic>(
                context,
                MaterialPageRoute<dynamic>(
                  builder: (BuildContext context) => const LoginPage(),
                ),
              );
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
                const RoundedRectangleBorder(
                  borderRadius: CIRCULAR_BORDER_RADIUS,
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
            initialCountryCode: widget.userPreferences.userCountryCode,
          ),
        ),
        SwitchListTile(
          title: const Text(
            'Crash reporting', // TODO(monsieurtanuki): localize
          ),
          subtitle: const Text(
            'When enabled, crash reports will be sent to the Open Food Facts server automatically, so that we can fix bugs and improve the app.',
          ),
          isThreeLine: true,
          value: widget.userPreferences.crashReports,
          onChanged: (final bool value) async {
            await widget.userPreferences.setCrashReports(value);
            AnalyticsHelper.setCrashReports(value);
            setState(() {});
          },
        ),
        SwitchListTile(
          title: const Text(
            'Send anonymous data', // TODO(monsieurtanuki): localize
          ),
          subtitle: const Text(
            'When enabled, some anonymous information regarding app usage will be sent to the Open Food Facts servers, so that we can understand how and how much features are used in order to improve them.',
          ),
          isThreeLine: true,
          value: widget.userPreferences.analyticsReports,
          onChanged: (final bool value) async {
            await widget.userPreferences.setAnalyticsReports(value);
            AnalyticsHelper.setAnalyticsReports(value);
            setState(() {});
          },
        ),
      ],
    );

    return Column(children: result);
  }
}
