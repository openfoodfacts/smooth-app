import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_list_tile.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/widgets/modal_bottomsheet_header.dart';

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
            ModalBottomSheetHeader(
                title: AppLocalizations.of(context)!.connect_with_us),
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

            //Blog
            SmoothListTile(
              text: AppLocalizations.of(context)!.blog,
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
