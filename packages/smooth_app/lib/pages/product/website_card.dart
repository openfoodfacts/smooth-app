import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';

/// Card that displays a website link.
class WebsiteCard extends StatelessWidget {
  const WebsiteCard(this.website);

  final String website;

  @override
  Widget build(BuildContext context) {
    final String website = _getWebsite();
    return buildProductSmoothCard(
      body: InkWell(
        onTap: () => LaunchUrlHelper.launchURL(website, false),
        borderRadius: ROUNDED_BORDER_RADIUS,
        child: Container(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      AppLocalizations.of(context).product_field_website_title,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: SMALL_SPACE),
                    Text(
                      website,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.blue),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.open_in_new),
            ],
          ),
        ),
      ),
      margin: const EdgeInsets.only(
        left: SMALL_SPACE,
        right: SMALL_SPACE,
        bottom: MEDIUM_SPACE,
      ),
    );
  }

  String _getWebsite() =>
      !website.startsWith('http') ? 'http://$website' : website;
}
