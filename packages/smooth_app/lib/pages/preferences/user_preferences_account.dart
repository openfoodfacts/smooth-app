import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mailto/mailto.dart';
import 'package:openfoodfacts/utils/OpenFoodAPIConfiguration.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/helpers/user_management_helper.dart';
import 'package:smooth_app/pages/onboarding/country_selector.dart';
import 'package:smooth_app/pages/preferences/abstract_user_preferences.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/pages/preferences/user_preferences_widgets.dart';
import 'package:smooth_app/pages/user_management/login_page.dart';
import 'package:url_launcher/url_launcher.dart';

class UserPreferencesAccount extends AbstractUserPreferences {
  UserPreferencesAccount({
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
  List<Widget> getBody() {
    return <Widget>[
      UserPreferencesSection(
        userPreferences: userPreferences,
        appLocalizations: appLocalizations,
        themeData: themeData,
      ),
    ];
  }

  @override
  PreferencePageType? getPreferencePageType() => PreferencePageType.ACCOUNT;

  @override
  Widget getTitle() {
    final String? userId = OpenFoodAPIConfiguration.globalUser?.userId;
    final String title;

    if (userId == null) {
      title = appLocalizations.user_profile_title_guest;
    } else if (userId.isEmail) {
      title = appLocalizations.user_profile_title_id_email(userId);
    } else {
      title = appLocalizations.user_profile_title_id_default(userId);
    }

    return Text(
      title,
      style: Theme.of(context).textTheme.headline2,
    );
  }

  @override
  String getTitleString() {
    return appLocalizations.myPreferences_profile_title;
  }

  @override
  Widget? getSubtitle() {
    if (!_isUserConnected()) {
      return const _UserPreferencesAccountSubTitleSignOut();
    } else {
      return Text(appLocalizations.myPreferences_profile_subtitle);
    }
  }

  @override
  IconData getLeadingIconData() => Icons.face;

  // No arrow
  @override
  Icon? getForwardIcon() {
    if (_isUserConnected()) {
      return super.getForwardIcon();
    } else {
      return null;
    }
  }

  @override
  Future<void> runHeaderAction() async {
    if (_isUserConnected(readOnly: true)) {
      return super.runHeaderAction();
    } else {
      return Navigator.of(
        context,
        rootNavigator: true,
      ).push<dynamic>(
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => const LoginPage(),
        ),
      );
    }
  }

  bool _isUserConnected({bool readOnly = false}) {
    // Ensure to be notified after a sign-in/sign-out
    if (!readOnly) {
      context.watch<UserManagementProvider>();
    }

    return OpenFoodAPIConfiguration.globalUser != null;
  }
}

class _UserPreferencesAccountSubTitleSignOut extends StatelessWidget {
  const _UserPreferencesAccountSubTitleSignOut({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Size size = MediaQuery.of(context).size;
    final ThemeData theme = Theme.of(context);

    return Column(
      children: <Widget>[
        Text(appLocalizations.user_profile_subtitle_guest),
        const SizedBox(height: LARGE_SPACE),
        Center(
          child: ElevatedButton(
            onPressed: () async {
              Navigator.of(
                context,
                rootNavigator: true,
              ).push<dynamic>(
                MaterialPageRoute<dynamic>(
                  builder: (BuildContext context) => const LoginPage(),
                ),
              );
            },
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
            child: Text(
              appLocalizations.sign_in,
              style: theme.textTheme.bodyText2?.copyWith(
                fontSize: 18.0,
                color: theme.colorScheme.surface,
              ),
            ),
          ),
        ),
      ],
    );
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
    final AppLocalizations localizations = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SmoothAlertDialog(
          title: localizations.sign_out,
          body: Text(
            localizations.sign_out_confirmation,
          ),
          positiveAction: SmoothActionButton(
            text: localizations.yes,
            onPressed: () async {
              context.read<UserManagementProvider>().logout();
              Navigator.pop(context);
            },
          ),
          negativeAction: SmoothActionButton(
            text: localizations.no,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // We need to listen to reflect login's from outside of the preferences page
    // e.g. question card, ...
    context.watch<UserManagementProvider>();

    final ThemeData theme = Theme.of(context);
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Size size = MediaQuery.of(context).size;

    final List<Widget> result = <Widget>[];

    if (OpenFoodAPIConfiguration.globalUser != null) {
      // Credentials
      final String userId = OpenFoodAPIConfiguration.globalUser!.userId;

      result.addAll(<Widget>[
        ListTile(
          onTap: () async => LaunchUrlHelper.launchURL(
            'https://openfoodfacts.org/editor/$userId',
            true,
          ),
          title: Text(appLocalizations.view_profile),
          leading: const Icon(Icons.open_in_new),
        ),
        const UserPreferencesListItemDivider(),
        ListTile(
          onTap: () => _confirmLogout(context),
          title: Text(appLocalizations.sign_out),
          leading: const Icon(Icons.clear),
        ),
        const UserPreferencesListItemDivider(),
        ListTile(
          onTap: () async {
            final Mailto mailtoLink = Mailto(
              to: <String>['contact@openfoodfacts.org'],
              subject: appLocalizations.email_subject_account_deletion,
              body: appLocalizations.email_body_account_deletion(userId),
            );
            await launchUrl(Uri.parse('$mailtoLink'));
          },
          title: Text(appLocalizations.account_delete),
          leading: const Icon(Icons.delete),
        ),
        const UserPreferencesListItemDivider(),
      ]);
    } else {
      // No credentials
      result.add(
        Center(
          child: ElevatedButton(
            onPressed: () async {
              Navigator.of(
                context,
                rootNavigator: true,
              ).push<dynamic>(
                MaterialPageRoute<dynamic>(
                  builder: (BuildContext context) => const LoginPage(),
                ),
              );
            },
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
            child: Text(
              appLocalizations.sign_in,
              style: theme.textTheme.bodyText2?.copyWith(
                fontSize: 18.0,
                color: theme.colorScheme.surface,
              ),
            ),
          ),
        ),
      );
    }
    result.add(
      CountrySelector(
        initialCountryCode: widget.userPreferences.userCountryCode,
      ),
    );

    return Column(children: result);
  }
}
