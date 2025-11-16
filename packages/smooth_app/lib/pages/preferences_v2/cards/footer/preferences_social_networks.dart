import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class SocialNetworksFooter extends StatelessWidget {
  const SocialNetworksFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    final double width = MediaQuery.widthOf(context);
    final bool lightTheme = context.lightTheme();

    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return SmoothCard(
      margin: EdgeInsetsDirectional.only(
        start: width * 0.1,
        end: width * 0.1,
        bottom: LARGE_SPACE,
      ),
      elevation: 2.0,
      color: lightTheme ? null : extension.primaryUltraBlack,
      child: IconTheme.merge(
        data: IconThemeData(
          color: lightTheme ? extension.primaryDark : Colors.white,
        ),
        child: Row(
          children: <Widget>[
            _SocialNetworkItem(
              icon: const icons.SocialNetwork.tiktok(),
              title: appLocalizations.tiktok,
              url: appLocalizations.tiktok_link,
            ),
            _SocialNetworkItem(
              icon: const icons.SocialNetwork.instagram(),
              title: appLocalizations.instagram,
              url: appLocalizations.instagram_link,
            ),
            _SocialNetworkItem(
              icon: const icons.SocialNetwork.twitter(),
              title: appLocalizations.twitter,
              url: appLocalizations.twitter_link,
            ),
            _SocialNetworkItem(
              icon: const icons.SocialNetwork.mastodon(),
              title: appLocalizations.mastodon,
              url: appLocalizations.mastodon_link,
            ),
            _SocialNetworkItem(
              icon: const icons.SocialNetwork.bluesky(),
              title: appLocalizations.bsky,
              url: appLocalizations.bsky_link,
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialNetworkItem extends StatelessWidget {
  const _SocialNetworkItem({
    required this.url,
    required this.title,
    required this.icon,
  });

  final String url;
  final String title;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Tooltip(
        message: title,
        child: IconButton(
          onPressed: () =>
              LaunchUrlHelper.launchURLInWebViewOrBrowser(context, url),
          icon: icon,
        ),
      ),
    );
  }
}
