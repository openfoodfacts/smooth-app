import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mailto/mailto.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/pages/preferences/abstract_user_preferences.dart';
import 'package:smooth_app/pages/preferences/user_preferences_list_tile.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:url_launcher/url_launcher.dart';

/// Display of "Connect" for the preferences page.
class UserPreferencesConnect extends AbstractUserPreferences {
  UserPreferencesConnect({
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
  PreferencePageType? getPreferencePageType() => PreferencePageType.CONNECT;

  @override
  String getTitleString() => appLocalizations.connect_with_us;

  @override
  Widget? getSubtitle() => null;

  @override
  IconData getLeadingIconData() => Icons.alternate_email;

  @override
  String? getHeaderAsset() => 'assets/preferences/contact.svg';

  @override
  Color? getHeaderColor() => const Color(0xFFDDE7FF);

  @override
  List<Widget> getBody() => <Widget>[
        _getListTile(
          title: appLocalizations.instagram,
          url: appLocalizations.instagram_link,
          leading: SvgPicture.asset(
            'assets/preferences/instagram-camera.svg',
            width: DEFAULT_ICON_SIZE,
          ),
        ),
        _getListTile(
          title: appLocalizations.twitter,
          url: appLocalizations.twitter_link,
          leading: SvgPicture.asset(
            'assets/preferences/twitter-bird.svg',
            width: DEFAULT_ICON_SIZE,
          ),
        ),
        _getListTile(
          title: appLocalizations.blog,
          url: 'https://blog.openfoodfacts.org',
          leading:
              UserPreferencesListTile.getTintedIcon(Icons.newspaper, context),
        ),
        _getListTile(
          title: appLocalizations.support_join_slack,
          url: 'https://slack.openfoodfacts.org/',
          leading: UserPreferencesListTile.getTintedIcon(Icons.forum, context),
        ),
        _getListTile(
          title: appLocalizations.support_via_email,
          leading: UserPreferencesListTile.getTintedIcon(Icons.drafts, context),
          onTap: () async {
            final PackageInfo packageInfo = await PackageInfo.fromPlatform();
            final Mailto mailtoLink = Mailto(
              to: <String>['contact@openfoodfacts.org'],
// This shouldn't be translated as its a debug message to OpenFoodFacts
              subject: 'Smoothie help',
              body: await _emailBody,
            );
            await launchUrl(Uri.parse('$mailtoLink'));
          },
        ),
      ];

  Future<String> get _emailBody async {
    final StringBuffer buffer = StringBuffer('\n\n----\n');
    final BaseDeviceInfo deviceInfo = await DeviceInfoPlugin().deviceInfo;

    if (deviceInfo is AndroidDeviceInfo) {
      buffer.writeln(
          'OS: Android (SDK Int: ${deviceInfo.version.sdkInt} / Release: ${deviceInfo.version.release})');
      buffer.writeln('Model: ${deviceInfo.model}');
      buffer.writeln('Product: ${deviceInfo.product}');
      buffer.writeln('Device: ${deviceInfo.device}');
      buffer.writeln('Brand: ${deviceInfo.brand}');
    } else if (deviceInfo is IosDeviceInfo) {
      buffer.writeln('OS: iOS (${deviceInfo.systemVersion})');
      buffer.writeln('Model: ${deviceInfo.model}');
      buffer.writeln('Localized model: ${deviceInfo.localizedModel}');
    }

    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    buffer.writeln('App version: ${packageInfo.version}');
    buffer.writeln('App build number: ${packageInfo.buildNumber}');
    buffer.writeln('App package name: ${packageInfo.packageName}');

    return buffer.toString();
  }

  Widget _getListTile({
    required final String title,
    required Widget leading,
    final String? url,
    final VoidCallback? onTap,
  }) =>
      UserPreferencesListTile(
        title: Text(title),
        onTap: onTap ?? () async => LaunchUrlHelper.launchURL(url!, false),
        trailing:
            UserPreferencesListTile.getTintedIcon(Icons.open_in_new, context),
        leading: leading,
      );
}
