import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

/// Card that displays a website link.
class WebsiteCard extends StatelessWidget {
  const WebsiteCard(this.website);

  final String website;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final String website = _getWebsite();

    return Semantics(
      label: localizations.product_field_website_title,
      value: Uri.parse(website).host,
      link: true,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsetsDirectional.all(BALANCED_SPACE),
        child: InkWell(
          onTap: () async => LaunchUrlHelper.launchURL(website),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                website,
                style: const TextStyle(fontSize: 15.5, color: Colors.blue),
              ),
              const icons.ExternalLink(),
            ],
          ),
        ),
      ),
    );
  }

  // TODO(g123k): That http is bothering me, what about switching to https?
  String _getWebsite() =>
      !website.startsWith('http') ? 'http://$website' : website;
}
