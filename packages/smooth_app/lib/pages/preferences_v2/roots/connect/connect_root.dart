import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/helpers/user_feedback_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences_v2/cards/preference_card.dart';
import 'package:smooth_app/pages/preferences_v2/roots/connect/send_email_dialog.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/url_preference_tile.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/services/smooth_services.dart';

class ConnectRoot extends PreferencesRoot {
  const ConnectRoot({required super.title});

  @override
  List<PreferenceCard> getCards(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return <PreferenceCard>[
      PreferenceCard(
        title: appLocalizations.preferences_connect_community_updates_title,
        tiles: <PreferenceTile>[
          _buildBlogTile(appLocalizations),
          _buildNewsletterTile(appLocalizations),
          _buildCommunityCalendarTile(appLocalizations),
        ],
      ),
      PreferenceCard(
        title: appLocalizations.preferences_connect_community_help_title,
        tiles: <PreferenceTile>[
          _buildForumTile(appLocalizations),
          _buildSlackTile(appLocalizations),
        ],
      ),
      PreferenceCard(
        title: appLocalizations.preferences_connect_improve_app_title,
        tiles: <PreferenceTile>[
          _buildDebugInfoTile(context, appLocalizations),
          _buildFeedbackTile(context, appLocalizations),
          _buildSurveyTile(appLocalizations),
        ],
      ),
      PreferenceCard(
        title: appLocalizations.preferences_connect_professionals_title,
        tiles: <PreferenceTile>[
          _buildProPageTile(appLocalizations),
          _buildProEmailTile(context, appLocalizations),
        ],
      ),
      PreferenceCard(
        title: appLocalizations.preferences_connect_press_title,
        tiles: <PreferenceTile>[
          _buildPressPageTile(appLocalizations),
          _buildPressEmailTile(context, appLocalizations),
        ],
      ),
    ];
  }

  // Community Updates section
  UrlPreferenceTile _buildNewsletterTile(AppLocalizations appLocalizations) {
    return UrlPreferenceTile(
      icon: const icons.Newsletter(),
      title: appLocalizations.contact_title_newsletter,
      subtitleText: appLocalizations.preferences_connect_newsletter_subtitle,
      url: 'https://link.openfoodfacts.org/newsletter-en',
    );
  }

  UrlPreferenceTile _buildCommunityCalendarTile(
    AppLocalizations appLocalizations,
  ) {
    return UrlPreferenceTile(
      icon: const icons.Calendar.add(),
      title: appLocalizations.preferences_connect_community_calendar_title,
      subtitleText:
          appLocalizations.preferences_connect_community_calendar_subtitle,
      url: 'https://wiki.openfoodfacts.org/Events',
    );
  }

  UrlPreferenceTile _buildBlogTile(AppLocalizations appLocalizations) {
    return UrlPreferenceTile(
      leading: const icons.Megaphone(),
      title: appLocalizations.preferences_connect_blog_title,
      subtitleText: appLocalizations.preferences_connect_blog_subtitle,
      url: 'https://blog.openfoodfacts.org',
    );
  }

  // Community Help section
  UrlPreferenceTile _buildForumTile(AppLocalizations appLocalizations) {
    return UrlPreferenceTile(
      icon: const icons.Forum(),
      title: appLocalizations.support_via_forum,
      url: 'https://forum.openfoodfacts.org/',
    );
  }

  UrlPreferenceTile _buildSlackTile(AppLocalizations appLocalizations) {
    return UrlPreferenceTile(
      icon: const icons.SocialNetwork.slack(),
      title: appLocalizations.support_join_slack,
      url: 'https://slack.openfoodfacts.org/',
    );
  }

  // Improve App section
  PreferenceTile _buildDebugInfoTile(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return PreferenceTile(
      icon: const icons.Debug(),
      title: appLocalizations.preferences_connect_debug_info_title,
      subtitleText: appLocalizations.preferences_connect_debug_info_subtitle,
      onTap: _openDebugLogDialog(context, appLocalizations),
    );
  }

  PreferenceTile _buildFeedbackTile(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return PreferenceTile(
      icon: const icons.Feedback(),
      title: appLocalizations.preferences_connect_feedback_title,
      subtitleText: appLocalizations.preferences_connect_feedback_subtitle,
      onTap: () async {
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
              '${appLocalizations.help_with_openfoodfacts} (Feedback on the Open Food Facts app)',
        );
      },
    );
  }

  UrlPreferenceTile _buildSurveyTile(AppLocalizations appLocalizations) {
    return UrlPreferenceTile(
      icon: const icons.Feedback.form(),
      title: appLocalizations.preferences_connect_survey_title,
      subtitleText: appLocalizations.preferences_connect_survey_subtitle,
      url: UserFeedbackHelper.getFeedbackFormLink(),
    );
  }

  // Professionals section
  UrlPreferenceTile _buildProPageTile(AppLocalizations appLocalizations) {
    return UrlPreferenceTile(
      icon: const icons.Producer(),
      title: appLocalizations.contact_title_pro_page,
      subtitleText: appLocalizations.preferences_connect_pro_subtitle,
      url: ProductQuery.replaceSubdomain(
        'https://world.pro.openfoodfacts.org/',
      ),
    );
  }

  PreferenceTile _buildProEmailTile(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return PreferenceTile(
      icon: const icons.Message.edit(),
      title: appLocalizations.contact_title_pro_email,
      subtitleText: appLocalizations.preferences_connect_pro_email_subtitle,
      onTap: () async => _sendEmail(
        context: context,
        recipient: ProductQuery.getLanguage() == OpenFoodFactsLanguage.FRENCH
            ? 'producteurs@openfoodfacts.org'
            : 'producers@openfoodfacts.org',
        appLocalizations: appLocalizations,
      ),
    );
  }

  // Press section
  UrlPreferenceTile _buildPressPageTile(AppLocalizations appLocalizations) {
    return UrlPreferenceTile(
      icon: const icons.News.press(),
      title: appLocalizations.contact_title_press_page,
      subtitleText: appLocalizations.preferences_connect_press_page_subtitle,
      url: 'https://world.openfoodfacts.org/press',
    );
  }

  PreferenceTile _buildPressEmailTile(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return PreferenceTile(
      icon: const icons.Message.edit(),
      title: appLocalizations.contact_title_press_email,
      subtitleText: appLocalizations.preferences_connect_press_email_subtitle,
      onTap: () async => _sendEmail(
        context: context,
        recipient: ProductQuery.getLanguage() == OpenFoodFactsLanguage.FRENCH
            ? 'presse@openfoodfacts.org'
            : 'press@openfoodfacts.org',
        appLocalizations: appLocalizations,
      ),
    );
  }

  Future<void> Function() _openDebugLogDialog(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) => () async {
    final bool? includeLogs = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return SmoothAlertDialog(
          title: appLocalizations.support_via_email_include_logs_dialog_title,
          body: Text(
            appLocalizations.support_via_email_include_logs_dialog_body,
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
      attachmentPaths: includeLogs == true ? Logs.logFilesPaths : null,
    );
  };

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
            builder: (BuildContext context) =>
                SendEmailDialog(recipient: recipient),
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
