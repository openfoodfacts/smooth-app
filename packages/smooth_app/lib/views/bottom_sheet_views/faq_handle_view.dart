import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_list_tile.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';

class FaqHandleView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          children: <Widget>[
            buildContainer(context),
            SmoothListTile(
              text: AppLocalizations.of(context)!.faq,
              leadingWidget: const Icon(Icons.open_in_new),
              onPressed: () =>
                  _launchUrl(context, 'https://world.openfoodfacts.org/faq'),
            ),
            SmoothListTile(
              text: AppLocalizations.of(context)!.discover,
              leadingWidget: const Icon(Icons.open_in_new),
              onPressed: () => _launchUrl(
                  context, 'https://world.openfoodfacts.org/discover'),
            ),
            SmoothListTile(
              text: AppLocalizations.of(context)!.how_to_contribute,
              leadingWidget: const Icon(Icons.open_in_new),
              onPressed: () => _launchUrl(
                  context, 'https://world.openfoodfacts.org/contribute'),
            ),
            SmoothListTile(
              text: AppLocalizations.of(context)!.support,
              leadingWidget: const Icon(Icons.open_in_new),
              onPressed: () =>
                  _launchUrl(context, 'https://support.openfoodfacts.org/help'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildContainer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      margin: const EdgeInsets.only(top: 20.0, bottom: 24.0),
      child: Text(
        AppLocalizations.of(context)!.faq,
        style: Theme.of(context).textTheme.headline1,
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
