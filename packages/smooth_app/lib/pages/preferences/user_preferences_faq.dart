import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/helpers/app_helper.dart';
import 'package:smooth_app/helpers/global_vars.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/helpers/user_feedback_helper.dart';
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
  IconData getLeadingIconData() => Icons.question_mark;

  @override
  String? getHeaderAsset() => 'assets/preferences/faq.svg';

  @override
  Color? getHeaderColor() => const Color(0xFFDFF7E8);

  @override
  List<Widget> getBody() => <Widget>[
        _getListTile(
          title: appLocalizations.faq,
          leading: Icons.question_mark,
          url: 'https://support.openfoodfacts.org/help',
        ),
        _getListTile(
          title: appLocalizations.discover,
          leading: Icons.travel_explore,
          url: 'https://world.openfoodfacts.org/discover',
        ),
        _getListTile(
          title: appLocalizations.how_to_contribute,
          leading: Icons.volunteer_activism,
          url: 'https://world.openfoodfacts.org/contribute',
        ),
        _getListTile(
          title: appLocalizations.feed_back,
          leading: Icons.feedback_sharp,
          url: UserFeedbackHelper.getFeedbackFormLink(),
        ),
        _getListTile(
          title: appLocalizations.about_this_app,
          leading: Icons.info,
          onTap: () async => _about(),
          icon: getForwardIcon(),
        ),
      ];

  Widget _getListTile({
    required final String title,
    required final IconData leading,
    final String? url,
    final VoidCallback? onTap,
    final Icon? icon,
  }) =>
      UserPreferencesListTile(
        title: Text(title),
        onTap: onTap ?? () async => LaunchUrlHelper.launchURL(url!, false),
        trailing: icon ??
            UserPreferencesListTile.getTintedIcon(Icons.open_in_new, context),
        leading: UserPreferencesListTile.getTintedIcon(leading, context),
      );

  static const String _iconLightAssetPath =
      'assets/app/release_icon_light_transparent_no_border.svg';
  static const String _iconDarkAssetPath =
      'assets/app/release_icon_dark_transparent_no_border.svg';

  Future<void> _about() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    // ignore: use_build_context_synchronously
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        final String logo = Theme.of(context).brightness == Brightness.light
            ? _iconLightAssetPath
            : _iconDarkAssetPath;
        return FractionallySizedBox(
          heightFactor: 0.6,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  top: MEDIUM_SPACE,
                  end: LARGE_SPACE,
                  start: LARGE_SPACE,
                ),
                child: Row(
                  children: <Widget>[
                    SvgPicture.asset(
                      logo,
                      width: MINIMUM_TOUCH_SIZE,
                      package: AppHelper.APP_PACKAGE,
                    ),
                    const SizedBox(width: SMALL_SPACE),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          FittedBox(
                            child: Text(
                              packageInfo.appName,
                              style: themeData.textTheme.displayLarge,
                            ),
                          ),
                          Text(
                            '${packageInfo.version}+${packageInfo.buildNumber}-${GlobalVars.scannerLabel.name}-${GlobalVars.storeLabel.name}',
                            style: themeData.textTheme.titleSmall,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: themeData.colorScheme.onBackground),
              Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      top: VERY_SMALL_SPACE,
                      end: LARGE_SPACE,
                      start: LARGE_SPACE,
                    ),
                    child: Text(appLocalizations.whatIsOff),
                  ),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: TextButton(
                            onPressed: () => LaunchUrlHelper.launchURL(
                                'https://openfoodfacts.org/who-we-are', true),
                            child: Text(
                              appLocalizations.learnMore,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed: () => LaunchUrlHelper.launchURL(
                                'https://openfoodfacts.org/terms-of-use', true),
                            child: Text(
                              appLocalizations.termsOfUse,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: MEDIUM_SPACE),
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      showLicensePage(
                        context: context,
                        applicationName: packageInfo.appName,
                        applicationVersion: packageInfo.version,
                        applicationIcon: SvgPicture.asset(
                          logo,
                          height: MediaQuery.of(context).size.height * 0.1,
                        ),
                      );
                    },
                    child: Text(
                      appLocalizations.licenses,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
