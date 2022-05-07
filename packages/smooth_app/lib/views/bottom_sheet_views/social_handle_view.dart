import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mailto/mailto.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_list_tile.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/widgets/modal_bottomsheet_header.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialHandleView extends StatelessWidget {
  static const Icon _icon = Icon(Icons.open_in_new);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return Material(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          children: <Widget>[
            ModalBottomSheetHeader(title: appLocalizations.connect_with_us),
            SmoothListTile(
                text: appLocalizations.instagram,
                leadingWidget: _icon,
                onPressed: () => _launchUrl(
                    context, 'https://instagram.com/open.food.facts')),
            SmoothListTile(
              text: appLocalizations.twitter,
              leadingWidget: _icon,
              onPressed: () =>
                  _launchUrl(context, 'https://www.twitter.com/openfoodfacts'),
            ),
            SmoothListTile(
              text: appLocalizations.blog,
              leadingWidget: _icon,
              onPressed: () =>
                  _launchUrl(context, 'https://en.blog.openfoodfacts.org'),
            ),
            SmoothListTile(
              text: appLocalizations.support_join_slack,
              leadingWidget: _icon,
              onPressed: () =>
                  _launchUrl(context, 'https://slack.openfoodfacts.org/'),
            ),
            SmoothListTile(
              text: appLocalizations.support_via_email,
              leadingWidget: _icon,
              onPressed: () async {
                final PackageInfo packageInfo =
                    await PackageInfo.fromPlatform();

                final Mailto mailtoLink = Mailto(
                  to: <String>['contact@openfoodfacts.org'],
                  subject: 'OpenFoodFacts (Codename: Smoothie) help',
                  body:
                      'Version:${packageInfo.version}+${packageInfo.buildNumber} running on ${Platform.operatingSystem}(${Platform.operatingSystemVersion})',
                );
                await launchUrl(Uri.parse('$mailtoLink'));
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    await LaunchUrlHelper.launchURL(
      url,
      false,
    );
  }
}
