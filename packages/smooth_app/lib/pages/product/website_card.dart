import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
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
        padding: const EdgeInsetsDirectional.only(
          top: VERY_LARGE_SPACE,
          start: SMALL_SPACE,
          end: SMALL_SPACE,
        ),
        child: InkWell(
          onTap: () async => LaunchUrlHelper.launchURL(website),
          borderRadius: ROUNDED_BORDER_RADIUS,
          child: buildProductSmoothCard(
            title: Text(localizations.product_field_website_title),
            body: Container(
              width: double.infinity,
              padding: const EdgeInsetsDirectional.only(
                start: LARGE_SPACE,
                top: LARGE_SPACE,
                bottom: LARGE_SPACE,
                // To be perfectly aligned with arrows
                end: 21.0,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      website,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.blue),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsetsDirectional.only(
                      start: 5.0,
                      end: 3.0,
                    ),
                    child: icons.ExternalLink(
                      size: 20.0,
                    ),
                  ),
                ],
              ),
            ),
            margin: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }

  // TODO(g123k): That http is bothering me, what about switching to https?
  String _getWebsite() =>
      !website.startsWith('http') ? 'http://$website' : website;
}
