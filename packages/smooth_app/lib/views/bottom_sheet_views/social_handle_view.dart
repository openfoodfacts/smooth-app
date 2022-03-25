import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_action_button.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_list_tile.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';

class SocialHandleView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              margin: const EdgeInsets.only(top: 20.0, bottom: 24.0),
              child: Text(
                AppLocalizations.of(context)!.connect_with_us,
                style: Theme.of(context).textTheme.headline1,
              ),
            ),
            // Instagram
            SmoothListTile(
                text: AppLocalizations.of(context)!.instagram,
                leadingWidget: const Icon(Icons.open_in_new),
                onPressed: () => _launchUrl(
                    context, 'https://instagram.com/open.food.facts')),

            //Twitter
            SmoothListTile(
              text: AppLocalizations.of(context)!.twitter,
              leadingWidget: const Icon(Icons.open_in_new),
              onPressed: () =>
                  _launchUrl(context, 'https://www.twitter.com/openfoodfacts'),
            ),

            //Blogger
            SmoothListTile(
              text: AppLocalizations.of(context)!.blogger,
              leadingWidget: const Icon(Icons.open_in_new),
              onPressed: () =>
                  _launchUrl(context, 'https://en.blog.openfoodfacts.org'),
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
