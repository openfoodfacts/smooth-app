import 'dart:ui' as ui;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/helpers/app_helper.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/pages/preferences/abstract_user_preferences.dart';
import 'package:smooth_app/pages/preferences/user_preferences_item.dart';
import 'package:smooth_app/pages/preferences/user_preferences_list_tile.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/services/smooth_services.dart';

/// Display of "Connect" for the preferences page.
class UserPreferencesConnect extends AbstractUserPreferences {
  UserPreferencesConnect({
    required super.context,
    required super.userPreferences,
    required super.appLocalizations,
    required super.themeData,
  });

  @override
  PreferencePageType getPreferencePageType() => PreferencePageType.CONNECT;

  @override
  String getTitleString() => appLocalizations.connect_with_us;

  @override
  IconData getLeadingIconData() => Icons.alternate_email;

  @override
  String? getHeaderAsset() => 'assets/preferences/contact.svg';

  @override
  Color? getHeaderColor() => const Color(0xFFDDE7FF);

  @override
  List<UserPreferencesItem> getChildren() => <UserPreferencesItem>[
        _getListTile(
          title: appLocalizations.contact_title_newsletter,
          url: 'https://link.openfoodfacts.org/newsletter-en',
          leadingIconData: CupertinoIcons.news_solid,
        ),
        _getListTile(
          title: appLocalizations.contact_title_calendar,
          url: 'https://wiki.openfoodfacts.org/Events',
          leadingIconData: Icons.calendar_month,
        ),
        _getListTile(
          title: appLocalizations.support_via_email,
          leadingIconData: Icons.drafts,
          onTap: () async {
            final bool? includeLogs = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return SmoothAlertDialog(
                    title: appLocalizations
                        .support_via_email_include_logs_dialog_title,
                    body: Text(
                      appLocalizations
                          .support_via_email_include_logs_dialog_body,
                    ),
                    close: true,
                    positiveAction: SmoothActionButton(
                        text: appLocalizations.yes,
                        onPressed: () => Navigator.of(context).pop(true)),
                    negativeAction: SmoothActionButton(
                        text: appLocalizations.no,
                        onPressed: () => Navigator.of(context).pop(false)),
                  );
                });

            if (includeLogs == null) {
              return;
            }

            await _sendEmail(
              body: await _emailBody,
              subject:
                  '${appLocalizations.help_with_openfoodfacts} (Help with Open Food Facts)',
              recipient: 'mobile@openfoodfacts.org',
              attachmentPaths: includeLogs == true ? Logs.logFilesPaths : null,
            );
          },
        ),
        _getDivider(),
        _getListTile(
          title: appLocalizations.tiktok,
          url: appLocalizations.tiktok_link,
          leadingWidget: SvgPicture.asset(
            'assets/preferences/tiktok-logo.svg',
            width: DEFAULT_ICON_SIZE,
            package: AppHelper.APP_PACKAGE,
          ),
        ),
        _getListTile(
          title: appLocalizations.instagram,
          url: appLocalizations.instagram_link,
          leadingWidget: SvgPicture.asset(
            'assets/preferences/instagram-camera.svg',
            width: DEFAULT_ICON_SIZE,
            package: AppHelper.APP_PACKAGE,
          ),
        ),
        _getListTile(
          title: appLocalizations.twitter,
          url: appLocalizations.twitter_link,
          leadingWidget: SvgPicture.asset(
            'assets/preferences/x-logo.svg',
            width: DEFAULT_ICON_SIZE,
            colorFilter: ui.ColorFilter.mode(
              Theme.of(context).colorScheme.onSurface,
              ui.BlendMode.srcIn,
            ),
            package: AppHelper.APP_PACKAGE,
          ),
        ),
        _getListTile(
          title: appLocalizations.mastodon,
          url: appLocalizations.mastodon_link,
          leadingWidget: SvgPicture.asset(
            'assets/preferences/mastodon-logo.svg',
            width: DEFAULT_ICON_SIZE,
            package: AppHelper.APP_PACKAGE,
          ),
        ),
        _getListTile(
          title: appLocalizations.bsky,
          url: appLocalizations.bsky_link,
          leadingWidget: SvgPicture.asset(
            'assets/preferences/bluesky-logo.svg',
            width: DEFAULT_ICON_SIZE,
            package: AppHelper.APP_PACKAGE,
          ),
        ),
        _getListTile(
          title: appLocalizations.blog,
          url: 'https://blog.openfoodfacts.org',
          leadingIconData: Icons.newspaper,
        ),
        _getDivider(),
        _getListTile(
          title: appLocalizations.support_via_forum,
          url: 'https://forum.openfoodfacts.org/',
          leadingIconData: Icons.forum,
        ),
        _getListTile(
          title: appLocalizations.support_join_slack,
          url: 'https://slack.openfoodfacts.org/',
          leadingIconData: Icons.chat,
        ),
        _getDivider(),
        _getListTile(
          title: appLocalizations.contact_title_pro_page,
          url: ProductQuery.replaceSubdomain(
            'https://world.pro.openfoodfacts.org/',
          ),
          leadingIconData: Icons.factory_outlined,
        ),
        _getListTile(
          title: appLocalizations.contact_title_pro_email,
          leadingIconData: Icons.drafts,
          onTap: () async => _sendEmail(
            recipient:
                ProductQuery.getLanguage() == OpenFoodFactsLanguage.FRENCH
                    ? 'producteurs@openfoodfacts.org'
                    : 'producers@openfoodfacts.org',
          ),
        ),
        _getDivider(),
        _getListTile(
          title: appLocalizations.contact_title_press_page,
          url: ProductQuery.replaceSubdomain(
            'https://world.openfoodfacts.org/press',
          ),
          leadingIconData: CupertinoIcons.news_solid,
        ),
        _getListTile(
          title: appLocalizations.contact_title_press_email,
          leadingIconData: Icons.drafts,
          onTap: () async => _sendEmail(
            recipient:
                ProductQuery.getLanguage() == OpenFoodFactsLanguage.FRENCH
                    ? 'presse@openfoodfacts.org'
                    : 'press@openfoodfacts.org',
          ),
        ),
      ];

  Future<String> get _emailBody async {
    final StringBuffer buffer = StringBuffer('\n\n----\n');
    final BaseDeviceInfo deviceInfo = await DeviceInfoPlugin().deviceInfo;
    final String deviceText;

    if (deviceInfo is AndroidDeviceInfo) {
      deviceText = appLocalizations.contact_form_body_android(
        deviceInfo.version.sdkInt,
        deviceInfo.version.release,
        deviceInfo.model,
        deviceInfo.product,
        deviceInfo.device,
        deviceInfo.brand,
      );
    } else if (deviceInfo is IosDeviceInfo) {
      deviceText = appLocalizations.contact_form_body_ios(
        deviceInfo.systemVersion,
        deviceInfo.model,
        deviceInfo.localizedModel,
      );
    } else {
      deviceText = '';
    }

    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    buffer.writeln(
      appLocalizations.contact_form_body(deviceText, packageInfo.version,
          packageInfo.buildNumber, packageInfo.packageName),
    );

    return buffer.toString();
  }

  UserPreferencesItem _getListTile({
    required final String title,
    final IconData? leadingIconData,
    final Widget? leadingWidget,
    final String? url,
    final VoidCallback? onTap,
  }) =>
      UserPreferencesItemSimple(
        labels: <String>[title],
        builder: (_) => UserPreferencesListTile(
          title: Text(title),
          onTap: onTap ?? () async => LaunchUrlHelper.launchURL(url!),
          trailing:
              UserPreferencesListTile.getTintedIcon(Icons.open_in_new, context),
          leading: leadingIconData != null
              ? UserPreferencesListTile.getTintedIcon(leadingIconData, context)
              : leadingWidget,
          externalLink: true,
        ),
      );

  Future<void> _sendEmail({
    final String body = '',
    final String subject = '',
    required final String recipient,
    final List<String>? attachmentPaths,
  }) async {
    final Email email = Email(
      body: body,
      subject: subject,
      recipients: <String>[recipient],
      attachmentPaths: attachmentPaths,
    );

    try {
      await FlutterEmailSender.send(email);
    } on PlatformException catch (e) {
      if (e.code != 'not_available') {
        return;
      }
      // No email client installed on the device
      if (!context.mounted) {
        return;
      }
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) => ScaffoldMessenger(
          child: Builder(
            //Added scaffold to make the snack bar appear on the same level as dialog
            builder: (BuildContext context) => Scaffold(
              backgroundColor: Colors.transparent,
              body: SmoothAlertDialog(
                title: appLocalizations.no_email_client_available_dialog_title,
                body: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(appLocalizations.please_send_us_an_email_to),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(recipient),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          tooltip: appLocalizations.copy_email_to_clip_board,
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(text: recipient),
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    appLocalizations.email_copied_to_clip_board,
                                    textAlign: TextAlign.center,
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                        )
                      ],
                    )
                  ],
                ),
                positiveAction: SmoothActionButton(
                  onPressed: () =>
                      Navigator.of(context, rootNavigator: true).pop(),
                  text: appLocalizations.okay,
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  UserPreferencesItem _getDivider() => UserPreferencesItemSimple(
        labels: <String>[],
        builder: (_) => const Divider(),
      );
}
