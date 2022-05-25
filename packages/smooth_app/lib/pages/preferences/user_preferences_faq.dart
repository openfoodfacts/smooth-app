import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/pages/preferences/abstract_user_preferences.dart';
import 'package:smooth_app/pages/preferences/user_preferences_list_tile.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';

/// Display of "FAQ" for the preferences page.
class UserPreferencesFaq extends AbstractUserPreferences {
  UserPreferencesFaq({
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
  PreferencePageType? getPreferencePageType() => PreferencePageType.FAQ;

  @override
  String getTitleString() => appLocalizations.faq;

  @override
  Widget? getSubtitle() => null;

  @override
  List<Widget> getBody() => <Widget>[
        _getListTile(
          title: appLocalizations.faq,
          url: 'https://support.openfoodfacts.org/help',
        ),
        _getListTile(
          title: appLocalizations.discover,
          url: 'https://world.openfoodfacts.org/discover',
        ),
        _getListTile(
          title: appLocalizations.how_to_contribute,
          url: 'https://world.openfoodfacts.org/contribute',
        ),
        _getListTile(
          title: appLocalizations.about_this_app,
          onTap: () async => _about(),
          icon: getForwardIcon(),
        ),
      ];

  Widget _getListTile({
    required final String title,
    final String? url,
    final VoidCallback? onTap,
    final Icon? icon,
  }) =>
      UserPreferencesListTile(
        title: Text(title),
        onTap: onTap ?? () async => LaunchUrlHelper.launchURL(url!, false),
        icon: icon ?? const Icon(Icons.open_in_new),
      );

  static const String _iconAssetPath = 'assets/app/release_icon.svg';

  Future<void> _about() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SmoothAlertDialog(
          body: Column(
            children: <Widget>[
              ListTile(
                leading: SvgPicture.asset(
                  _iconAssetPath,
                ),
                title: FittedBox(
                  child: Text(
                    packageInfo.appName,
                    style: themeData.textTheme.headline1,
                  ),
                ),
                subtitle: Text(
                  '${packageInfo.version}+${packageInfo.buildNumber}',
                  style: themeData.textTheme.subtitle2,
                ),
              ),
              Divider(color: themeData.colorScheme.onSurface),
              const SizedBox(height: 20),
              Text(appLocalizations.whatIsOff),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextButton(
                    onPressed: () => LaunchUrlHelper.launchURL(
                        'https://openfoodfacts.org/who-we-are', true),
                    child: Text(
                      appLocalizations.learnMore,
                      style: const TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => LaunchUrlHelper.launchURL(
                        'https://openfoodfacts.org/terms-of-use', true),
                    child: Text(
                      appLocalizations.termsOfUse,
                      style: const TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
          positiveAction: SmoothActionButton(
            onPressed: () async {
              showLicensePage(
                context: context,
                applicationName: packageInfo.appName,
                applicationVersion: packageInfo.version,
                applicationIcon: SvgPicture.asset(
                  _iconAssetPath,
                  height: MediaQuery.of(context).size.height * 0.1,
                ),
              );
            },
            text: appLocalizations.licenses,
          ),
          negativeAction: SmoothActionButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            text: appLocalizations.okay,
          ),
        );
      },
    );
  }
}
