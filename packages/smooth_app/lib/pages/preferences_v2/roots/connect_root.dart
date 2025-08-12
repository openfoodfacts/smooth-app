import 'dart:ui' as ui;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_svg/svg.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/helpers/app_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences_v2/cards/preference_card.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/url_preference_tile.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/services/smooth_services.dart';

class ConnectRoot extends PreferencesRoot {
  const ConnectRoot({required super.title});

  @override
  List<PreferenceCard> getCards(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return <PreferenceCard>[
      PreferenceCard(
        title: 'Updates',
        tiles: <PreferenceTile>[
          UrlPreferenceTile(
            icon: CupertinoIcons.news_solid,
            title: appLocalizations.contact_title_newsletter,
            url: 'https://link.openfoodfacts.org/newsletter-en',
          ),
          UrlPreferenceTile(
            icon: Icons.calendar_month,
            title: appLocalizations.support_via_email,
            url: 'https://wiki.openfoodfacts.org/Events',
          ),
          PreferenceTile(
            icon: Icons.drafts,
            title: appLocalizations.preferences_app_system_settings,
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
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                    negativeAction: SmoothActionButton(
                      text: appLocalizations.no,
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  );
                },
              );

              if (includeLogs == null) {
                return;
              }

              final String emailBody = await _emailBody(appLocalizations);

              if (!context.mounted) {
                return;
              }

              await _sendEmail(
                context: context,
                recipient: 'mobile@openfoodfacts.org',
                appLocalizations: appLocalizations,
                body: emailBody,
                subject:
                    '${appLocalizations.help_with_openfoodfacts} (Help with Open Food Facts)',
                attachmentPaths: includeLogs == true
                    ? Logs.logFilesPaths
                    : null,
              );
            },
          ),
        ],
      ),
      PreferenceCard(
        title: 'Social',
        tiles: <PreferenceTile>[
          UrlPreferenceTile(
            leading: SvgPicture.asset(
              'assets/preferences/tiktok-logo.svg',
              width: DEFAULT_ICON_SIZE,
              package: AppHelper.APP_PACKAGE,
            ),
            title: appLocalizations.preferences_app_system_settings,
            url: appLocalizations.tiktok_link,
          ),
          UrlPreferenceTile(
            leading: SvgPicture.asset(
              'assets/preferences/instagram-camera.svg',
              width: DEFAULT_ICON_SIZE,
              package: AppHelper.APP_PACKAGE,
            ),
            title: appLocalizations.instagram,
            url: appLocalizations.instagram_link,
          ),
          UrlPreferenceTile(
            leading: SvgPicture.asset(
              'assets/preferences/x-logo.svg',
              width: DEFAULT_ICON_SIZE,
              colorFilter: ui.ColorFilter.mode(
                Theme.of(context).colorScheme.onSurface,
                ui.BlendMode.srcIn,
              ),
              package: AppHelper.APP_PACKAGE,
            ),
            title: appLocalizations.twitter,
            url: appLocalizations.twitter_link,
          ),
          UrlPreferenceTile(
            leading: SvgPicture.asset(
              'assets/preferences/mastodon-logo.svg',
              width: DEFAULT_ICON_SIZE,
              package: AppHelper.APP_PACKAGE,
            ),
            title: appLocalizations.mastodon,
            url: appLocalizations.mastodon_link,
          ),
          UrlPreferenceTile(
            leading: SvgPicture.asset(
              'assets/preferences/bluesky-logo.svg',
              width: DEFAULT_ICON_SIZE,
              package: AppHelper.APP_PACKAGE,
            ),
            title: appLocalizations.bsky,
            url: appLocalizations.bsky_link,
          ),
          UrlPreferenceTile(
            icon: Icons.newspaper,
            title: appLocalizations.blog,
            url: 'https://blog.openfoodfacts.org',
          ),
        ],
      ),
      PreferenceCard(
        title: 'Forum',
        tiles: <PreferenceTile>[
          UrlPreferenceTile(
            icon: Icons.forum,
            title: appLocalizations.support_via_forum,
            url: 'https://forum.openfoodfacts.org/',
          ),
          UrlPreferenceTile(
            icon: Icons.chat,
            title: appLocalizations.support_join_slack,
            url: 'https://slack.openfoodfacts.org/',
          ),
        ],
      ),
      PreferenceCard(
        title: 'Professionals',
        tiles: <PreferenceTile>[
          UrlPreferenceTile(
            icon: Icons.shopping_bag,
            title: appLocalizations.preferences_app_store,
            url: ProductQuery.replaceSubdomain(
              'https://world.pro.openfoodfacts.org/',
            ),
          ),
          PreferenceTile(
            icon: Icons.drafts,
            title: appLocalizations.contact_title_pro_email,
            onTap: () async => _sendEmail(
              context: context,
              recipient:
                  ProductQuery.getLanguage() == OpenFoodFactsLanguage.FRENCH
                  ? 'producteurs@openfoodfacts.org'
                  : 'producers@openfoodfacts.org',
              appLocalizations: appLocalizations,
            ),
          ),
        ],
      ),
      PreferenceCard(
        title: 'Press',
        tiles: <PreferenceTile>[
          UrlPreferenceTile(
            icon: CupertinoIcons.news_solid,
            title: appLocalizations.contact_title_press_page,
            url: 'https://world.openfoodfacts.org/press',
          ),
          PreferenceTile(
            icon: Icons.drafts,
            title: appLocalizations.contact_title_press_email,
            onTap: () async => _sendEmail(
              context: context,
              recipient:
                  ProductQuery.getLanguage() == OpenFoodFactsLanguage.FRENCH
                  ? 'presse@openfoodfacts.org'
                  : 'press@openfoodfacts.org',
              appLocalizations: appLocalizations,
            ),
          ),
        ],
      ),
    ];
  }

  Future<void> _sendEmail({
    required final BuildContext context,
    required final String recipient,
    required final AppLocalizations appLocalizations,
    final String body = '',
    final String subject = '',
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
                        ),
                      ],
                    ),
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

  Future<String> _emailBody(AppLocalizations appLocalizations) async {
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
      appLocalizations.contact_form_body(
        deviceText,
        packageInfo.version,
        packageInfo.buildNumber,
        packageInfo.packageName,
      ),
    );

    return buffer.toString();
  }
}
